#include "RecentFiles.h"

#include <QFile>
#include <QFileInfo>
#include <QSet>
#include <QStandardPaths>
#include <QUrl>
#include <QXmlStreamReader>

QList<RecentFiles::Item> RecentFiles::read()
{
    QFile file(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
               + "/recently-used.xbel");
    if (!file.open(QIODevice::ReadOnly))
        return {};

    QList<Item> items;
    QSet<QString> seen;
    QXmlStreamReader xml(&file);
    while (xml.readNextStartElement() || !xml.atEnd()) {
        if (xml.name() != u"bookmark")
            continue;

        const QXmlStreamAttributes attributes = xml.attributes();
        const QUrl url(attributes.value("href").toString());
        const QString path = url.toLocalFile();
        if (path.isEmpty() || seen.contains(path) || !QFileInfo(path).isFile())
            continue;

        seen.insert(path);
        QDateTime visited = QDateTime::fromString(attributes.value("visited").toString(), Qt::ISODate);
        if (!visited.isValid())
            visited = QDateTime::fromString(attributes.value("modified").toString(), Qt::ISODate);
        items.append({path, visited});
    }
    return items;
}
