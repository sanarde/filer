#pragma once

#include <QDBusMessage>
#include <QList>
#include <QObject>
#include <QString>
#include <QTimer>

#include <functional>

struct UdisksBlock {
    QString path;
    QString device;
    QString label;
    qint64 size = 0;
    QString drive;
    bool system = false;
    bool mounted = false;
    bool ejectable = false;
    bool canPowerOff = false;
};

class Udisks : public QObject
{
    Q_OBJECT

public:
    explicit Udisks(QObject *parent = nullptr);

    void fetch();
    void mount(const QString &block);
    void eject(const QString &block);

signals:
    void blocksChanged(const QList<UdisksBlock> &blocks);
    void mountReady(const QString &path);
    void failed(const QString &error);

private slots:
    void scheduleFetch();

private:
    void call(const QString &path, const QString &interface, const QString &method,
              const std::function<void(const QDBusMessage &)> &done);
    void release(const UdisksBlock &block);

    QList<UdisksBlock> m_blocks;
    QTimer m_debounce;
};
