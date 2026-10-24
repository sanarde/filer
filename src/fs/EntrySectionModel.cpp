#include "EntrySectionModel.h"

#include "DirectoryModel.h"

EntrySectionModel::EntrySectionModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{
}

void EntrySectionModel::setDirectories(bool directories)
{
    if (m_directories == directories)
        return;
    m_directories = directories;
    emit directoriesChanged();
    invalidateRowsFilter();
}

bool EntrySectionModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
    return index.data(DirectoryModel::IsDirectoryRole).toBool() == m_directories;
}
