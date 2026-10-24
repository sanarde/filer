import QtQuick
import Sanar.Filer

Item {
    id: root

    property string name
    property string subtitle
    property string icon
    property string path
    property int kind: FileKind.Other

    property bool selected: false

    signal selectRequested(int mode)
    signal opened

    implicitHeight: 170

    Accessible.role: Accessible.Button
    Accessible.name: name
    Accessible.onPressAction: root.opened()

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: root.selected ? Theme.secondaryContainer
                             : input.hovered ? Theme.surface : "transparent"
    }

    Rectangle {
        id: thumb
        x: 8
        y: 8
        width: parent.width - 16
        height: 104
        radius: root.selected ? 28 : 18
        color: Theme.surfaceHighest

        EntryThumb {
            anchors.fill: parent
            icon: root.icon
            kind: root.kind
            path: root.path
            radius: thumb.radius
        }

        Rectangle {
            visible: root.selected
            x: 8
            y: 8
            width: 24
            height: 24
            radius: 12
            color: Theme.primary

            Icon {
                anchors.centerIn: parent
                name: "check"
                filled: true
                color: Theme.onPrimary
                font.pixelSize: 18
            }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: thumb.bottom
        anchors.topMargin: 10
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 2

        Text {
            width: parent.width
            text: root.name
            elide: Text.ElideMiddle
            color: root.selected ? Theme.onSecondaryContainer : Theme.onSurface
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: root.subtitle
            elide: Text.ElideRight
            color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
            opacity: root.selected ? 0.78 : 1
            font.pixelSize: 12
        }
    }

    EntryInput {
        id: input
        anchors.fill: parent
        onSelectRequested: mode => root.selectRequested(mode)
        onOpened: root.opened()
    }
}
