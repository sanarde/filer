import QtQuick
import Sanar.Filer

Item {
    id: root

    required property Navigator navigator
    required property DirectoryModel directory

    focus: true
    Component.onCompleted: forceActiveFocus()

    Keys.onEscapePressed: directory.clearSelection()
    Keys.onReturnPressed: openSelected()
    Keys.onEnterPressed: openSelected()

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
        onSortMenuRequested: sortMenu.visible = !sortMenu.visible
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
        anchors.bottom: parent.bottom
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        directory: root.directory
        viewMode: Settings.viewMode
        onOpenRequested: path => root.navigator.open(path)
        onSelectRequested: (path, mode) => {
            root.forceActiveFocus()
            root.directory.select(path, mode)
        }
        onBackgroundClicked: {
            root.forceActiveFocus()
            root.directory.clearSelection()
        }
    }

    SelectionBar {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        count: root.directory.selectedCount
        onCleared: root.directory.clearSelection()
    }

    MouseArea {
        anchors.fill: parent
        visible: sortMenu.visible
        onClicked: sortMenu.visible = false
    }

    SortMenu {
        id: sortMenu
        visible: false
        x: header.x + header.sortButtonX
        y: header.y + header.height + 4
        onClosed: visible = false
    }
}
