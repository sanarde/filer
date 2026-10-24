import QtQuick
import QtQuick.Layouts
import Sanar.Filer

Item {
    id: root

    required property Window window

    property alias navigation: navigation
    property alias search: search

    implicitHeight: 72

    DragHandler {
        target: null
        onActiveChanged: if (active) root.window.startSystemMove()
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onDoubleTapped: root.window.visibility === Window.Maximized ? root.window.showNormal()
                                                                    : root.window.showMaximized()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Item {
            Layout.preferredWidth: 236
            Layout.fillHeight: true

            NavigationButtons {
                id: navigation
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        SearchField {
            id: search
            Layout.fillWidth: true
            Layout.maximumWidth: 720
        }

        Item { Layout.fillWidth: true }

        WindowControls {
            window: root.window
        }
    }
}
