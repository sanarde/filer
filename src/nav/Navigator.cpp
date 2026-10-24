#include "Navigator.h"

#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QUrl>
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

static bool isWithin(const QString &path, const QString &base)
{
    return path == base || path.startsWith(base + u'/');
}

QVariantList Navigator::crumbs() const
{
    const QString home = QDir::cleanPath(QDir::homePath());
    const QString trash = QDir::cleanPath(
        QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/Trash/files");

    QString base = QDir::rootPath();
    QString root;
    if (isWithin(m_path, trash)) {
        base = trash;
        root = "trash";
    } else if (isWithin(m_path, home)) {
        base = home;
        root = "home";
    }

    QVariantList result;
    result.append(QVariantMap{
        {"label", root.isEmpty() ? base : QString()},
        {"path", base},
        {"root", root},
    });

    QString current = base;
    const QStringList parts = m_path.mid(base.size()).split(u'/', Qt::SkipEmptyParts);
    for (const QString &part : parts) {
        current = QDir::cleanPath(current + u'/' + part);
        result.append(QVariantMap{
            {"label", part},
            {"path", current},
            {"root", QString()},
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

void Navigator::open(const QString &path)
{
    if (QFileInfo(path).isDir())
        goTo(path);
    else
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
