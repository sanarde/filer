#pragma once

#include <QImage>
#include <QString>

namespace ThumbnailCache {

int sizeClass(int requested);
QImage load(const QString &path, int size);
void store(const QString &path, int size, const QImage &image);

}
