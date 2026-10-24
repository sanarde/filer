import QtQuick
import Sanar.Filer

Item {
    id: root

    property string icon
    property string label
    property string usedText
    property real usedFraction: 0

    signal clicked

    implicitHeight: content.implicitHeight + 26

    Accessible.role: Accessible.Button
    Accessible.name: label + ", " + usedText
    Accessible.onPressAction: root.clicked()

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Theme.surface
    }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Qt.alpha(Theme.onSurface, 0.08)
        visible: hover.hovered
    }

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 14
        spacing: 12

        Row {
            spacing: 12

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: root.icon
                filled: true
                color: Theme.primary
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: root.label
                    color: Theme.onSurface
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Text {
                    text: root.usedText
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 12
                }
            }
        }

        WaveProgress {
            width: parent.width
            value: root.usedFraction
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
