#pragma once

#include <QString>

namespace Trash {

QString filesDirectory();
QString reserveName(const QString &source);
QString originalPath(const QString &trashed);
void pruneOrphans();

}
