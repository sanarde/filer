#include "Navigator.h"

#include <QDir>
#include <QVariantMap>

Navigator::Navigator(QObject *parent)
    : QObject(parent)
    , m_path(QDir::cleanPath(QDir::homePath()))
{
}

bool Navigator::canGoUp() const
{
    return m_path != QDir::rootPath();
}

QVariantList Navigator::crumbs() const
{
    const QString home = QDir::cleanPath(QDir::homePath());
    const bool underHome = m_path == home || m_path.startsWith(home + u'/');
    const QString base = underHome ? home : QDir::rootPath();

    QVariantList result;
    result.append(QVariantMap{
        {"label", underHome ? QString() : base},
        {"path", base},
        {"isHome", underHome},
    });

    QString current = base;
    const QStringList parts = m_path.mid(base.size()).split(u'/', Qt::SkipEmptyParts);
    for (const QString &part : parts) {
        current = QDir::cleanPath(current + u'/' + part);
        result.append(QVariantMap{
            {"label", part},
            {"path", current},
            {"isHome", false},
        });
    }
    return result;
}

void Navigator::goTo(const QString &path)
{
    const QString clean = QDir::cleanPath(QDir(path).absolutePath());
    if (clean == m_path)
        return;

    m_back.append(m_path);
    m_forward.clear();
    m_path = clean;
    emit changed();
}

void Navigator::back()
{
    if (m_back.isEmpty())
        return;

    m_forward.append(m_path);
    m_path = m_back.takeLast();
    emit changed();
}

void Navigator::forward()
{
    if (m_forward.isEmpty())
        return;

    m_back.append(m_path);
    m_path = m_forward.takeLast();
    emit changed();
}

void Navigator::up()
{
    if (!canGoUp())
        return;

    QDir dir(m_path);
    dir.cdUp();
    goTo(dir.path());
}
