#include "Translator.h"

#include <libintl.h>

#include <clocale>

Translator::Translator(QObject *parent)
    : QObject(parent)
{
    setlocale(LC_MESSAGES, "");
    bindtextdomain("sanar-filer", LOCALEDIR);
    bind_textdomain_codeset("sanar-filer", "UTF-8");
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
