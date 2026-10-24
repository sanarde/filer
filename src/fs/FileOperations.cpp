#include "FileOperations.h"

#include "TransferJob.h"
#include "Trash.h"

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
    start(std::make_unique<TransferJob>(sources, target, TransferJob::Copy, static_cast<TransferJob::Conflict>(conflict)), false);
}

void FileOperations::move(const QStringList &sources, const QString &target, Conflict conflict)
{
    start(std::make_unique<TransferJob>(sources, target, TransferJob::Move, static_cast<TransferJob::Conflict>(conflict)), true);
}

void FileOperations::trash(const QStringList &sources)
{
    auto job = std::make_unique<TransferJob>(sources, Trash::filesDirectory(), TransferJob::Move, TransferJob::KeepBoth);
    job->setNaming(Trash::reserveName);
    start(std::move(job), true);
}

void FileOperations::remove(const QStringList &sources)
{
    start(std::make_unique<TransferJob>(sources, QString(), TransferJob::Remove, TransferJob::Replace), true);
}

void FileOperations::cancel()
{
    if (m_job)
        m_job->cancel();
}

void FileOperations::start(std::unique_ptr<TransferJob> job, bool moving)
{
    if (m_busy)
        return;

    m_job = std::move(job);
    m_job->setProgress([this](qint64 done, qint64 total, const QString &name) {
        QMetaObject::invokeMethod(this, [this, done, total, name] {
            m_progress = total > 0 ? double(done) / total : 0;
            m_currentName = name;
            emit progressChanged();
        }, Qt::QueuedConnection);
    });

    m_busy = true;
    m_moving = moving;
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
            m_busy = false;
            emit busyChanged();
            emit finished(success, error);
        }, Qt::QueuedConnection);
    });
    m_thread->start();
}
