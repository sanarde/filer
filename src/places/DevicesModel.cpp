#include "DevicesModel.h"

#include <libintl.h>

#include <QDir>
#include <QStorageInfo>

#include <algorithm>

#include "SizeFormat.h"

DevicesModel::DevicesModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_devices(scan())
{
    m_timer.setInterval(5000);
    connect(&m_timer, &QTimer::timeout, this, &DevicesModel::refresh);
    m_timer.start();
}

QList<DevicesModel::Device> DevicesModel::scan()
{
    QList<Device> devices;
    for (const QStorageInfo &storage : QStorageInfo::mountedVolumes()) {
        const QString node = QString::fromUtf8(storage.device());
        if (!storage.isValid() || !storage.isReady() || !node.startsWith(u"/dev/")
            || node.startsWith(u"/dev/loop"))
            continue;

        const QString path = storage.rootPath();
        if (path.startsWith(u"/boot") || path.startsWith(u"/efi"))
            continue;
        auto same = std::find_if(devices.begin(), devices.end(),
                                 [&](const Device &d) { return d.deviceNode == node; });
        if (same != devices.end()) {
            if (path.size() < same->path.size())
                devices.erase(same);
            else
                continue;
        }

        Device device;
        device.deviceNode = node;
        device.path = path;
        device.total = storage.bytesTotal();
        device.used = storage.bytesTotal() - storage.bytesFree();
        device.label = storage.name();
        if (device.label.isEmpty()) {
            device.label = path == u"/" ? QString::fromUtf8(dgettext("sanar-filer", "System"))
                                         : QDir(path).dirName();
        }
        const bool removable = path.startsWith(u"/run/media/") || path.startsWith(u"/media/");
        device.icon = removable ? "usb" : "hard_drive";
        devices.append(device);
    }

    std::sort(devices.begin(), devices.end(), [](const Device &a, const Device &b) {
        if ((a.path == u"/") != (b.path == u"/"))
            return a.path == u"/";
        return a.path < b.path;
    });
    return devices;
}

void DevicesModel::refresh()
{
    const QList<Device> devices = scan();
    if (devices == m_devices)
        return;

    beginResetModel();
    m_devices = devices;
    endResetModel();
}

int DevicesModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_devices.size();
}

QVariant DevicesModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid))
        return {};

    const Device &device = m_devices.at(index.row());
    switch (role) {
    case Qt::DisplayRole:
    case LabelRole:
        return device.label;
    case IconRole:
        return device.icon;
    case PathRole:
        return device.path;
    case UsedTextRole:
        return QString::fromUtf8(dgettext("sanar-filer", "%1 of %2 used"))
            .arg(formatSize(device.used), formatSize(device.total));
    case UsedFractionRole:
        return device.total > 0 ? double(device.used) / double(device.total) : 0.0;
    case PrimaryRole:
        return device.path == u"/";
    }
    return {};
}

QHash<int, QByteArray> DevicesModel::roleNames() const
{
    return {
        {LabelRole, "label"},
        {IconRole, "icon"},
        {PathRole, "path"},
        {UsedTextRole, "usedText"},
        {UsedFractionRole, "usedFraction"},
        {PrimaryRole, "primary"},
    };
}
