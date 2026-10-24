#pragma once

#include <QMimeType>
#include <QObject>
#include <QtQml/qqmlregistration.h>

namespace FileKinds {
Q_NAMESPACE
QML_NAMED_ELEMENT(FileKind)

enum Kind {
    Folder,
    Image,
    Document,
    Code,
    Archive,
    Audio,
    Video,
    Other,
};
Q_ENUM_NS(Kind)

Kind kindOf(const QMimeType &mime);
QString iconName(Kind kind);
}
