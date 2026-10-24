#pragma once

#include <QAbstractListModel>
#include <QCollator>
#include <QDateTime>
#include <QFileSystemWatcher>
#include <QFutureWatcher>
#include <QFileInfo>
#include <QHash>
#include <QMimeDatabase>
#include <QSet>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

#include "FileKind.h"

class DirectoryModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
    Q_PROPERTY(Error error READ error NOTIFY errorChanged FINAL)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged FINAL)
    Q_PROPERTY(SortKey sortKey READ sortKey WRITE setSortKey NOTIFY sortChanged FINAL)
    Q_PROPERTY(bool sortDescending READ sortDescending WRITE setSortDescending NOTIFY sortChanged FINAL)
    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged FINAL)
    Q_PROPERTY(Filter filter READ filter WRITE setFilter NOTIFY filterChanged FINAL)
    Q_PROPERTY(bool foldersFirst READ foldersFirst WRITE setFoldersFirst NOTIFY foldersFirstChanged FINAL)
    Q_PROPERTY(bool showHidden READ showHidden WRITE setShowHidden NOTIFY showHiddenChanged FINAL)
    Q_PROPERTY(int folderCount READ folderCount NOTIFY totalsChanged FINAL)
    Q_PROPERTY(int fileCount READ fileCount NOTIFY totalsChanged FINAL)
    Q_PROPERTY(qint64 totalSize READ totalSize NOTIFY totalsChanged FINAL)
    Q_PROPERTY(QString totalSizeText READ totalSizeText NOTIFY totalsChanged FINAL)
    Q_PROPERTY(int selectedCount READ selectedCount NOTIFY selectionChanged FINAL)
    Q_PROPERTY(qint64 selectedSize READ selectedSize NOTIFY selectionChanged FINAL)
    Q_PROPERTY(QString selectedSizeText READ selectedSizeText NOTIFY selectionChanged FINAL)
    Q_PROPERTY(QString selectedPath READ selectedPath NOTIFY selectionChanged FINAL)

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
        SelectedRole,
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

    enum SelectMode {
        SelectReplace,
        SelectClick,
        SelectToggle,
        SelectRange,
    };
    Q_ENUM(SelectMode)

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
    QString nameFilter() const { return m_nameFilter; }
    void setNameFilter(const QString &text);
    bool loading() const { return m_loading; }
    bool foldersFirst() const { return m_foldersFirst; }
    void setFoldersFirst(bool first);
    bool showHidden() const { return m_showHidden; }
    void setShowHidden(bool show);
    int folderCount() const { return m_folderCount; }
    int fileCount() const { return m_rows.size() - m_folderCount; }
    qint64 totalSize() const { return m_totalSize; }
    QString totalSizeText() const;
    int selectedCount() const { return m_selected.size(); }
    qint64 selectedSize() const;
    QString selectedSizeText() const;
    QString selectedPath() const { return m_selected.size() == 1 ? *m_selected.constBegin() : QString(); }

    Q_INVOKABLE void select(const QString &path, SelectMode mode);
    Q_INVOKABLE int move(int dx, int dy, int columns, bool sectioned, bool extend);
    Q_INVOKABLE void reload();
    Q_INVOKABLE void selectPaths(const QStringList &paths);
    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void clearSelection();
    Q_INVOKABLE QStringList selectedPaths() const;

signals:
    void pathChanged();
    void errorChanged();
    void loadingChanged();
    void sortChanged();
    void filterChanged();
    void nameFilterChanged();
    void foldersFirstChanged();
    void showHiddenChanged();
    void totalsChanged();
    void selectionChanged();

private:
    struct Entry {
        QString name;
        QString path;
        QString suffix;
        QDateTime modified;
        QDateTime visited;
        qint64 size = 0;
        FileKinds::Kind kind = FileKinds::Other;
    };

    struct ScanResult {
        Error error = NoError;
        QList<Entry> entries;
    };

    static Entry makeEntry(const QFileInfo &info, const QMimeDatabase &mimeDb);
    static ScanResult scan(const QString &path, bool showHidden);
    void load();
    void apply();
    void rebuild();
    bool accepts(const Entry &entry) const;
    bool lessThan(const Entry &a, const Entry &b) const;
    int countItems(const QString &dirPath) const;
    void setError(Error error);
    void setSelection(const QSet<QString> &selection);
    int rowOf(const QString &path) const;

    QString m_path;
    Error m_error = NoError;
    SortKey m_sortKey = SortByName;
    bool m_sortDescending = false;
    Filter m_filter = ShowAll;
    QString m_nameFilter;
    bool m_foldersFirst = true;
    bool m_showHidden = false;
    bool m_loading = false;
    QList<Entry> m_all;
    QList<Entry> m_rows;
    QSet<QString> m_selected;
    QString m_anchor;
    QString m_cursor;
    int m_folderCount = 0;
    qint64 m_totalSize = 0;
    mutable QHash<QString, int> m_itemCounts;
    QCollator m_collator;
    QFutureWatcher<ScanResult> m_scan;
    QFileSystemWatcher m_watcher;
    QTimer m_reloadTimer;
};
