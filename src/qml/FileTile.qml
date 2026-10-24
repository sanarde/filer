import QtQuick
import Sanar.Filer

Item {
    id: root

    property string name
    property string subtitle
    property string icon
    property int kind: FileKind.Other

    signal opened

    implicitHeight: 144

    Accessible.role: Accessible.Button
    Accessible.name: name
    Accessible.onPressAction: root.opened()

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: hover.hovered ? Theme.surface : "transparent"
    }

    Rectangle {
        id: thumb
        x: 8
        y: 8
        width: parent.width - 16
        height: 104
        radius: 18
        color: Theme.surfaceHighest

        Rectangle {
            visible: root.kind === FileKind.Document
            anchors.centerIn: parent
            width: 76
            height: 88
            radius: 10
            color: Theme.surfaceLowest

            Column {
                x: 10
                y: 12
                spacing: 6

                Repeater {
                    model: [0.6, 1, 1, 0.8, 0.5]

                    Rectangle {
                        required property real modelData
                        required property int index

                        width: (76 - 20) * modelData
                        height: index === 0 ? 6 : 4
                        radius: 2
                        color: index === 0 ? Theme.primary : Theme.outlineVariant
                    }
                }
            }
        }

        Rectangle {
            visible: root.kind !== FileKind.Document
            anchors.centerIn: parent
            width: 72
            height: 72
            color: [Theme.primaryContainer, Theme.primaryContainer, Theme.surfaceHigh,
                    Theme.secondaryContainer, Theme.tertiaryContainer, Theme.primaryContainer,
                    Theme.tertiaryContainer, Theme.surfaceHigh][root.kind]
            topLeftRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 26 : 8)
            topRightRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 8 : 26)
            bottomLeftRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 8 : 26)
            bottomRightRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 26 : 8)

            Icon {
                anchors.centerIn: parent
                name: root.icon
                filled: true
                color: [Theme.onPrimaryContainer, Theme.onPrimaryContainer, Theme.onSurface,
                        Theme.onSecondaryContainer, Theme.onTertiaryContainer,
                        Theme.onPrimaryContainer, Theme.onTertiaryContainer,
                        Theme.onSurface][root.kind]
                font.pixelSize: 36
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
            color: Theme.onSurface
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: root.subtitle
            elide: Text.ElideRight
            color: Theme.onSurfaceVariant
            font.pixelSize: 12
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onDoubleTapped: root.opened()
    }
}
