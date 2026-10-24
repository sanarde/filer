#pragma once

#include <QList>
#include <QString>

#include "ColorSet.h"

struct PaletteData {
    QString id;
    QString name;
    ColorSet light;
    ColorSet dark;
};

QList<PaletteData> loadPalettes();
