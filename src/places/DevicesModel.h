#pragma once

#include <QAbstractListModel>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

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
    };

    explicit DevicesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    struct Device {
        QString label;
        QString icon;
        QString path;
        QString deviceNode;
        qint64 total = 0;
        qint64 used = 0;

        bool operator==(const Device &other) const = default;
    };

    static QList<Device> scan();
    void refresh();

    QList<Device> m_devices;
    QTimer m_timer;
};
