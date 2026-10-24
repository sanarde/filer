#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class Translator : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(Tr)
    QML_SINGLETON

public:
    explicit Translator(QObject *parent = nullptr);

    Q_INVOKABLE QString t(const QString &msgid) const;
    Q_INVOKABLE QString n(const QString &singular, const QString &plural, int count) const;
};
