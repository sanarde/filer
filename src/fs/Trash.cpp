#include "Trash.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QUrl>

static QString trashRoot()
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/Trash";
}

QString Trash::filesDirectory()
{
    return trashRoot() + "/files";
}

QString Trash::reserveName(const QString &source)
{
    const QString infoDirectory = trashRoot() + "/info";
    QDir().mkpath(filesDirectory());
    QDir().mkpath(infoDirectory);

    const QFileInfo info(source);
    const QString base = info.completeBaseName();
    const QString suffix = info.suffix().isEmpty() ? QString() : u'.' + info.suffix();

    QString name = info.fileName();
    for (int i = 2;; ++i) {
        QFile entry(infoDirectory + u'/' + name + ".trashinfo");
        if (!QFileInfo::exists(filesDirectory() + u'/' + name) && entry.open(QIODevice::WriteOnly | QIODevice::NewOnly)) {
            const QString path = QString::fromLatin1(QUrl::toPercentEncoding(info.absoluteFilePath(), "/"));
            entry.write("[Trash Info]\nPath=" + path.toUtf8() + "\nDeletionDate="
                        + QDateTime::currentDateTime().toString(Qt::ISODate).toUtf8() + "\n");
            return name;
        }
        name = QStringLiteral("%1 (%2)%3").arg(base).arg(i).arg(suffix);
    }
}

void Trash::pruneOrphans()
{
    const QDir infoDirectory(trashRoot() + "/info");
    const QStringList entries = infoDirectory.entryList({"*.trashinfo"}, QDir::Files);
    for (const QString &entry : entries) {
        const QString name = entry.chopped(QStringLiteral(".trashinfo").size());
        const QFileInfo file(filesDirectory() + u'/' + name);
        if (!file.exists() && !file.isSymLink())
            QFile::remove(infoDirectory.filePath(entry));
    }
}
