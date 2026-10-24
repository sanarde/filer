import QtQuick
import Sanar.Filer

Rectangle {
    id: root

    signal closed

    width: 220
    height: column.implicitHeight + 16
    radius: 16
    color: Theme.surfaceHighest
    border.width: 1
    border.color: Theme.outlineVariant

    Column {
        id: column
        y: 8
        width: root.width

        MenuEntry {
            label: Tr.t("Name")
            checked: Settings.sortKey === DirectoryModel.SortByName
            onTriggered: {
                Settings.sortKey = DirectoryModel.SortByName
                root.closed()
            }
        }

        MenuEntry {
            label: Tr.t("Date modified")
            checked: Settings.sortKey === DirectoryModel.SortByModified
            onTriggered: {
                Settings.sortKey = DirectoryModel.SortByModified
                root.closed()
            }
        }

        MenuEntry {
            label: Tr.t("Size")
            checked: Settings.sortKey === DirectoryModel.SortBySize
            onTriggered: {
                Settings.sortKey = DirectoryModel.SortBySize
                root.closed()
            }
        }

        MenuEntry {
            label: Tr.t("Type")
            checked: Settings.sortKey === DirectoryModel.SortByType
            onTriggered: {
                Settings.sortKey = DirectoryModel.SortByType
                root.closed()
            }
        }

        MenuSeparator {}

        MenuEntry {
            label: Tr.t("Ascending")
            icon: "arrow_upward"
            checked: !Settings.sortDescending
            onTriggered: {
                Settings.sortDescending = false
                root.closed()
            }
        }

        MenuEntry {
            label: Tr.t("Descending")
            icon: "arrow_downward"
            checked: Settings.sortDescending
            onTriggered: {
                Settings.sortDescending = true
                root.closed()
            }
        }
    }
}
