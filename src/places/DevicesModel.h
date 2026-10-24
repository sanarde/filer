#pragma once

#include <QAbstractListModel>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

#include "Udisks.h"

class DevicesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Role {
        LabelRole = Qt::UserRole + 1,
        IconRole,
        PathRole,
        UsedTextRole,
        UsedFractionRole,
        PrimaryRole,
        MountedRole,
        EjectableRole,
    };

    explicit DevicesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void mount(int row);
    Q_INVOKABLE void eject(int row);

signals:
    void mountReady(const QString &path);
    void failed(const QString &error);

private:
    struct Device {
        QString label;
        QString icon;
        QString path;
        QString deviceNode;
        QString block;
        bool mounted = true;
        bool ejectable = false;
        qint64 total = 0;
        qint64 used = 0;

        bool operator==(const Device &other) const = default;
    };

    QList<Device> scan() const;
    void refresh();

    QList<UdisksBlock> m_blocks;
    QList<Device> m_devices;
    Udisks m_udisks;
    QTimer m_timer;
};
