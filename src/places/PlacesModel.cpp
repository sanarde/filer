#include "PlacesModel.h"

#include <libintl.h>

#include <QDir>
#include <QStandardPaths>

#include "RecentFiles.h"

PlacesModel::PlacesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const QString home = QDir::cleanPath(QDir::homePath());
    const QString trash = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
                          + "/Trash/files";

    m_places.append({QString::fromUtf8(dgettext("sanar-filer", "Home")), "home", home});
    m_places.append({QString::fromUtf8(dgettext("sanar-filer", "Recent")), "history", RecentFiles::location});

    const QList<Place> candidates = {
        {QString::fromUtf8(dgettext("sanar-filer", "Documents")), "description",
         QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)},
        {QString::fromUtf8(dgettext("sanar-filer", "Downloads")), "download",
         QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)},
        {QString::fromUtf8(dgettext("sanar-filer", "Pictures")), "image",
         QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)},
        {QString::fromUtf8(dgettext("sanar-filer", "Music")), "music_note",
         QStandardPaths::writableLocation(QStandardPaths::MusicLocation)},
        {QString::fromUtf8(dgettext("sanar-filer", "Videos")), "movie",
         QStandardPaths::writableLocation(QStandardPaths::MoviesLocation)},
        {QString::fromUtf8(dgettext("sanar-filer", "Trash")), "delete", trash},
    };

    for (const Place &place : candidates) {
        if (place.path != home && QDir(place.path).exists())
            m_places.append(place);
    }
}

int PlacesModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_places.size();
}

QVariant PlacesModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid))
        return {};

    const Place &place = m_places.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case LabelRole:
        return place.label;
    case IconRole:
        return place.icon;
    case PathRole:
        return place.path;
    }
    return {};
}

QHash<int, QByteArray> PlacesModel::roleNames() const
{
    return {
        {LabelRole, "label"},
        {IconRole, "icon"},
        {PathRole, "path"},
    };
}
