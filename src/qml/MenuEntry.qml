import QtQuick
import Sanar.Filer

Item {
    id: root

    property string label
    property string icon: "check"
    property bool checked: false
    property bool showIcon: checked

    signal triggered

    width: parent ? parent.width : 220
    height: 44
    opacity: enabled ? 1 : 0.5

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
        name: root.icon
        visible: root.showIcon
        color: root.checked ? Theme.primary : Theme.onSurfaceVariant
        font.pixelSize: 20
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: Theme.onSurface
        font.pixelSize: 14
        font.weight: root.checked ? Font.DemiBold : Font.Medium
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.triggered()
    }
}
