#include "ThumbnailCache.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>
#include <QStandardPaths>
#include <QUrl>

static QString className(int size)
{
    switch (size) {
    case 128:
        return "normal";
    case 256:
        return "large";
    case 512:
        return "x-large";
    }
    return "xx-large";
}

static QString uriOf(const QString &path)
{
    return QString::fromLatin1(QUrl::fromLocalFile(path).toEncoded());
}

static QString cachePath(const QString &path, int size)
{
    const QString name = QString::fromLatin1(
        QCryptographicHash::hash(uriOf(path).toUtf8(), QCryptographicHash::Md5).toHex());
    return QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)
           + "/thumbnails/" + className(size) + u'/' + name + ".png";
}

int ThumbnailCache::sizeClass(int requested)
{
    for (const int size : {128, 256, 512}) {
        if (requested <= size)
            return size;
    }
    return 1024;
}

QImage ThumbnailCache::load(const QString &path, int size)
{
    QImage image(cachePath(path, size));
    if (image.isNull())
        return image;
    const qint64 modified = QFileInfo(path).lastModified().toSecsSinceEpoch();
    if (image.text("Thumb::URI") != uriOf(path) || image.text("Thumb::MTime").toLongLong() != modified)
        return QImage();
    return image;
}

void ThumbnailCache::store(const QString &path, int size, const QImage &image)
{
    const QString target = cachePath(path, size);
    const QString directory = QFileInfo(target).path();
    if (!QDir().mkpath(directory))
        return;
    QFile::setPermissions(directory, QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner);

    QImage stamped = image;
    stamped.setText("Thumb::URI", uriOf(path));
    stamped.setText("Thumb::MTime", QString::number(QFileInfo(path).lastModified().toSecsSinceEpoch()));

    QSaveFile file(target);
    if (!file.open(QIODevice::WriteOnly))
        return;
    file.setPermissions(QFile::ReadOwner | QFile::WriteOwner);
    if (stamped.save(&file, "PNG"))
        file.commit();
}
