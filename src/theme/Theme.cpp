#include "Theme.h"

#include <QGuiApplication>
#include <QStyleHints>

Theme::Theme(QObject *parent)
    : QObject(parent)
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

QColor Theme::swatch(Palette palette) const
{
    return QColor(colorSets[palette][dark() ? 1 : 0].primary);
}

void Theme::setPalette(Palette palette)
{
    if (m_palette == palette)
        return;
    m_palette = palette;
    emit changed();
}

void Theme::setMode(Mode mode)
{
    if (m_mode == mode)
        return;
    m_mode = mode;
    emit changed();
}
