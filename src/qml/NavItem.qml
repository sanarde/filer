import QtQuick
import Sanar.Filer

Item {
    id: root

    property string icon
    property string label
    property bool selected: false

    signal clicked

    implicitHeight: 52

    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.onPressAction: root.clicked()

    Rectangle {
        anchors.fill: parent
        radius: 26
        color: root.selected ? Theme.secondaryContainer
                             : hover.hovered ? Qt.alpha(Theme.onSurface, 0.08) : "transparent"
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        filled: root.selected
        color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
    }

    Text {
        anchors.left: glyph.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        elide: Text.ElideRight
        color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
        font.pixelSize: 14
        font.weight: root.selected ? Font.Bold : Font.Medium
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.clicked()
    }
}
