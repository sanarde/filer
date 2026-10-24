pragma ComponentBehavior: Bound

import QtQuick
import Sanar.Filer

Rectangle {
    id: root

    required property DirectoryModel directory

    signal closed

    width: 220
    height: column.implicitHeight + 16
    radius: 16
    color: Theme.surfaceHighest
    border.width: 1
    border.color: Theme.outlineVariant

    component MenuEntry: Item {
        id: entry

        property string label
        property bool checked: false
        property string icon: "check"

        signal triggered

        width: root.width
        height: 44

        Accessible.role: Accessible.MenuItem
        Accessible.name: label
        Accessible.checked: checked

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            radius: 12
            color: hover.hovered ? Qt.alpha(Theme.onSurface, 0.08) : "transparent"
        }

        Icon {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            name: entry.icon
            visible: entry.checked
            color: Theme.primary
            font.pixelSize: 20
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 52
            anchors.verticalCenter: parent.verticalCenter
            text: entry.label
            color: Theme.onSurface
            font.pixelSize: 14
            font.weight: entry.checked ? Font.DemiBold : Font.Medium
        }

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: {
                entry.triggered()
                root.closed()
            }
        }
    }

    Column {
        id: column
        y: 8

        MenuEntry {
            label: Tr.t("Name")
            checked: root.directory.sortKey === DirectoryModel.SortByName
            onTriggered: root.directory.sortKey = DirectoryModel.SortByName
        }

        MenuEntry {
            label: Tr.t("Date modified")
            checked: root.directory.sortKey === DirectoryModel.SortByModified
            onTriggered: root.directory.sortKey = DirectoryModel.SortByModified
        }

        MenuEntry {
            label: Tr.t("Size")
            checked: root.directory.sortKey === DirectoryModel.SortBySize
            onTriggered: root.directory.sortKey = DirectoryModel.SortBySize
        }

        MenuEntry {
            label: Tr.t("Type")
            checked: root.directory.sortKey === DirectoryModel.SortByType
            onTriggered: root.directory.sortKey = DirectoryModel.SortByType
        }

        Rectangle {
            x: 16
            width: root.width - 32
            height: 1
            color: Theme.outlineVariant
        }

        MenuEntry {
            label: Tr.t("Ascending")
            icon: "arrow_upward"
            checked: !root.directory.sortDescending
            onTriggered: root.directory.sortDescending = false
        }

        MenuEntry {
            label: Tr.t("Descending")
            icon: "arrow_downward"
            checked: root.directory.sortDescending
            onTriggered: root.directory.sortDescending = true
        }
    }
}
