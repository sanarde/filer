#include "Palettes.h"

#include <QColor>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QStandardPaths>

namespace {

struct Field {
    const char *key;
    QRgb ColorSet::*member;
};

const Field fields[] = {
    {"desk", &ColorSet::desk},
    {"background", &ColorSet::background},
    {"surfaceLowest", &ColorSet::surfaceLowest},
    {"surfaceLow", &ColorSet::surfaceLow},
    {"surface", &ColorSet::surface},
    {"surfaceHigh", &ColorSet::surfaceHigh},
    {"surfaceHighest", &ColorSet::surfaceHighest},
    {"onSurface", &ColorSet::onSurface},
    {"onSurfaceVariant", &ColorSet::onSurfaceVariant},
    {"outline", &ColorSet::outline},
    {"outlineVariant", &ColorSet::outlineVariant},
    {"primary", &ColorSet::primary},
    {"onPrimary", &ColorSet::onPrimary},
    {"primaryContainer", &ColorSet::primaryContainer},
    {"onPrimaryContainer", &ColorSet::onPrimaryContainer},
    {"secondaryContainer", &ColorSet::secondaryContainer},
    {"onSecondaryContainer", &ColorSet::onSecondaryContainer},
    {"tertiary", &ColorSet::tertiary},
    {"tertiaryContainer", &ColorSet::tertiaryContainer},
    {"onTertiaryContainer", &ColorSet::onTertiaryContainer},
    {"errorContainer", &ColorSet::errorContainer},
    {"onErrorContainer", &ColorSet::onErrorContainer},
};

bool parseSet(const QJsonObject &object, ColorSet &set)
{
    for (const Field &field : fields) {
        const QColor color(object.value(QLatin1String(field.key)).toString());
        if (!color.isValid())
            return false;
        set.*field.member = color.rgb();
    }
    return true;
}

QString parseName(const QJsonValue &value, const QString &id)
{
    if (value.isString())
        return value.toString();
    const QJsonObject names = value.toObject();
    const QString language = QLocale().name().section(u'_', 0, 0);
    for (const QString &key : {language, QStringLiteral("en")}) {
        if (names.value(key).isString())
            return names.value(key).toString();
    }
    return id;
}

bool parsePalette(const QString &path, PaletteData &palette)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return false;
    const QJsonObject object = QJsonDocument::fromJson(file.readAll()).object();
    palette.id = object.value("id").toString();
    palette.name = parseName(object.value("name"), palette.id);
    return !palette.id.isEmpty() && parseSet(object.value("light").toObject(), palette.light)
           && parseSet(object.value("dark").toObject(), palette.dark);
}

void loadDirectory(const QString &directory, QList<PaletteData> &palettes)
{
    const QStringList files = QDir(directory).entryList({"*.json"}, QDir::Files, QDir::Name);
    for (const QString &name : files) {
        PaletteData palette;
        if (!parsePalette(directory + u'/' + name, palette))
            continue;
        const auto existing = std::find_if(palettes.begin(), palettes.end(),
                                           [&](const PaletteData &item) { return item.id == palette.id; });
        if (existing != palettes.end())
            *existing = palette;
        else
            palettes.append(palette);
    }
}

}

QList<PaletteData> loadPalettes()
{
    QList<PaletteData> palettes;
    loadDirectory(":/palettes", palettes);
    loadDirectory(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/palettes", palettes);
    return palettes;
}
