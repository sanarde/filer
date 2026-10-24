import QtQuick
import Sanar.Filer

Rectangle {
    id: root

    property bool onEntry: false
    property int selectedCount: 0
    property bool canPaste: false
    property bool inTrash: false
    property bool inRecent: false

    signal openRequested
    signal showInFolderRequested
    signal detailsRequested
    signal renameRequested
    signal copyRequested
    signal cutRequested
    signal pasteRequested
    signal deleteRequested
    signal restoreRequested
    signal emptyTrashRequested
    signal newFolderRequested
    signal selectAllRequested
    signal refreshRequested
    signal sortRequested
    signal closed

    readonly property bool single: onEntry && selectedCount === 1

    width: 260
    height: column.implicitHeight + 16
    radius: 16
    color: Theme.surfaceHighest
    border.width: 1
    border.color: Theme.outlineVariant

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = true
    }

    Column {
        id: column
        y: 8
        width: root.width

        MenuEntry {
            visible: root.single
            icon: "open_in_new"
            showIcon: true
            label: Tr.t("Open")
            onTriggered: {
                root.openRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: root.single && root.inRecent
            icon: "folder_open"
            showIcon: true
            label: Tr.t("Show in folder")
            onTriggered: {
                root.showInFolderRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: root.single
            icon: "info"
            showIcon: true
            label: Tr.t("Details")
            onTriggered: {
                root.detailsRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: root.single
            icon: "edit"
            showIcon: true
            label: Tr.t("Rename")
            onTriggered: {
                root.renameRequested()
                root.closed()
            }
        }

        MenuSeparator {
            visible: root.onEntry
        }

        MenuEntry {
            visible: root.onEntry && !root.inTrash
            icon: "content_copy"
            showIcon: true
            label: Tr.t("Copy")
            onTriggered: {
                root.copyRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: root.onEntry && !root.inTrash
            icon: "content_cut"
            showIcon: true
            label: Tr.t("Cut")
            onTriggered: {
                root.cutRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: root.onEntry && root.inTrash
            icon: "restore_from_trash"
            showIcon: true
            label: Tr.t("Restore")
            onTriggered: {
                root.restoreRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: root.onEntry
            icon: root.inTrash ? "delete_forever" : "delete"
            showIcon: true
            label: root.inTrash ? Tr.t("Delete permanently") : Tr.t("Move to trash")
            onTriggered: {
                root.deleteRequested()
                root.closed()
            }
        }

        MenuSeparator {
            visible: root.onEntry
        }

        MenuEntry {
            visible: !root.onEntry && !root.inTrash && !root.inRecent
            enabled: root.canPaste
            icon: "content_paste"
            showIcon: true
            label: Tr.t("Paste")
            onTriggered: {
                root.pasteRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: !root.onEntry && !root.inTrash && !root.inRecent
            icon: "create_new_folder"
            showIcon: true
            label: Tr.t("New folder")
            onTriggered: {
                root.newFolderRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: !root.onEntry && root.inTrash
            icon: "delete_forever"
            showIcon: true
            label: Tr.t("Empty trash")
            onTriggered: {
                root.emptyTrashRequested()
                root.closed()
            }
        }

        MenuEntry {
            icon: "select_all"
            showIcon: true
            label: Tr.t("Select all")
            onTriggered: {
                root.selectAllRequested()
                root.closed()
            }
        }

        MenuEntry {
            visible: !root.onEntry
            icon: "refresh"
            showIcon: true
            label: Tr.t("Refresh")
            onTriggered: {
                root.refreshRequested()
                root.closed()
            }
        }

        MenuSeparator {
            visible: !root.onEntry
        }

        MenuEntry {
            visible: !root.onEntry
            checked: Settings.showHidden
            label: Tr.t("Show hidden files")
            onTriggered: {
                Settings.showHidden = !Settings.showHidden
                root.closed()
            }
        }

        MenuEntry {
            visible: !root.onEntry
            checked: Settings.separateFolders
            label: Tr.t("Separate folders and files")
            onTriggered: {
                Settings.separateFolders = !Settings.separateFolders
                root.closed()
            }
        }

        MenuEntry {
            visible: !root.onEntry
            icon: "swap_vert"
            showIcon: true
            label: Tr.t("Sort by")
            onTriggered: {
                root.sortRequested()
                root.closed()
            }
        }
    }
}
