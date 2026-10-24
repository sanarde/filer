#include "SizeFormat.h"

#include <libintl.h>

#include <QLocale>

QString formatSize(qint64 bytes)
{
    const char *units[] = {
        dgettext("sanar-filer", "B"),
        dgettext("sanar-filer", "KB"),
        dgettext("sanar-filer", "MB"),
        dgettext("sanar-filer", "GB"),
        dgettext("sanar-filer", "TB"),
    };

    double value = bytes;
    int unit = 0;
    while (value >= 1000 && unit < 4) {
        value /= 1000;
        ++unit;
    }

    const int decimals = unit > 0 && value < 10 ? 1 : 0;
    return QLocale().toString(value, 'f', decimals) + QChar(0x00A0) + QString::fromUtf8(units[unit]);
}
