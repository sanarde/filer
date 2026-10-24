#pragma once

#include <QString>
#include <QStringList>

#include <atomic>
#include <functional>

class TransferJob
{
public:
    enum Mode { Copy, Move, Remove };
    enum Conflict { Replace, Skip, KeepBoth };

    using Progress = std::function<void(qint64 done, qint64 total, const QString &name)>;
    using Naming = std::function<QString(const QString &source)>;

    TransferJob(const QStringList &sources, const QString &target, Mode mode, Conflict conflict);

    void setProgress(Progress progress) { m_progress = std::move(progress); }
    void setNaming(Naming naming) { m_naming = std::move(naming); }
    void cancel() { m_cancel = true; }
    bool run();
    QString error() const { return m_error; }
    bool canceled() const { return m_cancel; }

private:
    bool erase(const QString &path);
    bool transfer(const QString &source, const QString &directory);
    bool transferDirectory(const QString &source, const QString &destination);
    bool copyFile(const QString &source, const QString &destination);
    bool fail(const QString &message);
    void advance(qint64 bytes, const QString &name);

    QStringList m_sources;
    QString m_target;
    Mode m_mode;
    bool m_move;
    Conflict m_conflict;
    Progress m_progress;
    Naming m_naming;
    std::atomic_bool m_cancel{false};
    QString m_error;
    qint64 m_total = 0;
    qint64 m_done = 0;
};
