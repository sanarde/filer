#pragma once

#include <QString>

namespace Trash {

QString filesDirectory();
QString reserveName(const QString &source);
void pruneOrphans();

}
