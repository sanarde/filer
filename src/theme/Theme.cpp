#include "Theme.h"

#include <QGuiApplication>
#include <QStyleHints>

Theme::Theme(QObject *parent)
    : QObject(parent)
    , m_dark(QGuiApplication::styleHints()->colorScheme() != Qt::ColorScheme::Light)
{
}

void Theme::setPalette(Palette palette)
{
    if (m_palette == palette)
        return;
    m_palette = palette;
    emit changed();
}

void Theme::setDark(bool dark)
{
    if (m_dark == dark)
        return;
    m_dark = dark;
    emit changed();
}
