#pragma once

#include <QHash>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class Icons : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Icons(QObject *parent = nullptr);

    Q_INVOKABLE QString glyph(const QString &name) const;

private:
    QHash<QString, QString> m_glyphs;
};
