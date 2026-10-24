#include "TransferJob.h"

#include <libintl.h>

#include <QDir>
#include <QFile>
#include <QFileInfo>

#include <cerrno>
#include <cstdio>
#include <unistd.h>

static QString message(const char *msgid)
{
    return QString::fromUtf8(dgettext("sanar-filer", msgid));
}

static bool isLink(const QString &path)
{
    return QFileInfo(path).isSymLink();
}

static bool isRealDir(const QString &path)
{
    const QFileInfo info(path);
    return info.isDir() && !info.isSymLink();
}

static bool entryExists(const QString &path)
{
    return QFileInfo::exists(path) || isLink(path);
}

static qint64 sizeOf(const QString &path)
{
    if (!isRealDir(path))
        return isLink(path) ? 0 : QFileInfo(path).size();

    qint64 total = 0;
    const QDir dir(path);
    const QStringList names = dir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);
    for (const QString &name : names)
        total += sizeOf(dir.filePath(name));
    return total;
}

static bool removeEntry(const QString &path)
{
    if (isRealDir(path))
        return QDir(path).removeRecursively();
    return QFile::remove(path);
}

static QString uniquePath(const QString &directory, const QString &name)
{
    const QFileInfo info(name);
    const QString base = info.completeBaseName();
    const QString suffix = info.suffix().isEmpty() ? QString() : u'.' + info.suffix();
    for (int i = 2;; ++i) {
        const QString candidate = QStringLiteral("%1/%2 (%3)%4").arg(directory, base).arg(i).arg(suffix);
        if (!entryExists(candidate))
            return candidate;
    }
}

TransferJob::TransferJob(const QStringList &sources, const QString &target, Mode mode, Conflict conflict)
    : m_sources(sources)
    , m_target(QDir::cleanPath(target))
    , m_mode(mode)
    , m_move(mode == Move)
    , m_conflict(conflict)
{
}

bool TransferJob::fail(const QString &message)
{
    if (m_error.isEmpty())
        m_error = message;
    return false;
}

void TransferJob::advance(qint64 bytes, const QString &name)
{
    m_done += bytes;
    if (m_progress)
        m_progress(m_done, m_total, name);
}

bool TransferJob::run()
{
    for (const QString &source : m_sources)
        m_total += sizeOf(source);

    for (const QString &source : m_sources) {
        const QString path = QDir::cleanPath(source);
        if (!(m_mode == Remove ? erase(path) : transfer(path, m_target)))
            return false;
    }
    return true;
}

bool TransferJob::erase(const QString &path)
{
    if (m_cancel)
        return fail(message("Canceled"));

    if (isRealDir(path)) {
        const QDir dir(path);
        const QStringList names = dir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);
        for (const QString &name : names) {
            if (!erase(dir.filePath(name)))
                return false;
        }
        if (!QDir().rmdir(path))
            return fail(message("Cannot remove %1").arg(path));
        return true;
    }

    const qint64 size = sizeOf(path);
    if (!QFile::remove(path))
        return fail(message("Cannot remove %1").arg(path));
    advance(size, QFileInfo(path).fileName());
    return true;
}

bool TransferJob::transfer(const QString &source, const QString &directory)
{
    if (m_cancel)
        return fail(message("Canceled"));

    const QFileInfo info(source);
    const QString name = m_naming && directory == m_target ? m_naming(source) : info.fileName();
    QString destination = directory + u'/' + name;

    if (isRealDir(source)) {
        const QString canonicalSource = info.canonicalFilePath();
        const QString canonicalDirectory = QFileInfo(directory).canonicalFilePath();
        if (canonicalDirectory == canonicalSource || canonicalDirectory.startsWith(canonicalSource + u'/'))
            return fail(message("A folder cannot be copied into itself: %1").arg(name));
    }

    if (entryExists(destination)) {
        if (destination == source) {
            if (m_move)
                return true;
            destination = uniquePath(directory, name);
        } else if (m_conflict == Skip) {
            advance(sizeOf(source), name);
            return true;
        } else if (m_conflict == KeepBoth) {
            destination = uniquePath(directory, name);
        } else if (!(isRealDir(source) && isRealDir(destination))) {
            if (!removeEntry(destination))
                return fail(message("Cannot replace %1").arg(destination));
        }
    }

    if (isRealDir(source))
        return transferDirectory(source, destination);

    if (m_move && !entryExists(destination)) {
        if (::rename(QFile::encodeName(source).constData(), QFile::encodeName(destination).constData()) == 0) {
            advance(sizeOf(destination), name);
            return true;
        }
        if (errno != EXDEV)
            return fail(message("Cannot move %1").arg(source));
    }

    if (isLink(source)) {
        char buffer[4096];
        const ssize_t length = ::readlink(QFile::encodeName(source).constData(), buffer, sizeof(buffer));
        if (length < 0 || !QFile::link(QFile::decodeName(QByteArray(buffer, length)), destination))
            return fail(message("Cannot copy %1").arg(source));
    } else if (!copyFile(source, destination)) {
        return false;
    }

    if (m_move && !QFile::remove(source))
        return fail(message("Cannot remove %1").arg(source));
    return true;
}

bool TransferJob::transferDirectory(const QString &source, const QString &destination)
{
    if (m_move && !entryExists(destination)) {
        if (::rename(QFile::encodeName(source).constData(), QFile::encodeName(destination).constData()) == 0) {
            advance(sizeOf(destination), QFileInfo(source).fileName());
            return true;
        }
        if (errno != EXDEV)
            return fail(message("Cannot move %1").arg(source));
    }

    if (!QFileInfo(destination).isDir() && !QDir().mkdir(destination))
        return fail(message("Cannot create folder %1").arg(destination));

    const QDir dir(source);
    const QStringList names = dir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);
    for (const QString &name : names) {
        if (!transfer(dir.filePath(name), destination))
            return false;
    }

    QFile::setPermissions(destination, QFile::permissions(source));

    if (m_move && !QDir().rmdir(source))
        return fail(message("Cannot remove %1").arg(source));
    return true;
}

bool TransferJob::copyFile(const QString &source, const QString &destination)
{
    QFile in(source);
    if (!in.open(QIODevice::ReadOnly))
        return fail(message("Cannot read %1: %2").arg(source, in.errorString()));

    QFile out(destination);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return fail(message("Cannot write %1: %2").arg(destination, out.errorString()));

    const QString name = QFileInfo(source).fileName();
    QByteArray buffer(1 << 20, Qt::Uninitialized);
    while (true) {
        if (m_cancel) {
            out.close();
            QFile::remove(destination);
            return fail(message("Canceled"));
        }
        const qint64 count = in.read(buffer.data(), buffer.size());
        if (count < 0)
            return fail(message("Cannot read %1: %2").arg(source, in.errorString()));
        if (count == 0)
            break;
        if (out.write(buffer.constData(), count) != count) {
            const QString text = message("Cannot write %1: %2").arg(destination, out.errorString());
            out.close();
            QFile::remove(destination);
            return fail(text);
        }
        advance(count, name);
    }

    out.close();
    QFile::setPermissions(destination, in.permissions());
    return true;
}
