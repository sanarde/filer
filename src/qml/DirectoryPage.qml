import QtQuick
import Sanar.Filer

Item {
    id: root

    required property Navigator navigator
    required property DirectoryModel directory

    focus: true
    Component.onCompleted: forceActiveFocus()

    Keys.onEscapePressed: {
        if (sortMenu.visible || contextMenu.visible)
            closeMenus()
        else
            directory.clearSelection()
    }
    Keys.onReturnPressed: openSelected()
    Keys.onEnterPressed: openSelected()

    property point sortMenuPosition: Qt.point(-1, -1)

    property string contextPath

    signal detailsRequested(string path)
    signal renameRequested(string path)
    signal newFolderRequested
    signal copyRequested
    signal cutRequested
    signal pasteRequested
    signal deleteRequested

    property bool canPaste: false
    property bool inTrash: false

    function closeMenus() {
        sortMenu.visible = false
        contextMenu.visible = false
    }

    function showContextMenu(position, path) {
        const local = root.mapFromItem(null, position.x, position.y)
        sortMenu.visible = false
        contextMenu.onEntry = path !== ""
        contextPath = path
        if (path !== "" && directory.selectedPaths().indexOf(path) < 0)
            directory.select(path, DirectoryModel.SelectReplace)
        contextMenu.x = Math.max(8, Math.min(local.x, root.width - contextMenu.width - 8))
        contextMenu.y = Math.max(8, Math.min(local.y, root.height - contextMenu.height - 8))
        contextMenu.visible = true
        root.forceActiveFocus()
    }

    function openSelected() {
        const paths = directory.selectedPaths()
        if (paths.length === 1)
            navigator.open(paths[0])
    }

    Shortcut {
        sequence: StandardKey.SelectAll
        enabled: root.activeFocus
        onActivated: root.directory.selectAll()
    }

    readonly property bool selecting: view.bandActive
    readonly property var crumbs: navigator.crumbs
    readonly property var lastCrumb: crumbs[crumbs.length - 1]

    Breadcrumbs {
        id: breadcrumbs
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 18
        anchors.rightMargin: 28
        anchors.topMargin: 20
        crumbs: root.crumbs
        onCrumbClicked: path => root.navigator.goTo(path)
    }

    DirectoryHeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: breadcrumbs.bottom
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        anchors.topMargin: 8
        directory: root.directory
        title: root.lastCrumb.root === "home" ? Tr.t("Home")
               : root.lastCrumb.root === "trash" ? Tr.t("Trash") : root.lastCrumb.label
        onSortMenuRequested: {
            root.sortMenuPosition = Qt.point(-1, -1)
            sortMenu.visible = !sortMenu.visible
        }
    }

    FilterChips {
        id: chips
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.leftMargin: 28
        anchors.topMargin: 16
        filter: root.directory.filter
        onFilterChanged: root.directory.filter = filter
    }

    DirectoryView {
        id: view
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: chips.bottom
        anchors.bottom: infoStrip.visible ? infoStrip.top : parent.bottom
        anchors.bottomMargin: infoStrip.visible ? 8 : 0
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        directory: root.directory
        viewMode: Settings.viewMode
        onOpenRequested: path => root.navigator.open(path)
        onSelectRequested: (path, mode) => {
            root.forceActiveFocus()
            root.directory.select(path, mode)
        }
        onContextMenuRequested: (path, position) => root.showContextMenu(position, path)
        onBackgroundContextMenuRequested: position => root.showContextMenu(position, "")
        onBackgroundClicked: {
            root.forceActiveFocus()
            root.directory.clearSelection()
        }
    }

    InfoStrip {
        id: infoStrip
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 12
        directory: root.directory
        onCleared: root.directory.clearSelection()
    }

    MouseArea {
        anchors.fill: parent
        visible: sortMenu.visible || contextMenu.visible
        acceptedButtons: Qt.AllButtons
        onClicked: root.closeMenus()
    }

    ContextMenu {
        id: contextMenu
        visible: false
        selectedCount: root.directory.selectedCount
        canPaste: root.canPaste
        inTrash: root.inTrash
        onOpenRequested: root.navigator.open(root.contextPath)
        onDetailsRequested: root.detailsRequested(root.contextPath)
        onRenameRequested: root.renameRequested(root.contextPath)
        onNewFolderRequested: root.newFolderRequested()
        onCopyRequested: root.copyRequested()
        onCutRequested: root.cutRequested()
        onPasteRequested: root.pasteRequested()
        onDeleteRequested: root.deleteRequested()
        onSelectAllRequested: root.directory.selectAll()
        onRefreshRequested: root.directory.reload()
        onSortRequested: {
            root.sortMenuPosition = Qt.point(contextMenu.x, contextMenu.y)
            sortMenu.visible = true
        }
        onClosed: visible = false
    }

    SortMenu {
        id: sortMenu
        visible: false
        x: root.sortMenuPosition.x >= 0 ? root.sortMenuPosition.x : header.x + header.sortButtonX
        y: root.sortMenuPosition.x >= 0 ? root.sortMenuPosition.y : header.y + header.height + 4
        onClosed: visible = false
    }
}
