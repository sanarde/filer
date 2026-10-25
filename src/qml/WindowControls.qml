import QtQuick
import Sanar.Filer
import Sanar.Style

Row {
    id: root

    required property Window window

    spacing: 2

    IconButton {
        width: 48
        icon: "remove"
        iconSize: 20
        label: Tr.t("Minimize")
        color: Theme.surfaceHigh
        hoverColor: Theme.surfaceHighest
        iconColor: Theme.onSurface
        radius: 8
        topLeftRadius: 20
        bottomLeftRadius: 20
        onClicked: root.window.showMinimized()
    }

    IconButton {
        width: 48
        icon: "crop_square"
        iconSize: 20
        label: root.window.visibility === Window.Maximized ? Tr.t("Restore") : Tr.t("Maximize")
        color: Theme.surfaceHigh
        hoverColor: Theme.surfaceHighest
        iconColor: Theme.onSurface
        radius: 8
        onClicked: root.window.visibility === Window.Maximized ? root.window.showNormal()
                                                              : root.window.showMaximized()
    }

    IconButton {
        width: 48
        icon: "close"
        iconSize: 20
        label: Tr.t("Close")
        color: Theme.errorContainer
        hoverColor: Qt.alpha(Theme.onErrorContainer, 0.12)
        iconColor: Theme.onErrorContainer
        radius: 8
        topRightRadius: 20
        bottomRightRadius: 20
        onClicked: root.window.close()
    }
}
