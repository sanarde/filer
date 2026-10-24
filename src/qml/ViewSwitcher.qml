import QtQuick
import Sanar.Filer

Row {
    id: root

    readonly property string viewMode: Settings.viewMode

    spacing: 2

    IconButton {
        width: 48
        height: 48
        icon: "view_list"
        filled: root.viewMode === "list"
        label: Tr.t("List")
        color: root.viewMode === "list" ? Theme.primary : Theme.surfaceHigh
        iconColor: root.viewMode === "list" ? Theme.onPrimary : Theme.onSurfaceVariant
        radius: root.viewMode === "list" ? 24 : 8
        topLeftRadius: 24
        bottomLeftRadius: 24
        onClicked: Settings.viewMode = "list"
    }

    IconButton {
        width: 48
        height: 48
        icon: "grid_view"
        filled: root.viewMode === "grid"
        label: Tr.t("Grid")
        color: root.viewMode === "grid" ? Theme.primary : Theme.surfaceHigh
        iconColor: root.viewMode === "grid" ? Theme.onPrimary : Theme.onSurfaceVariant
        radius: root.viewMode === "grid" ? 24 : 8
        topRightRadius: 24
        bottomRightRadius: 24
        onClicked: Settings.viewMode = "grid"
    }
}
