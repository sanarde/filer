pragma ComponentBehavior: Bound

import QtQuick
import Sanar.Filer

Item {
    id: root

    required property DirectoryModel directory
    property string viewMode: "grid"

    signal openRequested(string path)
    signal selectRequested(string path, int mode)
    signal backgroundClicked

    readonly property int gap: 12
    readonly property int columns: Math.max(1, Math.floor((width + gap) / (200 + gap)))
    readonly property real cellWidth: (width + gap) / columns

    EntrySectionModel {
        id: folders
        sourceModel: root.directory
        directories: true
    }

    EntrySectionModel {
        id: files
        sourceModel: root.directory
        directories: false
    }

    function itemCountText(count) {
        return Tr.n("%1 item", "%1 items", count).replace("%1", count)
    }

    function fileSubtitle(typeLabel, sizeText) {
        return typeLabel ? typeLabel + " · " + sizeText : sizeText
    }

    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.backgroundClicked()
    }

    GridView {
        id: grid
        visible: root.viewMode === "grid"
        anchors.fill: parent
        anchors.rightMargin: -root.gap
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cellWidth: root.cellWidth
        cellHeight: 170 + 12
        model: Settings.separateFolders ? files : root.directory
        header: Settings.separateFolders ? sectionHeader : null

        delegate: Item {
            id: cell

            required property var model

            width: grid.cellWidth
            height: grid.cellHeight

            FileTile {
                width: parent.width - root.gap
                height: 170
                name: cell.model.name
                subtitle: cell.model.isDirectory ? root.itemCountText(cell.model.itemCount)
                                                 : root.fileSubtitle(cell.model.typeLabel, cell.model.sizeText)
                icon: cell.model.icon
                path: cell.model.path
                kind: cell.model.kind
                selected: cell.model.selected
                onSelectRequested: mode => root.selectRequested(cell.model.path, mode)
                onOpened: root.openRequested(cell.model.path)
            }
        }
    }

    Component {
        id: sectionHeader

        Column {
            width: grid.width

            SectionTitle {
                visible: root.directory.folderCount > 0
                title: Tr.t("Folders")
                count: root.directory.folderCount
            }

            Grid {
                columns: root.columns
                columnSpacing: root.gap
                rowSpacing: root.gap
                width: grid.width

                Repeater {
                    model: folders

                    FolderTile {
                        required property var model
                        required property int index

                        width: root.cellWidth - root.gap
                        name: model.name
                        subtitle: root.itemCountText(model.itemCount)
                        scheme: index
                        selected: model.selected
                        onSelectRequested: mode => root.selectRequested(model.path, mode)
                        onOpened: root.openRequested(model.path)
                    }
                }
            }

            SectionTitle {
                visible: root.directory.fileCount > 0
                title: Tr.t("Files")
                count: root.directory.fileCount
            }
        }
    }

    ListView {
        id: list
        visible: root.viewMode === "list"
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: 2
        model: root.directory

        delegate: FileRow {
            id: row

            required property var model

            width: list.width
            name: model.name
            icon: model.icon
            directory: model.isDirectory
            typeText: model.typeLabel
            sizeText: model.isDirectory ? root.itemCountText(model.itemCount) : model.sizeText
            modified: model.modified
            selected: model.selected
            onSelectRequested: mode => root.selectRequested(model.path, mode)
            onOpened: root.openRequested(model.path)
        }
    }

    Text {
        anchors.centerIn: parent
        visible: text !== ""
        color: Theme.onSurfaceVariant
        font.pixelSize: 16
        text: {
            switch (root.directory.error) {
            case DirectoryModel.NotFound:
                return Tr.t("Folder not found")
            case DirectoryModel.AccessDenied:
                return Tr.t("Access denied")
            }
            return root.directory.folderCount + root.directory.fileCount === 0 ? Tr.t("Nothing here") : ""
        }
    }
}
