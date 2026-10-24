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
        id: pathNavigator
    }

    DirectoryModel {
        id: dirModel
        path: pathNavigator.path
    }

    property string dismissedDetails

    Shortcut {
        sequence: "Alt+Left"
        onActivated: pathNavigator.back()
    }

    Shortcut {
        sequence: "Alt+Right"
        onActivated: pathNavigator.forward()
    }

    Shortcut {
        sequence: "Alt+Up"
        onActivated: pathNavigator.up()
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
                canGoBack: pathNavigator.canGoBack
                canGoForward: pathNavigator.canGoForward
                canGoUp: pathNavigator.canGoUp
                onBackRequested: pathNavigator.back()
                onForwardRequested: pathNavigator.forward()
                onUpRequested: pathNavigator.up()
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: 12
                Layout.bottomMargin: 12
                spacing: 12

                Sidebar {
                    Layout.preferredWidth: 236
                    Layout.leftMargin: 16
                    Layout.topMargin: 4
                    Layout.fillHeight: true
                    currentPath: pathNavigator.path
                    onPathRequested: path => pathNavigator.goTo(path)
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.surfaceLow
                    radius: 28
                    clip: true

                    DirectoryPage {
                        anchors.fill: parent
                        navigator: pathNavigator
                        directory: dirModel
                    }
                }

                DetailsPanel {
                    Layout.preferredWidth: 332
                    Layout.fillHeight: true
                    visible: dirModel.selectedPath !== "" && dirModel.selectedPath !== root.dismissedDetails
                    path: dirModel.selectedPath
                    onCloseRequested: root.dismissedDetails = dirModel.selectedPath
                    onOpenRequested: path => pathNavigator.open(path)
                }
            }
        }
    }

    ResizeHandles {
        anchors.fill: parent
        window: root
    }
}
