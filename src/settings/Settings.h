#pragma once

#include <QObject>
#include <QSocketNotifier>
#include <QtQml/qqmlregistration.h>

#include <cfgd/cfgd.h>

#include "DirectoryModel.h"
#include "Theme.h"

class Settings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(Theme::Mode themeMode READ themeMode WRITE setThemeMode NOTIFY themeModeChanged FINAL)
    Q_PROPERTY(QString palette READ palette WRITE setPalette NOTIFY paletteChanged FINAL)
    Q_PROPERTY(bool showHidden READ showHidden WRITE setShowHidden NOTIFY showHiddenChanged FINAL)
    Q_PROPERTY(bool separateFolders READ separateFolders WRITE setSeparateFolders NOTIFY separateFoldersChanged FINAL)
    Q_PROPERTY(bool detailsPanel READ detailsPanel WRITE setDetailsPanel NOTIFY detailsPanelChanged FINAL)
    Q_PROPERTY(DirectoryModel::SortKey sortKey READ sortKey WRITE setSortKey NOTIFY sortKeyChanged FINAL)
    Q_PROPERTY(bool sortDescending READ sortDescending WRITE setSortDescending NOTIFY sortDescendingChanged FINAL)
    Q_PROPERTY(QString viewMode READ viewMode WRITE setViewMode NOTIFY viewModeChanged FINAL)

public:
    explicit Settings(QObject *parent = nullptr);
    ~Settings() override;

    Theme::Mode themeMode() const { return m_themeMode; }
    void setThemeMode(Theme::Mode mode);
    QString palette() const { return m_palette; }
    void setPalette(const QString &palette);
    bool showHidden() const { return m_showHidden; }
    void setShowHidden(bool show);
    bool separateFolders() const { return m_separateFolders; }
    void setSeparateFolders(bool separate);
    bool detailsPanel() const { return m_detailsPanel; }
    void setDetailsPanel(bool enabled);
    DirectoryModel::SortKey sortKey() const { return m_sortKey; }
    void setSortKey(DirectoryModel::SortKey key);
    bool sortDescending() const { return m_sortDescending; }
    void setSortDescending(bool descending);
    QString viewMode() const { return m_viewMode; }
    void setViewMode(const QString &mode);

signals:
    void themeModeChanged();
    void paletteChanged();
    void showHiddenChanged();
    void separateFoldersChanged();
    void detailsPanelChanged();
    void sortKeyChanged();
    void sortDescendingChanged();
    void viewModeChanged();

private:
    static void keyChanged(const char *key, void *user);
    void dispatch();
    void reload(const QString &name);
    bool readBool(const char *name, bool fallback) const;
    QString readString(const char *name, const QString &fallback) const;
    Theme::Mode readThemeMode() const;
    DirectoryModel::SortKey readSortKey() const;
    QString readViewMode() const;
    void writeBool(const char *name, bool value);
    void writeString(const char *name, const QString &value);

    cfgd_t *m_cfgd = nullptr;
    QSocketNotifier *m_notifier = nullptr;
    Theme::Mode m_themeMode;
    QString m_palette;
    bool m_showHidden;
    bool m_separateFolders;
    bool m_detailsPanel;
    DirectoryModel::SortKey m_sortKey;
    bool m_sortDescending;
    QString m_viewMode;
};
