#include "Thumbnailers.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QMimeDatabase>
#include <QMimeType>
#include <QProcess>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QUrl>

namespace {

struct Thumbnailer {
    QString tryExec;
    QString exec;
};

QHash<QString, Thumbnailer> loadThumbnailers()
{
    QStringList directories;
    const QStringList data = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    for (auto it = data.crbegin(); it != data.crend(); ++it)
        directories.append(*it + "/thumbnailers");

    QHash<QString, Thumbnailer> result;
    for (const QString &directory : std::as_const(directories)) {
        const QStringList files = QDir(directory).entryList({"*.thumbnailer"}, QDir::Files, QDir::Name);
        for (const QString &name : files) {
            QFile file(directory + u'/' + name);
            if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
                continue;
            Thumbnailer thumbnailer;
            QStringList types;
            bool inEntry = false;
            while (!file.atEnd()) {
                const QString line = QString::fromUtf8(file.readLine()).trimmed();
                if (line.startsWith(u'[')) {
                    inEntry = line == "[Thumbnailer Entry]";
                    continue;
                }
                const qsizetype separator = line.indexOf(u'=');
                if (!inEntry || separator < 0)
                    continue;
                const QString key = line.left(separator).trimmed();
                const QString value = line.mid(separator + 1).trimmed();
                if (key == "TryExec")
                    thumbnailer.tryExec = value;
                else if (key == "Exec")
                    thumbnailer.exec = value;
                else if (key == "MimeType")
                    types = value.split(u';', Qt::SkipEmptyParts);
            }
            if (thumbnailer.exec.isEmpty())
                continue;
            for (const QString &type : types) {
                if (!type.isEmpty())
                    result.insert(type, thumbnailer);
            }
        }
    }
    return result;
}

const QHash<QString, Thumbnailer> &thumbnailers()
{
    static const QHash<QString, Thumbnailer> all = loadThumbnailers();
    return all;
}

bool available(const Thumbnailer &thumbnailer)
{
    if (thumbnailer.tryExec.isEmpty())
        return true;
    if (QDir::isAbsolutePath(thumbnailer.tryExec))
        return QFileInfo(thumbnailer.tryExec).isExecutable();
    return !QStandardPaths::findExecutable(thumbnailer.tryExec).isEmpty();
}

QStringList arguments(const Thumbnailer &thumbnailer, const QString &path, int size, const QString &output)
{
    QStringList result;
    const QStringList words = QProcess::splitCommand(thumbnailer.exec);
    for (QString word : words) {
        word.replace("%%", QChar(1));
        word.replace("%s", QString::number(size));
        word.replace("%u", QString::fromLatin1(QUrl::fromLocalFile(path).toEncoded()));
        word.replace("%i", path);
        word.replace("%o", output);
        word.replace(QChar(1), "%");
        result.append(word);
    }
    return result;
}

}

QImage Thumbnailers::generate(const QString &path, int size)
{
    const QMimeType mime = QMimeDatabase().mimeTypeForFile(path);
    QStringList types = {mime.name()};
    types.append(mime.aliases());
    types.append(mime.allAncestors());

    for (const QString &type : std::as_const(types)) {
        const auto found = thumbnailers().constFind(type);
        if (found == thumbnailers().constEnd() || !available(*found))
            continue;

        QTemporaryDir directory;
        if (!directory.isValid())
            return QImage();
        const QString output = directory.filePath("thumbnail.png");
        QStringList words = arguments(*found, path, size, output);
        if (words.isEmpty())
            return QImage();

        QProcess process;
        const QString program = words.takeFirst();
        process.setProgram(program);
        process.setArguments(words);
        process.setStandardOutputFile(QProcess::nullDevice());
        process.setStandardErrorFile(QProcess::nullDevice());
        process.start();
        if (!process.waitForFinished(20000)) {
            process.kill();
            process.waitForFinished();
            return QImage();
        }
        return QImage(output);
    }
    return QImage();
}
