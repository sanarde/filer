import QtQuick
import Sanar.Filer

Item {
    id: root

    property string title
    property string confirmLabel
    property string error
    property real radius: 0

    signal accepted(string name)
    signal closeRequested

    function open(heading, label, initial) {
        title = heading
        confirmLabel = label
        error = ""
        input.text = initial
        visible = true
        input.forceActiveFocus()
        const dot = initial.lastIndexOf(".")
        input.select(0, dot > 0 ? dot : initial.length)
    }

    visible: false

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
        width: Math.min(420, parent.width - 48)
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
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width
                height: 52
                radius: 16
                color: Theme.surfaceHigh
                border.width: 2
                border.color: root.error !== "" ? Theme.onErrorContainer : input.activeFocus ? Theme.primary : "transparent"

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.onSurface
                    font.pixelSize: 16
                    clip: true
                    selectByMouse: true
                    selectionColor: Theme.primaryContainer
                    selectedTextColor: Theme.onPrimaryContainer
                    Accessible.name: root.title
                    onTextChanged: root.error = ""
                    onAccepted: root.accepted(text)
                }
            }

            Text {
                visible: root.error !== ""
                width: parent.width
                text: root.error
                color: Theme.onErrorContainer
                font.pixelSize: 14
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

                Rectangle {
                    width: confirmText.implicitWidth + 40
                    height: 44
                    radius: 22
                    color: Theme.primary
                    opacity: confirmArea.containsMouse ? 0.92 : 1

                    Text {
                        id: confirmText
                        anchors.centerIn: parent
                        text: root.confirmLabel
                        color: Theme.onPrimary
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: confirmArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.accepted(input.text)
                    }
                }
            }
        }
    }
}
