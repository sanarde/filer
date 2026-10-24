#pragma once

#include <QObject>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

class FileClipboard : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QStringList paths READ paths NOTIFY changed FINAL)
    Q_PROPERTY(bool cut READ cut NOTIFY changed FINAL)

public:
    explicit FileClipboard(QObject *parent = nullptr);

    QStringList paths() const;
    bool cut() const;

    Q_INVOKABLE void set(const QStringList &paths, bool cut);
    Q_INVOKABLE void clear();

signals:
    void changed();
};
