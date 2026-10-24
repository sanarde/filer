#include "FileClipboard.h"

#include <QClipboard>
#include <QGuiApplication>
#include <QMimeData>
#include <QUrl>

namespace {

constexpr auto gnomeFormat = "x-special/gnome-copied-files";

}

FileClipboard::FileClipboard(QObject *parent)
    : QObject(parent)
{
    connect(QGuiApplication::clipboard(), &QClipboard::dataChanged, this, &FileClipboard::changed);
}

QStringList FileClipboard::paths() const
{
    const QMimeData *data = QGuiApplication::clipboard()->mimeData();
    if (!data)
        return {};

    QStringList result;
    for (const QUrl &url : data->urls()) {
        if (url.isLocalFile())
            result.append(url.toLocalFile());
    }
    return result;
}

bool FileClipboard::cut() const
{
    const QMimeData *data = QGuiApplication::clipboard()->mimeData();
    return data && data->hasFormat(gnomeFormat) && data->data(gnomeFormat).startsWith("cut");
}

void FileClipboard::set(const QStringList &paths, bool cut)
{
    QList<QUrl> urls;
    QByteArray gnome = cut ? "cut" : "copy";
    for (const QString &path : paths) {
        const QUrl url = QUrl::fromLocalFile(path);
        urls.append(url);
        gnome += '\n' + url.toEncoded();
    }

    auto *data = new QMimeData;
    data->setUrls(urls);
    data->setText(paths.join(u'\n'));
    data->setData(gnomeFormat, gnome);
    QGuiApplication::clipboard()->setMimeData(data);
}

void FileClipboard::clear()
{
    QGuiApplication::clipboard()->clear();
}
