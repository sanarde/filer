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
        onFinished: (success, error) => root.operationError = error
        onBusyChanged: if (busy) root.operationError = ""
    }

    property string operationError

    readonly property string operationTitle: {
        switch (fileOps.kind) {
        case FileOperations.Copy: return Tr.t("Copying")
        case FileOperations.Move: return Tr.t("Moving")
        case FileOperations.Trash: return Tr.t("Moving to trash")
        case FileOperations.Restore: return Tr.t("Restoring")
        default: return Tr.t("Deleting")
        }
    }

    property string renamePath
    property var clipboard: []
    property bool clipboardCut: false
    property string confirmAction
    property var pendingPaths: []
    readonly property bool inTrash: pathNavigator.crumbs[0].root === "trash"

    function copySelection(cut) {
        const paths = dirModel.selectedPaths()
        if (paths.length === 0)
            return
        clipboard = paths
        clipboardCut = cut
    }

    function paste() {
        if (clipboard.length === 0 || inTrash)
            return
        const conflicts = fileOps.conflicts(clipboard, pathNavigator.path)
        if (conflicts.length === 0) {
            runPaste(FileOperations.KeepBoth)
            return
        }
        confirmAction = "paste"
        confirmDialog.open(Tr.t("Name conflict"),
                           Tr.n("%1 item already exists in this folder.", "%1 items already exist in this folder.", conflicts.length)
                               .replace("%1", conflicts.length),
                           [Tr.t("Replace"), Tr.t("Skip"), Tr.t("Keep both")], 2)
    }

    function runPaste(conflict) {
        if (clipboardCut) {
            fileOps.move(clipboard, pathNavigator.path, conflict)
            clipboard = []
        } else {
            fileOps.copy(clipboard, pathNavigator.path, conflict)
        }
    }

    function deleteSelection(permanent) {
        const paths = dirModel.selectedPaths()
        if (paths.length === 0)
            return
        if (!permanent && !inTrash) {
            fileOps.trash(paths)
            return
        }
        pendingPaths = paths
        confirmAction = "delete"
        confirmDialog.open(Tr.t("Delete permanently"),
                           Tr.n("Delete %1 item permanently? This cannot be undone.", "Delete %1 items permanently? This cannot be undone.", paths.length)
                               .replace("%1", paths.length),
                           [Tr.t("Delete")], 0)
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
    property bool detailsVisible: false
    readonly property bool dialogOpen: settingsDialog.visible || detailsDialog.visible || nameDialog.visible || confirmDialog.visible

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
        sequences: [StandardKey.Copy]
        enabled: page.activeFocus && !root.dialogOpen && !root.inTrash
        onActivated: root.copySelection(false)
    }

    Shortcut {
        sequences: [StandardKey.Cut]
        enabled: page.activeFocus && !root.dialogOpen && !root.inTrash
        onActivated: root.copySelection(true)
    }

    Shortcut {
        sequences: [StandardKey.Paste]
        enabled: page.activeFocus && !root.dialogOpen
        onActivated: root.paste()
    }

    Shortcut {
        sequences: [StandardKey.Delete]
        enabled: page.activeFocus && !root.dialogOpen
        onActivated: root.deleteSelection(false)
    }

    Shortcut {
        sequence: "Shift+Delete"
        enabled: page.activeFocus && !root.dialogOpen
        onActivated: root.deleteSelection(true)
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
                        canPaste: root.clipboard.length > 0
                        inTrash: root.inTrash
                        onCopyRequested: root.copySelection(false)
                        onCutRequested: root.copySelection(true)
                        onPasteRequested: root.paste()
                        onDeleteRequested: root.deleteSelection(false)
                        onRestoreRequested: fileOps.restore(dirModel.selectedPaths())
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

        OperationPanel {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            busy: fileOps.busy
            progress: fileOps.progress
            title: root.operationTitle
            detail: fileOps.currentName
            error: root.operationError
            onCancelRequested: fileOps.cancel()
            onDismissed: root.operationError = ""
        }

        ConfirmDialog {
            id: confirmDialog
            anchors.fill: parent
            radius: parent.radius
            onCloseRequested: visible = false
            onChosen: index => {
                visible = false
                if (root.confirmAction === "paste")
                    root.runPaste(index)
                else
                    fileOps.remove(root.pendingPaths)
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
