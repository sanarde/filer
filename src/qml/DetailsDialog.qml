import QtQuick
import Sanar.Filer

Item {
    id: root

    property alias path: panel.path
    property real radius: 0

    signal openRequested(string path)
    signal closeRequested

    function open(filePath) {
        panel.path = filePath
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

    DetailsPanel {
        id: panel
        anchors.centerIn: parent
        width: Math.min(480, parent.width - 48)
        height: Math.min(parent.height - 48, 720)
        detailed: true
        onCloseRequested: root.closeRequested()
        onOpenRequested: path => root.openRequested(path)

        MouseArea {
            anchors.fill: parent
            z: -1
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onWheel: wheel => wheel.accepted = true
        }
    }
}
