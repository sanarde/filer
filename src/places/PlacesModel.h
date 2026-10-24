#pragma once

#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>

class PlacesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Role {
        LabelRole = Qt::UserRole + 1,
        IconRole,
        PathRole,
    };

    explicit PlacesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    struct Place {
        QString label;
        QString icon;
        QString path;
    };

    QList<Place> m_places;
};
