import QtQuick
import Sanar.Filer

Item {
    id: root

    property string title
    property string text
    property var actions: []
    property int primaryIndex: 0
    property real radius: 0

    signal chosen(int index)
    signal closeRequested

    function open(heading, message, labels, primary) {
        title = heading
        text = message
        actions = labels
        primaryIndex = primary
        visible = true
        forceActiveFocus()
    }

    visible: false
    focus: true

    Shortcut {
        sequence: "Esc"
        enabled: root.visible
        onActivated: root.closeRequested()
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha("black", 0.5)

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: root.closeRequested()
            onWheel: wheel => wheel.accepted = true
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(480, parent.width - 48)
        height: column.implicitHeight + 48
        radius: 28
        color: Theme.surfaceHighest

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onWheel: wheel => wheel.accepted = true
        }

        Column {
            id: column
            x: 24
            y: 24
            width: parent.width - 48
            spacing: 16

            Text {
                width: parent.width
                text: root.title
                color: Theme.onSurface
                font.pixelSize: 22
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                text: root.text
                color: Theme.onSurfaceVariant
                font.pixelSize: 15
                wrapMode: Text.WordWrap
            }

            Row {
                anchors.right: parent.right
                spacing: 8

                Rectangle {
                    width: cancelText.implicitWidth + 40
                    height: 44
                    radius: 22
                    color: cancelArea.containsMouse ? Qt.alpha(Theme.onSurface, 0.08) : "transparent"

                    Text {
                        id: cancelText
                        anchors.centerIn: parent
                        text: Tr.t("Cancel")
                        color: Theme.primary
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.closeRequested()
                    }
                }

                Repeater {
                    model: root.actions

                    Rectangle {
                        required property int index
                        required property string modelData
                        readonly property bool primary: index === root.primaryIndex

                        width: actionText.implicitWidth + 40
                        height: 44
                        radius: 22
                        color: primary ? Theme.primary
                               : actionArea.containsMouse ? Qt.alpha(Theme.onSurface, 0.08) : "transparent"

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: parent.primary ? Theme.onPrimary : Theme.primary
                            font.pixelSize: 15
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: actionArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.chosen(parent.index)
                        }
                    }
                }
            }
        }
    }
}
