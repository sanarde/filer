#include "Settings.h"

#include <QByteArray>
#include <QFile>
#include <QSettings>
#include <QStandardPaths>

#include <cstdlib>

namespace {

const QString prefix = QStringLiteral("/org/nuros/sanar/filer/");
const char *const themeModes[] = {"system", "light", "dark"};
const char *const sortKeys[] = {"name", "modified", "size", "type"};

QByteArray keyPath(const char *name)
{
    return (prefix + QLatin1String(name)).toUtf8();
}

template<typename Enum, size_t N>
Enum enumFromName(const QString &name, const char *const (&names)[N], Enum fallback)
{
    for (size_t i = 0; i < N; ++i) {
        if (name == QLatin1String(names[i]))
            return Enum(i);
    }
    return fallback;
}


int migrateBool(cfgd_t *cfgd, const QSettings &file, const char *legacyKey, const char *name)
{
    if (!file.contains(legacyKey))
        return CFGD_OK;
    return cfgd_set_bool(cfgd, keyPath(name).constData(), file.value(legacyKey).toBool());
}

int migrateString(cfgd_t *cfgd, const QSettings &file, const char *legacyKey, const char *name)
{
    if (!file.contains(legacyKey))
        return CFGD_OK;
    return cfgd_set_string(cfgd, keyPath(name).constData(),
                           file.value(legacyKey).toString().toUtf8().constData());
}

template<size_t N>
int migrateIndex(cfgd_t *cfgd, const QSettings &file, const char *legacyKey, const char *name,
                 const char *const (&names)[N])
{
    const int index = file.value(legacyKey, -1).toInt();
    if (index < 0 || size_t(index) >= N)
        return CFGD_OK;
    return cfgd_set_string(cfgd, keyPath(name).constData(), names[index]);
}

}

Settings::Settings(QObject *parent)
    : QObject(parent)
    , m_cfgd(cfgd_open())
{
    if (!m_cfgd) {
        qWarning("Cannot open the cfgd database, settings are not saved");
    } else {
        cfgd_subscribe(m_cfgd, keyPath("").constData(), keyChanged, this);
        const int fd = cfgd_notify_fd(m_cfgd);
        if (fd >= 0) {
            m_notifier = new QSocketNotifier(fd, QSocketNotifier::Read, this);
            connect(m_notifier, &QSocketNotifier::activated, this, &Settings::dispatch);
        }
    }

    migrateLegacy();

    m_themeMode = readThemeMode();
    m_palette = readString("palette", "teal");
    m_showHidden = readBool("show-hidden", false);
    m_separateFolders = readBool("separate-folders", true);
    m_detailsPanel = readBool("details-panel", false);
    m_sortKey = readSortKey();
    m_sortDescending = readBool("sort-descending", false);
    m_viewMode = readViewMode();
}

Settings::~Settings()
{
    cfgd_close(m_cfgd);
}

void Settings::keyChanged(const char *key, void *user)
{
    const QString path = QString::fromUtf8(key);

    if (path.startsWith(prefix))
        static_cast<Settings *>(user)->reload(path.mid(prefix.size()));
}

void Settings::migrateLegacy()
{
    const QString path = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/settings.ini";
    static const char *const legacyPalettes[] = {"teal", "coral", "indigo", "green"};
    int status = CFGD_OK;

    if (!m_cfgd || !QFile::exists(path))
        return;
    const QSettings file(path, QSettings::IniFormat);

    status = migrateIndex(m_cfgd, file, "appearance/mode", "theme-mode", themeModes);
    if (status == CFGD_OK && file.contains("appearance/paletteId"))
        status = migrateString(m_cfgd, file, "appearance/paletteId", "palette");
    else if (status == CFGD_OK)
        status = migrateIndex(m_cfgd, file, "appearance/palette", "palette", legacyPalettes);
    if (status == CFGD_OK)
        status = migrateBool(m_cfgd, file, "files/showHidden", "show-hidden");
    if (status == CFGD_OK)
        status = migrateBool(m_cfgd, file, "files/separateFolders", "separate-folders");
    if (status == CFGD_OK)
        status = migrateBool(m_cfgd, file, "experimental/detailsPanel", "details-panel");
    if (status == CFGD_OK)
        status = migrateIndex(m_cfgd, file, "view/sortKey", "sort-key", sortKeys);
    if (status == CFGD_OK)
        status = migrateBool(m_cfgd, file, "view/sortDescending", "sort-descending");
    if (status == CFGD_OK)
        status = migrateString(m_cfgd, file, "view/mode", "view-mode");

    if (status == CFGD_OK)
        QFile::rename(path, path + ".migrated");
    else
        qWarning("Cannot move the settings to cfgd, the old file is kept");
}

void Settings::dispatch()
{
    cfgd_dispatch(m_cfgd);
}

void Settings::reload(const QString &name)
{
    if (name == "theme-mode") {
        const Theme::Mode mode = readThemeMode();
        if (mode != m_themeMode) {
            m_themeMode = mode;
            emit themeModeChanged();
        }
    } else if (name == "palette") {
        const QString palette = readString("palette", "teal");
        if (palette != m_palette) {
            m_palette = palette;
            emit paletteChanged();
        }
    } else if (name == "show-hidden") {
        const bool value = readBool("show-hidden", false);
        if (value != m_showHidden) {
            m_showHidden = value;
            emit showHiddenChanged();
        }
    } else if (name == "separate-folders") {
        const bool value = readBool("separate-folders", true);
        if (value != m_separateFolders) {
            m_separateFolders = value;
            emit separateFoldersChanged();
        }
    } else if (name == "details-panel") {
        const bool value = readBool("details-panel", false);
        if (value != m_detailsPanel) {
            m_detailsPanel = value;
            emit detailsPanelChanged();
        }
    } else if (name == "sort-key") {
        const DirectoryModel::SortKey key = readSortKey();
        if (key != m_sortKey) {
            m_sortKey = key;
            emit sortKeyChanged();
        }
    } else if (name == "sort-descending") {
        const bool value = readBool("sort-descending", false);
        if (value != m_sortDescending) {
            m_sortDescending = value;
            emit sortDescendingChanged();
        }
    } else if (name == "view-mode") {
        const QString mode = readViewMode();
        if (mode != m_viewMode) {
            m_viewMode = mode;
            emit viewModeChanged();
        }
    }
}

bool Settings::readBool(const char *name, bool fallback) const
{
    bool value;
    return m_cfgd && cfgd_get_bool(m_cfgd, keyPath(name).constData(), &value) ? value : fallback;
}

QString Settings::readString(const char *name, const QString &fallback) const
{
    char *text = m_cfgd ? cfgd_get_string(m_cfgd, keyPath(name).constData()) : nullptr;
    if (!text)
        return fallback;
    const QString value = QString::fromUtf8(text);
    free(text);
    return value;
}

Theme::Mode Settings::readThemeMode() const
{
    return enumFromName(readString("theme-mode", "system"), themeModes, Theme::System);
}

DirectoryModel::SortKey Settings::readSortKey() const
{
    return enumFromName(readString("sort-key", "name"), sortKeys, DirectoryModel::SortByName);
}

QString Settings::readViewMode() const
{
    return readString("view-mode", "grid") == "list" ? "list" : "grid";
}

void Settings::writeBool(const char *name, bool value)
{
    if (m_cfgd && cfgd_set_bool(m_cfgd, keyPath(name).constData(), value) != CFGD_OK)
        qWarning("Cannot save %s", name);
}

void Settings::writeString(const char *name, const QString &value)
{
    if (m_cfgd && cfgd_set_string(m_cfgd, keyPath(name).constData(), value.toUtf8().constData()) != CFGD_OK)
        qWarning("Cannot save %s", name);
}

void Settings::setThemeMode(Theme::Mode mode)
{
    if (m_themeMode == mode)
        return;
    m_themeMode = mode;
    writeString("theme-mode", themeModes[mode]);
    emit themeModeChanged();
}

void Settings::setPalette(const QString &palette)
{
    if (m_palette == palette)
        return;
    m_palette = palette;
    writeString("palette", palette);
    emit paletteChanged();
}

void Settings::setShowHidden(bool show)
{
    if (m_showHidden == show)
        return;
    m_showHidden = show;
    writeBool("show-hidden", show);
    emit showHiddenChanged();
}

void Settings::setSeparateFolders(bool separate)
{
    if (m_separateFolders == separate)
        return;
    m_separateFolders = separate;
    writeBool("separate-folders", separate);
    emit separateFoldersChanged();
}

void Settings::setDetailsPanel(bool enabled)
{
    if (m_detailsPanel == enabled)
        return;
    m_detailsPanel = enabled;
    writeBool("details-panel", enabled);
    emit detailsPanelChanged();
}

void Settings::setSortKey(DirectoryModel::SortKey key)
{
    if (m_sortKey == key)
        return;
    m_sortKey = key;
    writeString("sort-key", sortKeys[key]);
    emit sortKeyChanged();
}

void Settings::setSortDescending(bool descending)
{
    if (m_sortDescending == descending)
        return;
    m_sortDescending = descending;
    writeBool("sort-descending", descending);
    emit sortDescendingChanged();
}

void Settings::setViewMode(const QString &mode)
{
    if (m_viewMode == mode || (mode != "grid" && mode != "list"))
        return;
    m_viewMode = mode;
    writeString("view-mode", mode);
    emit viewModeChanged();
}
