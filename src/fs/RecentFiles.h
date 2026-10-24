#pragma once

#include <QDateTime>
#include <QList>
#include <QString>

namespace RecentFiles {

inline const QString location = QStringLiteral("recent://");

struct Item {
    QString path;
    QDateTime visited;
};

QList<Item> read();

}
