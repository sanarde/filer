#include "FileDetails.h"

#include <libintl.h>

#include <QDir>
#include <QDirListing>
#include <QFileInfo>
#include <QImageReader>
#include <QLocale>
#include <QMimeDatabase>

#include "SizeFormat.h"

FileDetails::FileDetails(QObject *parent)
    : QObject(parent)
{
}

void FileDetails::setPath(const QString &path)
{
    if (m_path == path)
        return;
    m_path = path;
    load();
    emit changed();
}

static QString formatTime(const QDateTime &time)
{
    return time.isValid() ? QLocale().toString(time, QLocale::ShortFormat) : QString();
}

static QString formatPermissions(QFileDevice::Permissions permissions)
{
    static const struct {
        QFileDevice::Permission bit;
        char letter;
    } bits[] = {
        {QFileDevice::ReadOwner, 'r'},  {QFileDevice::WriteOwner, 'w'}, {QFileDevice::ExeOwner, 'x'},
        {QFileDevice::ReadGroup, 'r'},  {QFileDevice::WriteGroup, 'w'}, {QFileDevice::ExeGroup, 'x'},
        {QFileDevice::ReadOther, 'r'},  {QFileDevice::WriteOther, 'w'}, {QFileDevice::ExeOther, 'x'},
    };

    QString text;
    for (const auto &entry : bits)
        text += permissions.testFlag(entry.bit) ? QChar(entry.letter) : QChar('-');
    return text;
}

static QString locationOf(const QFileInfo &info)
{
    const QString home = QDir::cleanPath(QDir::homePath());
    const QString parent = info.absolutePath();

    if (parent == home || parent.startsWith(home + u'/')) {
        QStringList parts = parent.mid(home.size()).split(u'/', Qt::SkipEmptyParts);
        parts.prepend(QString::fromUtf8(dgettext("sanar-filer", "Home")));
        return parts.join(QStringLiteral(" / "));
    }
    return parent;
}

void FileDetails::load()
{
    const QFileInfo info(m_path);
    if (m_path.isEmpty() || !info.exists()) {
        m_name.clear();
        m_description.clear();
        m_suffix.clear();
        m_icon.clear();
        m_kind = FileKinds::Other;
        m_sizeText.clear();
        m_modifiedText.clear();
        m_createdText.clear();
        m_permissionsText.clear();
        m_locationText.clear();
        return;
    }

    QMimeDatabase mimeDb;
    const QMimeType mime = mimeDb.mimeTypeForFile(info, QMimeDatabase::MatchExtension);

    m_name = info.fileName();
    m_suffix = info.suffix().toUpper();
    m_modifiedText = formatTime(info.lastModified());
    m_createdText = formatTime(info.birthTime());
    m_permissionsText = formatPermissions(info.permissions());
    m_locationText = locationOf(info);

    if (info.isDir()) {
        m_kind = FileKinds::Folder;
        m_description = QString::fromUtf8(dgettext("sanar-filer", "Folder"));
        int count = 0;
        for (const auto &item : QDirListing(m_path, QDirListing::IteratorFlag::IncludeHidden)) {
            Q_UNUSED(item)
            ++count;
        }
        m_sizeText = QString::fromUtf8(dngettext("sanar-filer", "%1 item", "%1 items", count))
                         .replace(QStringLiteral("%1"), QString::number(count));
    } else {
        m_kind = FileKinds::kindOf(mime);
        m_description = mime.comment();
        m_sizeText = formatSize(info.size());
        if (m_kind == FileKinds::Image) {
            const QSize size = QImageReader(m_path).size();
            if (size.isValid()) {
                m_description += QString::fromUtf8(" · %1 × %2").arg(size.width()).arg(size.height());
            }
        }
    }
    m_icon = FileKinds::iconName(m_kind);
}
