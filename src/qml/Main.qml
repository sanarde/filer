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

    Navigator {
        id: navigator
    }

    DirectoryModel {
        id: directory
        path: navigator.path
    }

    Shortcut {
        sequence: "Alt+Left"
        onActivated: navigator.back()
    }

    Shortcut {
        sequence: "Alt+Right"
        onActivated: navigator.forward()
    }

    Shortcut {
        sequence: "Alt+Up"
        onActivated: navigator.up()
    }

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
                canGoBack: navigator.canGoBack
                canGoForward: navigator.canGoForward
                canGoUp: navigator.canGoUp
                onBackRequested: navigator.back()
                onForwardRequested: navigator.forward()
                onUpRequested: navigator.up()
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.bottomMargin: 12
                color: Theme.surfaceLow
                radius: 28
                clip: true

                Breadcrumbs {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 18
                    anchors.rightMargin: 28
                    anchors.topMargin: 20
                    crumbs: navigator.crumbs
                    onCrumbClicked: path => navigator.goTo(path)
                }
            }
        }
    }

    ResizeHandles {
        anchors.fill: parent
        window: root
    }
}
