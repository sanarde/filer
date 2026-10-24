#include "DirectoryModel.h"

#include <QDir>
#include <QDirListing>
#include <QFileInfo>
#include <QMimeDatabase>

#include <algorithm>

#include "SizeFormat.h"

DirectoryModel::DirectoryModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_collator.setNumericMode(true);
    m_collator.setCaseSensitivity(Qt::CaseInsensitive);

    m_reloadTimer.setSingleShot(true);
    m_reloadTimer.setInterval(100);
    connect(&m_reloadTimer, &QTimer::timeout, this, &DirectoryModel::load);
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, &m_reloadTimer,
            qOverload<>(&QTimer::start));
}

int DirectoryModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_rows.size();
}

QVariant DirectoryModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid))
        return {};

    const Entry &entry = m_rows.at(index.row());
    const bool isDir = entry.kind == FileKinds::Folder;

    switch (role) {
    case Qt::DisplayRole:
    case NameRole:
        return entry.name;
    case PathRole:
        return entry.path;
    case IsDirectoryRole:
        return isDir;
    case KindRole:
        return entry.kind;
    case SizeRole:
        return entry.size;
    case SizeTextRole:
        return isDir ? QString() : formatSize(entry.size);
    case ModifiedRole:
        return entry.modified;
    case TypeLabelRole:
        return entry.suffix.toUpper();
    case ItemCountRole:
        return isDir ? countItems(entry.path) : -1;
    }
    return {};
}

QHash<int, QByteArray> DirectoryModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {PathRole, "path"},
        {IsDirectoryRole, "isDirectory"},
        {KindRole, "kind"},
        {SizeRole, "size"},
        {SizeTextRole, "sizeText"},
        {ModifiedRole, "modified"},
        {TypeLabelRole, "typeLabel"},
        {ItemCountRole, "itemCount"},
    };
}

void DirectoryModel::setPath(const QString &path)
{
    const QString clean = path.isEmpty() ? QString() : QDir::cleanPath(QDir(path).absolutePath());
    if (m_path == clean)
        return;

    if (!m_watcher.directories().isEmpty())
        m_watcher.removePaths(m_watcher.directories());
    m_path = clean;
    emit pathChanged();
    load();
}

void DirectoryModel::setSortKey(SortKey key)
{
    if (m_sortKey == key)
        return;
    m_sortKey = key;
    emit sortChanged();
    rebuild();
}

void DirectoryModel::setSortDescending(bool descending)
{
    if (m_sortDescending == descending)
        return;
    m_sortDescending = descending;
    emit sortChanged();
    rebuild();
}

void DirectoryModel::setFilter(Filter filter)
{
    if (m_filter == filter)
        return;
    m_filter = filter;
    emit filterChanged();
    rebuild();
}

void DirectoryModel::setShowHidden(bool show)
{
    if (m_showHidden == show)
        return;
    m_showHidden = show;
    emit showHiddenChanged();
    load();
}

QString DirectoryModel::totalSizeText() const
{
    return formatSize(m_totalSize);
}

void DirectoryModel::load()
{
    m_all.clear();
    m_itemCounts.clear();

    const QFileInfo dir(m_path);
    if (m_path.isEmpty()) {
        setError(NoError);
    } else if (!dir.isDir()) {
        setError(NotFound);
    } else if (!dir.isReadable()) {
        setError(AccessDenied);
    } else {
        setError(NoError);
        if (!m_watcher.directories().contains(m_path))
            m_watcher.addPath(m_path);

        QDirListing::IteratorFlags flags;
        if (m_showHidden)
            flags |= QDirListing::IteratorFlag::IncludeHidden;

        QMimeDatabase mimeDb;
        for (const auto &item : QDirListing(m_path, flags)) {
            const QFileInfo info = item.fileInfo();
            Entry entry;
            entry.name = info.fileName();
            entry.path = info.filePath();
            entry.modified = info.lastModified();
            if (info.isDir()) {
                entry.kind = FileKinds::Folder;
            } else {
                entry.size = info.size();
                entry.suffix = info.suffix();
                entry.kind = FileKinds::kindOf(
                    mimeDb.mimeTypeForFile(info, QMimeDatabase::MatchExtension));
            }
            m_all.append(entry);
        }
    }

    rebuild();
}

void DirectoryModel::rebuild()
{
    QList<Entry> rows;
    for (const Entry &entry : std::as_const(m_all)) {
        if (accepts(entry))
            rows.append(entry);
    }
    std::sort(rows.begin(), rows.end(),
              [this](const Entry &a, const Entry &b) { return lessThan(a, b); });

    int folders = 0;
    qint64 total = 0;
    for (const Entry &entry : std::as_const(rows)) {
        if (entry.kind == FileKinds::Folder)
            ++folders;
        else
            total += entry.size;
    }

    beginResetModel();
    m_rows = std::move(rows);
    m_folderCount = folders;
    m_totalSize = total;
    endResetModel();
    emit totalsChanged();
}

bool DirectoryModel::accepts(const Entry &entry) const
{
    switch (m_filter) {
    case ShowAll:
        return true;
    case ShowFolders:
        return entry.kind == FileKinds::Folder;
    case ShowImages:
        return entry.kind == FileKinds::Image;
    case ShowDocuments:
        return entry.kind == FileKinds::Document;
    case ShowCode:
        return entry.kind == FileKinds::Code;
    case ShowArchives:
        return entry.kind == FileKinds::Archive;
    }
    return true;
}

bool DirectoryModel::lessThan(const Entry &a, const Entry &b) const
{
    const bool aDir = a.kind == FileKinds::Folder;
    const bool bDir = b.kind == FileKinds::Folder;
    if (aDir != bDir)
        return aDir;

    int result = 0;
    switch (m_sortKey) {
    case SortByName:
        break;
    case SortByModified:
        result = a.modified < b.modified ? -1 : (a.modified > b.modified ? 1 : 0);
        break;
    case SortBySize:
        result = a.size < b.size ? -1 : (a.size > b.size ? 1 : 0);
        break;
    case SortByType:
        result = m_collator.compare(a.suffix, b.suffix);
        break;
    }
    if (result != 0)
        return m_sortDescending ? result > 0 : result < 0;

    const int byName = m_collator.compare(a.name, b.name);
    return m_sortDescending && m_sortKey == SortByName ? byName > 0 : byName < 0;
}

int DirectoryModel::countItems(const QString &dirPath) const
{
    const auto it = m_itemCounts.constFind(dirPath);
    if (it != m_itemCounts.constEnd())
        return *it;

    QDirListing::IteratorFlags flags;
    if (m_showHidden)
        flags |= QDirListing::IteratorFlag::IncludeHidden;
    int count = 0;
    for (const auto &item : QDirListing(dirPath, flags)) {
        Q_UNUSED(item)
        ++count;
    }
    m_itemCounts.insert(dirPath, count);
    return count;
}

void DirectoryModel::setError(Error error)
{
    if (m_error == error)
        return;
    m_error = error;
    emit errorChanged();
}
