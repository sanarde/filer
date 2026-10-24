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

    FileOperations {
        id: fileOps
    }

    property string renamePath

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
    property bool detailsVisible: false
    readonly property bool dialogOpen: settingsDialog.visible || detailsDialog.visible || nameDialog.visible

    Binding {
        target: root
        property: "detailsVisible"
        value: dirModel.selectedPath !== "" && dirModel.selectedPath !== root.dismissedDetails
        when: !page.selecting
    }

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: settingsDialog.open()
    }

    Shortcut {
        sequence: "Alt+Return"
        enabled: dirModel.selectedPath !== "" && !root.dialogOpen
        onActivated: detailsDialog.open(dirModel.selectedPath)
    }

    Shortcut {
        sequence: "F2"
        enabled: dirModel.selectedCount === 1 && !root.dialogOpen
        onActivated: page.renameRequested(dirModel.selectedPath)
    }

    Shortcut {
        sequence: "Ctrl+Shift+N"
        enabled: !root.dialogOpen
        onActivated: page.newFolderRequested()
    }

    Shortcut {
        sequence: "Ctrl+H"
        enabled: !root.dialogOpen
        onActivated: Settings.showHidden = !Settings.showHidden
    }

    Shortcut {
        sequence: "Alt+Left"
        enabled: !root.dialogOpen
        onActivated: pathNavigator.back()
    }

    Shortcut {
        sequence: "Alt+Right"
        enabled: !root.dialogOpen
        onActivated: pathNavigator.forward()
    }

    Shortcut {
        sequence: "Alt+Up"
        enabled: !root.dialogOpen
        onActivated: pathNavigator.up()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: root.visibility === Window.Maximized ? 0 : 32

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            enabled: !root.dialogOpen

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
                        onDetailsRequested: path => detailsDialog.open(path)
                        onRenameRequested: path => {
                            root.renamePath = path
                            nameDialog.open(Tr.t("Rename"), Tr.t("Rename"), path.substring(path.lastIndexOf("/") + 1))
                        }
                        onNewFolderRequested: {
                            root.renamePath = ""
                            nameDialog.open(Tr.t("New folder"), Tr.t("Create"), "")
                        }
                        anchors.fill: parent
                        navigator: pathNavigator
                        directory: dirModel
                    }
                }

                DetailsPanel {
                    Layout.preferredWidth: 332
                    Layout.fillHeight: true
                    visible: Settings.detailsPanel && root.detailsVisible
                    path: dirModel.selectedPath
                    onCloseRequested: root.dismissedDetails = dirModel.selectedPath
                    onOpenRequested: path => pathNavigator.open(path)
                }
            }
        }

        DetailsDialog {
            id: detailsDialog
            anchors.fill: parent
            radius: parent.radius
            onCloseRequested: visible = false
            onOpenRequested: path => pathNavigator.open(path)
            onVisibleChanged: if (!visible) page.forceActiveFocus()
        }

        NameDialog {
            id: nameDialog
            anchors.fill: parent
            radius: parent.radius
            onCloseRequested: visible = false
            onAccepted: name => {
                const error = root.renamePath !== ""
                    ? fileOps.rename(root.renamePath, name)
                    : fileOps.createFolder(pathNavigator.path, name)
                if (error === "")
                    visible = false
                else
                    nameDialog.error = error
            }
            onVisibleChanged: if (!visible) page.forceActiveFocus()
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
