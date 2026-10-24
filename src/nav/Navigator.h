#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

class Navigator : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString path READ path NOTIFY changed FINAL)
    Q_PROPERTY(bool canGoBack READ canGoBack NOTIFY changed FINAL)
    Q_PROPERTY(bool canGoForward READ canGoForward NOTIFY changed FINAL)
    Q_PROPERTY(bool canGoUp READ canGoUp NOTIFY changed FINAL)
    Q_PROPERTY(QVariantList crumbs READ crumbs NOTIFY changed FINAL)

public:
    explicit Navigator(QObject *parent = nullptr);

    QString path() const { return m_path; }
    bool canGoBack() const { return !m_back.isEmpty(); }
    bool canGoForward() const { return !m_forward.isEmpty(); }
    bool canGoUp() const;
    QVariantList crumbs() const;

    Q_INVOKABLE void goTo(const QString &path);
    Q_INVOKABLE void back();
    Q_INVOKABLE void forward();
    Q_INVOKABLE void up();
    Q_INVOKABLE void open(const QString &path);

signals:
    void changed();

private:
    QString m_path;
    QStringList m_back;
    QStringList m_forward;
};
