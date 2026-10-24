#include "Icons.h"

#include <QFile>
#include <QTextStream>

Icons::Icons(QObject *parent)
    : QObject(parent)
{
    QFile file(":/icons.txt");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning("Cannot open icon table: %s", qPrintable(file.errorString()));
        return;
    }
    QTextStream in(&file);
    QString name;
    QString code;
    while (in >> name >> code)
        m_glyphs.insert(name, QString(QChar(code.toUInt(nullptr, 16))));
}

QString Icons::glyph(const QString &name) const
{
    if (name.isEmpty())
        return {};

    const auto it = m_glyphs.constFind(name);
    if (it == m_glyphs.constEnd()) {
        qWarning("Unknown icon: %s", qPrintable(name));
        return {};
    }
    return *it;
}
