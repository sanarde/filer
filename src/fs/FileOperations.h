#pragma once

#include <QObject>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

#include <deque>
#include <memory>

class QThread;
class TransferJob;

class FileOperations : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged FINAL)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged FINAL)
    Q_PROPERTY(QString currentName READ currentName NOTIFY progressChanged FINAL)
    Q_PROPERTY(int queued READ queued NOTIFY queuedChanged FINAL)
    Q_PROPERTY(Kind kind READ kind NOTIFY busyChanged FINAL)

public:
    enum Conflict { Replace, Skip, KeepBoth };
    Q_ENUM(Conflict)
    enum Kind { Copy, Move, Trash, Restore, Remove };
    Q_ENUM(Kind)

    explicit FileOperations(QObject *parent = nullptr);
    ~FileOperations() override;

    bool busy() const { return m_busy; }
    double progress() const { return m_progress; }
    QString currentName() const { return m_currentName; }
    int queued() const { return int(m_queue.size()); }
    Kind kind() const { return m_kind; }

    Q_INVOKABLE QStringList conflicts(const QStringList &sources, const QString &target) const;
    Q_INVOKABLE void copy(const QStringList &sources, const QString &target, Conflict conflict);
    Q_INVOKABLE void move(const QStringList &sources, const QString &target, Conflict conflict);
    Q_INVOKABLE void trash(const QStringList &sources);
    Q_INVOKABLE void restore(const QStringList &sources);
    Q_INVOKABLE void remove(const QStringList &sources);
    Q_INVOKABLE QString rename(const QString &path, const QString &name);
    Q_INVOKABLE QString createFolder(const QString &directory, const QString &name);
    Q_INVOKABLE void cancel();

signals:
    void busyChanged();
    void queuedChanged();
    void progressChanged();
    void finished(bool success, const QString &error);

private:
    void start(std::unique_ptr<TransferJob> job, Kind kind);
    void launch(std::unique_ptr<TransferJob> job, Kind kind);

    struct Pending {
        std::unique_ptr<TransferJob> job;
        Kind kind;
    };

    std::unique_ptr<TransferJob> m_job;
    std::deque<Pending> m_queue;
    QThread *m_thread = nullptr;
    bool m_busy = false;
    Kind m_kind = Copy;
    double m_progress = 0;
    QString m_currentName;
};
