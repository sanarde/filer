import QtQuick
import QtQuick.Layouts
import Sanar.Filer

Window {
    id: root

    width: Settings.windowWidth
    height: Settings.windowHeight
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
        sortKey: Settings.sortKey
        sortDescending: Settings.sortDescending
        showHidden: Settings.showHidden
        foldersFirst: Settings.separateFolders
    }

    Binding {
        target: Theme
        property: "mode"
        value: Settings.themeMode
    }

    Binding {
        target: Theme
        property: "palette"
        value: Settings.palette
    }

    Component.onCompleted: {
        if (Settings.windowMaximized)
            showMaximized()
    }

    onClosing: {
        Settings.windowMaximized = visibility === Window.Maximized
        if (visibility === Window.Windowed) {
            Settings.windowWidth = width
            Settings.windowHeight = height
        }
    }

    property string dismissedDetails

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: settingsDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+H"
        enabled: !settingsDialog.visible
        onActivated: Settings.showHidden = !Settings.showHidden
    }

    Shortcut {
        sequence: "Alt+Left"
        enabled: !settingsDialog.visible
        onActivated: pathNavigator.back()
    }

    Shortcut {
        sequence: "Alt+Right"
        enabled: !settingsDialog.visible
        onActivated: pathNavigator.forward()
    }

    Shortcut {
        sequence: "Alt+Up"
        enabled: !settingsDialog.visible
        onActivated: pathNavigator.up()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: root.visibility === Window.Maximized ? 0 : 32

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            enabled: !settingsDialog.visible

            TopBar {
                Layout.fillWidth: true
                window: root
                canGoBack: pathNavigator.canGoBack
                canGoForward: pathNavigator.canGoForward
                canGoUp: pathNavigator.canGoUp
                onBackRequested: pathNavigator.back()
                onForwardRequested: pathNavigator.forward()
                onUpRequested: pathNavigator.up()
                onSettingsRequested: settingsDialog.open()
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
                        id: page
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

        SettingsDialog {
            id: settingsDialog
            anchors.fill: parent
            radius: parent.radius
            onCloseRequested: visible = false
            onVisibleChanged: if (!visible) page.forceActiveFocus()
        }
    }

    ResizeHandles {
        anchors.fill: parent
        window: root
    }
}
