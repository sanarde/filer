#pragma once

#include <QRgb>

struct ColorSet {
    QRgb desk;
    QRgb background;
    QRgb surfaceLowest;
    QRgb surfaceLow;
    QRgb surface;
    QRgb surfaceHigh;
    QRgb surfaceHighest;
    QRgb onSurface;
    QRgb onSurfaceVariant;
    QRgb outline;
    QRgb outlineVariant;
    QRgb primary;
    QRgb onPrimary;
    QRgb primaryContainer;
    QRgb onPrimaryContainer;
    QRgb secondaryContainer;
    QRgb onSecondaryContainer;
    QRgb tertiary;
    QRgb tertiaryContainer;
    QRgb onTertiaryContainer;
    QRgb errorContainer;
    QRgb onErrorContainer;
};

extern const ColorSet colorSets[4][2];
