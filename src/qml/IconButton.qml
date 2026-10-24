import QtQuick
import Sanar.Filer

Item {
    id: root

    property string icon
    property bool filled: false
    property int iconSize: 24
    property color color: "transparent"
    property color hoverColor: Qt.alpha(Theme.onSurface, 0.1)
    property color iconColor: Theme.onSurfaceVariant
    property string label
    property real radius: height / 2
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius

    signal clicked

    implicitWidth: 40
    implicitHeight: 40
    opacity: enabled ? 1 : 0.5

    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.onPressAction: root.clicked()

    Rectangle {
        anchors.fill: parent
        color: root.color
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
    }

    Rectangle {
        anchors.fill: parent
        color: root.hoverColor
        visible: hover.hovered
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
    }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        filled: root.filled
        color: root.iconColor
        font.pixelSize: root.iconSize
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
