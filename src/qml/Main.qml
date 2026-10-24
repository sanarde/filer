import QtQuick
import Sanar.Filer

Window {
    width: 1400
    height: 860
    visible: true
    title: "Sanar Filer"
    color: Theme.desk

    Rectangle {
        anchors.fill: parent
        anchors.margins: 20
        radius: 32
        color: Theme.background

        Row {
            anchors.centerIn: parent
            spacing: 12
            Icon { name: "home"; filled: true; color: Theme.primary }
            Icon { name: "folder" }
            Icon { name: "hard_drive"; filled: true }
            Text {
                text: "Sanar Filer"
                color: Theme.onSurface
                font.pixelSize: 24
                font.weight: Font.Bold
            }
        }
    }
}
