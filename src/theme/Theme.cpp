#include "Theme.h"

#include <QGuiApplication>
#include <QStyleHints>
#include <QVariantMap>

Theme::Theme(QObject *parent)
    : QObject(parent)
    , m_palettes(loadPalettes())
{
    connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged, this, [this] {
        if (m_mode == System)
            emit changed();
    });
}

bool Theme::dark() const
{
    if (m_mode == System)
        return QGuiApplication::styleHints()->colorScheme() != Qt::ColorScheme::Light;
    return m_mode == Dark;
}

const ColorSet &Theme::set() const
{
    for (const PaletteData &palette : m_palettes) {
        if (palette.id == m_palette)
            return dark() ? palette.dark : palette.light;
    }
    return dark() ? m_palettes.first().dark : m_palettes.first().light;
}

QVariantList Theme::palettes() const
{
    QVariantList result;
    for (const PaletteData &palette : m_palettes)
        result.append(QVariantMap{{"id", palette.id}, {"name", palette.name}});
    return result;
}

QColor Theme::swatch(const QString &id, bool dark) const
{
    for (const PaletteData &palette : m_palettes) {
        if (palette.id == id)
            return QColor(dark ? palette.dark.primary : palette.light.primary);
    }
    return QColor();
}

void Theme::setPalette(const QString &id)
{
    if (m_palette == id)
        return;
    m_palette = id;
    emit changed();
}

void Theme::setMode(Mode mode)
{
    if (m_mode == mode)
        return;
    m_mode = mode;
    emit changed();
}
