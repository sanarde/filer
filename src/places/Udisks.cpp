#include "Udisks.h"

#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusMetaType>
#include <QDBusObjectPath>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QVariantMap>

#include <algorithm>

#include "SizeFormat.h"

namespace {

using InterfaceMap = QMap<QString, QVariantMap>;
using ObjectMap = QMap<QDBusObjectPath, InterfaceMap>;

constexpr auto service = "org.freedesktop.UDisks2";
constexpr auto root = "/org/freedesktop/UDisks2";
constexpr auto objectManager = "org.freedesktop.DBus.ObjectManager";
constexpr auto blockInterface = "org.freedesktop.UDisks2.Block";
constexpr auto driveInterface = "org.freedesktop.UDisks2.Drive";
constexpr auto filesystemInterface = "org.freedesktop.UDisks2.Filesystem";

}

Udisks::Udisks(QObject *parent)
    : QObject(parent)
{
    qDBusRegisterMetaType<InterfaceMap>();
    qDBusRegisterMetaType<ObjectMap>();

    m_debounce.setSingleShot(true);
    m_debounce.setInterval(300);
    connect(&m_debounce, &QTimer::timeout, this, &Udisks::fetch);

    QDBusConnection bus = QDBusConnection::systemBus();
    bus.connect(service, {}, "org.freedesktop.DBus.Properties", "PropertiesChanged", this,
                SLOT(scheduleFetch()));
    bus.connect(service, root, objectManager, "InterfacesAdded", this, SLOT(scheduleFetch()));
    bus.connect(service, root, objectManager, "InterfacesRemoved", this, SLOT(scheduleFetch()));

    fetch();
}

void Udisks::scheduleFetch()
{
    m_debounce.start();
}

void Udisks::fetch()
{
    const QDBusMessage message = QDBusMessage::createMethodCall(service, root, objectManager,
                                                                "GetManagedObjects");
    auto *watcher = new QDBusPendingCallWatcher(QDBusConnection::systemBus().asyncCall(message), this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this, [this](QDBusPendingCallWatcher *w) {
        w->deleteLater();
        const QDBusPendingReply<ObjectMap> reply = *w;
        if (reply.isError())
            return;

        const ObjectMap objects = reply.value();
        QList<UdisksBlock> blocks;
        for (auto it = objects.cbegin(); it != objects.cend(); ++it) {
            const InterfaceMap &interfaces = it.value();
            if (!interfaces.contains(blockInterface) || !interfaces.contains(filesystemInterface))
                continue;

            const QVariantMap &block = interfaces.value(blockInterface);
            UdisksBlock entry;
            entry.path = it.key().path();
            entry.device = QString::fromUtf8(qdbus_cast<QByteArray>(block.value("Device")).constData());
            if (block.value("HintIgnore").toBool() || entry.device.startsWith(u"/dev/loop"))
                continue;

            entry.size = block.value("Size").toLongLong();
            entry.system = block.value("HintSystem").toBool();
            entry.mounted = !qdbus_cast<QList<QByteArray>>(
                                 interfaces.value(filesystemInterface).value("MountPoints")).isEmpty();
            entry.label = block.value("IdLabel").toString();
            entry.drive = block.value("Drive").value<QDBusObjectPath>().path();

            const QVariantMap drive = objects.value(QDBusObjectPath(entry.drive))
                                          .value(driveInterface);
            entry.ejectable = drive.value("Ejectable").toBool();
            entry.canPowerOff = drive.value("CanPowerOff").toBool();
            if (entry.label.isEmpty())
                entry.label = drive.value("Model").toString();
            if (entry.label.isEmpty())
                entry.label = formatSize(entry.size);
            blocks.append(entry);
        }

        m_blocks = blocks;
        emit blocksChanged(blocks);
    });
}

void Udisks::call(const QString &path, const QString &interface, const QString &method,
                  const std::function<void(const QDBusMessage &)> &done)
{
    QDBusMessage message = QDBusMessage::createMethodCall(service, path, interface, method);
    message.setArguments({QVariantMap()});
    auto *watcher = new QDBusPendingCallWatcher(QDBusConnection::systemBus().asyncCall(message), this);
    connect(watcher, &QDBusPendingCallWatcher::finished, this,
            [this, done](QDBusPendingCallWatcher *w) {
                w->deleteLater();
                if (w->isError())
                    emit failed(w->error().message());
                else
                    done(w->reply());
            });
}

void Udisks::mount(const QString &block)
{
    call(block, filesystemInterface, "Mount", [this](const QDBusMessage &reply) {
        emit mountReady(reply.arguments().value(0).toString());
    });
}

void Udisks::eject(const QString &block)
{
    const auto found = std::find_if(m_blocks.cbegin(), m_blocks.cend(),
                                    [&](const UdisksBlock &b) { return b.path == block; });
    if (found == m_blocks.cend())
        return;

    const UdisksBlock entry = *found;
    call(block, filesystemInterface, "Unmount", [this, entry](const QDBusMessage &) {
        release(entry);
    });
}

void Udisks::release(const UdisksBlock &block)
{
    const bool shared = std::any_of(m_blocks.cbegin(), m_blocks.cend(), [&](const UdisksBlock &b) {
        return b.drive == block.drive && b.path != block.path && b.mounted;
    });
    if (shared)
        return;

    if (block.ejectable)
        call(block.drive, driveInterface, "Eject", [](const QDBusMessage &) {});
    else if (block.canPowerOff)
        call(block.drive, driveInterface, "PowerOff", [](const QDBusMessage &) {});
}
