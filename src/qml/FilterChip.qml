import QtQuick
import Sanar.Filer

Item {
    id: root

    property string icon
    property string label
    property bool selected: false

    signal clicked

    implicitWidth: content.implicitWidth + (selected ? 28 : 32)
    implicitHeight: 40

    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.checked: selected
    Accessible.onPressAction: root.clicked()

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.selected ? Theme.secondaryContainer
                             : hover.hovered ? Qt.alpha(Theme.onSurface, 0.08) : "transparent"
        border.width: root.selected ? 0 : 1
        border.color: Theme.outlineVariant
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 8

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.selected ? "check" : root.icon
            color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
            font.pixelSize: 18
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
            font.pixelSize: 14
            font.weight: root.selected ? Font.DemiBold : Font.Medium
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
