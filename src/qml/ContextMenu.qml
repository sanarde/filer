import QtQuick
import Sanar.Filer

Rectangle {
    id: root

    property bool onEntry: false
    property int selectedCount: 0

    signal openRequested
    signal detailsRequested
    signal renameRequested
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
            visible: root.single
        }

        MenuEntry {
            visible: !root.onEntry
            icon: "create_new_folder"
            showIcon: true
            label: Tr.t("New folder")
            onTriggered: {
                root.newFolderRequested()
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
