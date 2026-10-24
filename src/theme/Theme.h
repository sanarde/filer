#pragma once

#include <QColor>
#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "ColorSet.h"

class Theme : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(Palette palette READ palette WRITE setPalette NOTIFY changed FINAL)
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY changed FINAL)
    Q_PROPERTY(bool dark READ dark NOTIFY changed FINAL)
    Q_PROPERTY(QColor desk READ desk NOTIFY changed FINAL)
    Q_PROPERTY(QColor background READ background NOTIFY changed FINAL)
    Q_PROPERTY(QColor surfaceLowest READ surfaceLowest NOTIFY changed FINAL)
    Q_PROPERTY(QColor surfaceLow READ surfaceLow NOTIFY changed FINAL)
    Q_PROPERTY(QColor surface READ surface NOTIFY changed FINAL)
    Q_PROPERTY(QColor surfaceHigh READ surfaceHigh NOTIFY changed FINAL)
    Q_PROPERTY(QColor surfaceHighest READ surfaceHighest NOTIFY changed FINAL)
    Q_PROPERTY(QColor onSurface READ onSurface NOTIFY changed FINAL)
    Q_PROPERTY(QColor onSurfaceVariant READ onSurfaceVariant NOTIFY changed FINAL)
    Q_PROPERTY(QColor outline READ outline NOTIFY changed FINAL)
    Q_PROPERTY(QColor outlineVariant READ outlineVariant NOTIFY changed FINAL)
    Q_PROPERTY(QColor primary READ primary NOTIFY changed FINAL)
    Q_PROPERTY(QColor onPrimary READ onPrimary NOTIFY changed FINAL)
    Q_PROPERTY(QColor primaryContainer READ primaryContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor onPrimaryContainer READ onPrimaryContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor secondaryContainer READ secondaryContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor onSecondaryContainer READ onSecondaryContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor tertiary READ tertiary NOTIFY changed FINAL)
    Q_PROPERTY(QColor tertiaryContainer READ tertiaryContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor onTertiaryContainer READ onTertiaryContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor errorContainer READ errorContainer NOTIFY changed FINAL)
    Q_PROPERTY(QColor onErrorContainer READ onErrorContainer NOTIFY changed FINAL)

public:
    enum Palette {
        Teal,
        Coral,
        Indigo,
        Green,
    };
    Q_ENUM(Palette)

    enum Mode {
        System,
        Light,
        Dark,
    };
    Q_ENUM(Mode)

    explicit Theme(QObject *parent = nullptr);

    Palette palette() const { return m_palette; }
    Mode mode() const { return m_mode; }
    bool dark() const;
    void setPalette(Palette palette);
    void setMode(Mode mode);

    Q_INVOKABLE QColor swatch(Palette palette) const;

    QColor desk() const { return QColor(set().desk); }
    QColor background() const { return QColor(set().background); }
    QColor surfaceLowest() const { return QColor(set().surfaceLowest); }
    QColor surfaceLow() const { return QColor(set().surfaceLow); }
    QColor surface() const { return QColor(set().surface); }
    QColor surfaceHigh() const { return QColor(set().surfaceHigh); }
    QColor surfaceHighest() const { return QColor(set().surfaceHighest); }
    QColor onSurface() const { return QColor(set().onSurface); }
    QColor onSurfaceVariant() const { return QColor(set().onSurfaceVariant); }
    QColor outline() const { return QColor(set().outline); }
    QColor outlineVariant() const { return QColor(set().outlineVariant); }
    QColor primary() const { return QColor(set().primary); }
    QColor onPrimary() const { return QColor(set().onPrimary); }
    QColor primaryContainer() const { return QColor(set().primaryContainer); }
    QColor onPrimaryContainer() const { return QColor(set().onPrimaryContainer); }
    QColor secondaryContainer() const { return QColor(set().secondaryContainer); }
    QColor onSecondaryContainer() const { return QColor(set().onSecondaryContainer); }
    QColor tertiary() const { return QColor(set().tertiary); }
    QColor tertiaryContainer() const { return QColor(set().tertiaryContainer); }
    QColor onTertiaryContainer() const { return QColor(set().onTertiaryContainer); }
    QColor errorContainer() const { return QColor(set().errorContainer); }
    QColor onErrorContainer() const { return QColor(set().onErrorContainer); }

signals:
    void changed();

private:
    const ColorSet &set() const { return colorSets[m_palette][dark() ? 1 : 0]; }

    Palette m_palette = Teal;
    Mode m_mode = System;
};
