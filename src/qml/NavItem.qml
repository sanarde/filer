import QtQuick
import Sanar.Filer
import Sanar.Style

Item {
    id: root

    property string icon
    property string label
    property bool selected: false
    property bool ejectable: false

    signal clicked
    signal ejectRequested

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
        anchors.right: eject.visible ? eject.left : parent.right
        anchors.rightMargin: eject.visible ? 4 : 20
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        elide: Text.ElideRight
        color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
        font.pixelSize: 14
        font.weight: root.selected ? Font.Bold : Font.Medium
    }

    IconButton {
        id: eject
        visible: root.ejectable
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
        icon: "eject"
        iconSize: 20
        label: Tr.t("Eject")
        onClicked: root.ejectRequested()
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: point => {
            if (!eject.visible || !eject.contains(eject.mapFromItem(root, point.position)))
                root.clicked()
        }
    }
}
