import QtQuick
import QtQuick.Layouts
import Sanar.Filer

Window {
    id: root

    width: 1400
    height: 860
    minimumWidth: 640
    minimumHeight: 420
    visible: true
    title: "Sanar Filer"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: root.visibility === Window.Maximized ? 0 : 32

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            TopBar {
                Layout.fillWidth: true
                window: root
            }

            Item { Layout.fillHeight: true }
        }
    }

    ResizeHandles {
        anchors.fill: parent
        window: root
    }
}
