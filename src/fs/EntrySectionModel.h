#pragma once

#include <QSortFilterProxyModel>
#include <QtQml/qqmlregistration.h>

class EntrySectionModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool directories READ directories WRITE setDirectories NOTIFY directoriesChanged FINAL)

public:
    explicit EntrySectionModel(QObject *parent = nullptr);

    bool directories() const { return m_directories; }
    void setDirectories(bool directories);

signals:
    void directoriesChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    bool m_directories = false;
};
