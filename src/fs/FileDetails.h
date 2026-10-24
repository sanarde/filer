#pragma once

#include <QDateTime>
#include <QObject>
#include <QtQml/qqmlregistration.h>

#include "FileKind.h"

class FileDetails : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY changed FINAL)
    Q_PROPERTY(QString name READ name NOTIFY changed FINAL)
    Q_PROPERTY(QString description READ description NOTIFY changed FINAL)
    Q_PROPERTY(QString suffix READ suffix NOTIFY changed FINAL)
    Q_PROPERTY(QString icon READ icon NOTIFY changed FINAL)
    Q_PROPERTY(FileKinds::Kind kind READ kind NOTIFY changed FINAL)
    Q_PROPERTY(QString sizeText READ sizeText NOTIFY changed FINAL)
    Q_PROPERTY(QString modifiedText READ modifiedText NOTIFY changed FINAL)
    Q_PROPERTY(QString createdText READ createdText NOTIFY changed FINAL)
    Q_PROPERTY(QString permissionsText READ permissionsText NOTIFY changed FINAL)
    Q_PROPERTY(QString mimeText READ mimeText NOTIFY changed FINAL)
    Q_PROPERTY(QString ownerText READ ownerText NOTIFY changed FINAL)
    Q_PROPERTY(QString pathText READ pathText NOTIFY changed FINAL)
    Q_PROPERTY(QString locationText READ locationText NOTIFY changed FINAL)

public:
    explicit FileDetails(QObject *parent = nullptr);

    QString path() const { return m_path; }
    void setPath(const QString &path);
    QString name() const { return m_name; }
    QString description() const { return m_description; }
    QString suffix() const { return m_suffix; }
    QString icon() const { return m_icon; }
    FileKinds::Kind kind() const { return m_kind; }
    QString sizeText() const { return m_sizeText; }
    QString modifiedText() const { return m_modifiedText; }
    QString createdText() const { return m_createdText; }
    QString permissionsText() const { return m_permissionsText; }
    QString locationText() const { return m_locationText; }
    QString mimeText() const { return m_mimeText; }
    QString ownerText() const { return m_ownerText; }
    QString pathText() const { return m_pathText; }

signals:
    void changed();

private:
    void load();

    QString m_path;
    QString m_name;
    QString m_description;
    QString m_suffix;
    QString m_icon;
    FileKinds::Kind m_kind = FileKinds::Other;
    QString m_sizeText;
    QString m_modifiedText;
    QString m_createdText;
    QString m_permissionsText;
    QString m_locationText;
    QString m_mimeText;
    QString m_ownerText;
    QString m_pathText;
};
