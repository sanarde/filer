#include "Translator.h"

#include <libintl.h>

Translator::Translator(QObject *parent)
    : QObject(parent)
{
}

QString Translator::t(const QString &msgid) const
{
    return QString::fromUtf8(dgettext("sanar-filer", msgid.toUtf8().constData()));
}

QString Translator::n(const QString &singular, const QString &plural, int count) const
{
    return QString::fromUtf8(dngettext("sanar-filer", singular.toUtf8().constData(),
                                       plural.toUtf8().constData(), count));
}
