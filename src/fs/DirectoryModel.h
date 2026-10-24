#pragma once

#include <QAbstractListModel>
#include <QCollator>
#include <QDateTime>
#include <QFileSystemWatcher>
#include <QHash>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

#include "FileKind.h"

class DirectoryModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
    Q_PROPERTY(Error error READ error NOTIFY errorChanged FINAL)
    Q_PROPERTY(SortKey sortKey READ sortKey WRITE setSortKey NOTIFY sortChanged FINAL)
    Q_PROPERTY(bool sortDescending READ sortDescending WRITE setSortDescending NOTIFY sortChanged FINAL)
    Q_PROPERTY(Filter filter READ filter WRITE setFilter NOTIFY filterChanged FINAL)
    Q_PROPERTY(bool showHidden READ showHidden WRITE setShowHidden NOTIFY showHiddenChanged FINAL)
    Q_PROPERTY(int folderCount READ folderCount NOTIFY totalsChanged FINAL)
    Q_PROPERTY(int fileCount READ fileCount NOTIFY totalsChanged FINAL)
    Q_PROPERTY(qint64 totalSize READ totalSize NOTIFY totalsChanged FINAL)
    Q_PROPERTY(QString totalSizeText READ totalSizeText NOTIFY totalsChanged FINAL)

public:
    enum Role {
        NameRole = Qt::UserRole + 1,
        PathRole,
        IsDirectoryRole,
        KindRole,
        SizeRole,
        SizeTextRole,
        ModifiedRole,
        TypeLabelRole,
        ItemCountRole,
        IconRole,
    };

    enum SortKey {
        SortByName,
        SortByModified,
        SortBySize,
        SortByType,
    };
    Q_ENUM(SortKey)

    enum Filter {
        ShowAll,
        ShowFolders,
        ShowImages,
        ShowDocuments,
        ShowCode,
        ShowArchives,
    };
    Q_ENUM(Filter)

    enum Error {
        NoError,
        NotFound,
        AccessDenied,
    };
    Q_ENUM(Error)

    explicit DirectoryModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString path() const { return m_path; }
    void setPath(const QString &path);
    Error error() const { return m_error; }
    SortKey sortKey() const { return m_sortKey; }
    void setSortKey(SortKey key);
    bool sortDescending() const { return m_sortDescending; }
    void setSortDescending(bool descending);
    Filter filter() const { return m_filter; }
    void setFilter(Filter filter);
    bool showHidden() const { return m_showHidden; }
    void setShowHidden(bool show);
    int folderCount() const { return m_folderCount; }
    int fileCount() const { return m_rows.size() - m_folderCount; }
    qint64 totalSize() const { return m_totalSize; }
    QString totalSizeText() const;

signals:
    void pathChanged();
    void errorChanged();
    void sortChanged();
    void filterChanged();
    void showHiddenChanged();
    void totalsChanged();

private:
    struct Entry {
        QString name;
        QString path;
        QString suffix;
        QDateTime modified;
        qint64 size = 0;
        FileKinds::Kind kind = FileKinds::Other;
    };

    void load();
    void rebuild();
    bool accepts(const Entry &entry) const;
    bool lessThan(const Entry &a, const Entry &b) const;
    int countItems(const QString &dirPath) const;
    void setError(Error error);

    QString m_path;
    Error m_error = NoError;
    SortKey m_sortKey = SortByName;
    bool m_sortDescending = false;
    Filter m_filter = ShowAll;
    bool m_showHidden = false;
    QList<Entry> m_all;
    QList<Entry> m_rows;
    int m_folderCount = 0;
    qint64 m_totalSize = 0;
    mutable QHash<QString, int> m_itemCounts;
    QCollator m_collator;
    QFileSystemWatcher m_watcher;
    QTimer m_reloadTimer;
};
