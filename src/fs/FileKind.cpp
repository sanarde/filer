#include "FileKind.h"

#include <QStringList>

namespace FileKinds {

static bool inheritsAny(const QMimeType &mime, const QStringList &names)
{
    for (const QString &name : names) {
        if (mime.inherits(name))
            return true;
    }
    return false;
}

Kind kindOf(const QMimeType &mime)
{
    const QString name = mime.name();

    if (name.startsWith(u"image/"))
        return Image;
    if (name.startsWith(u"audio/"))
        return Audio;
    if (name.startsWith(u"video/"))
        return Video;

    static const QStringList documents = {
        "application/pdf", "application/rtf",
        "application/epub+zip", "application/msword",
        "application/vnd.oasis.opendocument.text",
        "application/vnd.oasis.opendocument.spreadsheet",
        "application/vnd.oasis.opendocument.presentation",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    };
    if (name == u"text/plain" || name == u"text/markdown" || inheritsAny(mime, documents))
        return Document;

    static const QStringList archives = {
        "application/zip", "application/x-tar", "application/gzip", "application/x-bzip2",
        "application/x-xz", "application/zstd", "application/x-7z-compressed",
        "application/vnd.rar", "application/x-cpio", "application/x-archive",
    };
    if (inheritsAny(mime, archives))
        return Archive;

    if (mime.inherits("text/plain"))
        return Code;

    return Other;
}

QString iconName(Kind kind)
{
    switch (kind) {
    case Folder:
        return "folder";
    case Image:
        return "image";
    case Document:
        return "description";
    case Code:
        return "data_object";
    case Archive:
        return "folder_zip";
    case Audio:
        return "music_note";
    case Video:
        return "movie";
    case Other:
        break;
    }
    return "draft";
}

}
