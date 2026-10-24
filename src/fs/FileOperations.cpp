#include "FileOperations.h"

#include "TransferJob.h"
#include "Trash.h"

#include <libintl.h>

#include <QDir>
#include <QFileInfo>
#include <QThread>

FileOperations::FileOperations(QObject *parent)
    : QObject(parent)
{
}

FileOperations::~FileOperations()
{
    if (m_thread) {
        m_job->cancel();
        m_thread->wait();
    }
}

QStringList FileOperations::conflicts(const QStringList &sources, const QString &target) const
{
    QStringList result;
    for (const QString &source : sources) {
        const QString name = QFileInfo(source).fileName();
        const QFileInfo destination(QDir(target).filePath(name));
        if ((destination.exists() || destination.isSymLink()) && destination.absoluteFilePath() != QFileInfo(source).absoluteFilePath())
            result.append(name);
    }
    return result;
}

void FileOperations::copy(const QStringList &sources, const QString &target, Conflict conflict)
{
    start(std::make_unique<TransferJob>(sources, target, TransferJob::Copy, static_cast<TransferJob::Conflict>(conflict)), Copy);
}

void FileOperations::move(const QStringList &sources, const QString &target, Conflict conflict)
{
    start(std::make_unique<TransferJob>(sources, target, TransferJob::Move, static_cast<TransferJob::Conflict>(conflict)), Move);
}

void FileOperations::trash(const QStringList &sources)
{
    auto job = std::make_unique<TransferJob>(sources, Trash::filesDirectory(), TransferJob::Move, TransferJob::KeepBoth);
    job->setDestination([](const QString &source) { return Trash::filesDirectory() + u'/' + Trash::reserveName(source); });
    start(std::move(job), Trash);
}

void FileOperations::restore(const QStringList &sources)
{
    auto job = std::make_unique<TransferJob>(sources, Trash::filesDirectory(), TransferJob::Move, TransferJob::KeepBoth);
    job->setDestination([](const QString &source) {
        const QString original = Trash::originalPath(source);
        const QString destination = original.isEmpty() ? QDir::homePath() + u'/' + QFileInfo(source).fileName() : original;
        QDir().mkpath(QFileInfo(destination).path());
        return destination;
    });
    start(std::move(job), Restore);
}

void FileOperations::remove(const QStringList &sources)
{
    start(std::make_unique<TransferJob>(sources, QString(), TransferJob::Remove, TransferJob::Replace), Remove);
}

static QString message(const char *msgid)
{
    return QString::fromUtf8(dgettext("sanar-filer", msgid));
}

static QString nameError(const QString &directory, const QString &name)
{
    if (name.isEmpty() || name == "." || name == "..")
        return message("The name is not valid");
    if (name.contains(u'/'))
        return message("The name cannot contain /");
    const QFileInfo existing(QDir(directory).filePath(name));
    if (existing.exists() || existing.isSymLink())
        return message("An item with this name already exists");
    return QString();
}

QString FileOperations::rename(const QString &path, const QString &name)
{
    const QFileInfo info(path);
    if (name == info.fileName())
        return QString();
    const QString error = nameError(info.absolutePath(), name);
    if (!error.isEmpty())
        return error;
    if (!QDir().rename(path, info.dir().filePath(name)))
        return message("Cannot rename %1").arg(info.fileName());
    return QString();
}

QString FileOperations::createFolder(const QString &directory, const QString &name)
{
    const QString error = nameError(directory, name);
    if (!error.isEmpty())
        return error;
    if (!QDir(directory).mkdir(name))
        return message("Cannot create folder %1").arg(name);
    return QString();
}

void FileOperations::cancel()
{
    if (m_job)
        m_job->cancel();
}

void FileOperations::start(std::unique_ptr<TransferJob> job, Kind kind)
{
    if (m_busy) {
        m_queue.push_back({std::move(job), kind});
        emit queuedChanged();
        return;
    }
    launch(std::move(job), kind);
}

void FileOperations::launch(std::unique_ptr<TransferJob> job, Kind kind)
{
    m_job = std::move(job);
    m_job->setProgress([this](qint64 done, qint64 total, const QString &name) {
        QMetaObject::invokeMethod(this, [this, done, total, name] {
            m_progress = total > 0 ? double(done) / total : 0;
            m_currentName = name;
            emit progressChanged();
        }, Qt::QueuedConnection);
    });

    m_busy = true;
    m_kind = kind;
    m_progress = 0;
    m_currentName.clear();
    emit busyChanged();
    emit progressChanged();

    TransferJob *running = m_job.get();
    m_thread = QThread::create([this, running] {
        const bool success = running->run();
        const QString error = running->canceled() ? QString() : running->error();
        QMetaObject::invokeMethod(this, [this, success, error] {
            m_thread->wait();
            m_thread->deleteLater();
            m_thread = nullptr;
            m_job.reset();
            Trash::pruneOrphans();
            if (success && !m_queue.empty()) {
                Pending next = std::move(m_queue.front());
                m_queue.pop_front();
                emit queuedChanged();
                launch(std::move(next.job), next.kind);
                return;
            }
            if (!m_queue.empty()) {
                m_queue.clear();
                emit queuedChanged();
            }
            m_busy = false;
            emit busyChanged();
            emit finished(success, error);
        }, Qt::QueuedConnection);
    });
    m_thread->start();
}
