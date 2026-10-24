#include "Settings.h"

#include <QStandardPaths>

static QString settingsFile()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/settings.ini";
}

template<typename Enum>
static Enum readEnum(const QSettings &file, const QString &key, Enum fallback, int last)
{
    const int value = file.value(key, int(fallback)).toInt();
    return value >= 0 && value <= last ? Enum(value) : fallback;
}

Settings::Settings(QObject *parent)
    : QObject(parent)
    , m_file(settingsFile(), QSettings::IniFormat)
    , m_themeMode(readEnum(m_file, "appearance/mode", Theme::System, Theme::Dark))
    , m_palette(readEnum(m_file, "appearance/palette", Theme::Teal, Theme::Green))
    , m_showHidden(m_file.value("files/showHidden", false).toBool())
    , m_separateFolders(m_file.value("files/separateFolders", true).toBool())
    , m_detailsPanel(m_file.value("experimental/detailsPanel", false).toBool())
    , m_sortKey(readEnum(m_file, "view/sortKey", DirectoryModel::SortByName, DirectoryModel::SortByType))
    , m_sortDescending(m_file.value("view/sortDescending", false).toBool())
    , m_viewMode(m_file.value("view/mode", "grid").toString() == "list" ? "list" : "grid")
    , m_windowWidth(qMax(640, m_file.value("window/width", 1400).toInt()))
    , m_windowHeight(qMax(420, m_file.value("window/height", 860).toInt()))
    , m_windowMaximized(m_file.value("window/maximized", false).toBool())
{
}

void Settings::setThemeMode(Theme::Mode mode)
{
    if (m_themeMode == mode)
        return;
    m_themeMode = mode;
    m_file.setValue("appearance/mode", int(mode));
    emit themeModeChanged();
}

void Settings::setPalette(Theme::Palette palette)
{
    if (m_palette == palette)
        return;
    m_palette = palette;
    m_file.setValue("appearance/palette", int(palette));
    emit paletteChanged();
}

void Settings::setShowHidden(bool show)
{
    if (m_showHidden == show)
        return;
    m_showHidden = show;
    m_file.setValue("files/showHidden", show);
    emit showHiddenChanged();
}

void Settings::setSeparateFolders(bool separate)
{
    if (m_separateFolders == separate)
        return;
    m_separateFolders = separate;
    m_file.setValue("files/separateFolders", separate);
    emit separateFoldersChanged();
}

void Settings::setDetailsPanel(bool enabled)
{
    if (m_detailsPanel == enabled)
        return;
    m_detailsPanel = enabled;
    m_file.setValue("experimental/detailsPanel", enabled);
    emit detailsPanelChanged();
}

void Settings::setSortKey(DirectoryModel::SortKey key)
{
    if (m_sortKey == key)
        return;
    m_sortKey = key;
    m_file.setValue("view/sortKey", int(key));
    emit sortKeyChanged();
}

void Settings::setSortDescending(bool descending)
{
    if (m_sortDescending == descending)
        return;
    m_sortDescending = descending;
    m_file.setValue("view/sortDescending", descending);
    emit sortDescendingChanged();
}

void Settings::setViewMode(const QString &mode)
{
    if (m_viewMode == mode || (mode != "grid" && mode != "list"))
        return;
    m_viewMode = mode;
    m_file.setValue("view/mode", mode);
    emit viewModeChanged();
}

void Settings::setWindowWidth(int width)
{
    if (m_windowWidth == width)
        return;
    m_windowWidth = width;
    m_file.setValue("window/width", width);
    emit windowSizeChanged();
}

void Settings::setWindowHeight(int height)
{
    if (m_windowHeight == height)
        return;
    m_windowHeight = height;
    m_file.setValue("window/height", height);
    emit windowSizeChanged();
}

void Settings::setWindowMaximized(bool maximized)
{
    if (m_windowMaximized == maximized)
        return;
    m_windowMaximized = maximized;
    m_file.setValue("window/maximized", maximized);
    emit windowMaximizedChanged();
}
