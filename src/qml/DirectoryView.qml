pragma ComponentBehavior: Bound

import QtQuick
import Sanar.Filer

Item {
    id: root

    required property DirectoryModel directory
    property string viewMode: "grid"

    signal openRequested(string path)

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

    GridView {
        id: grid
        visible: root.viewMode === "grid"
        anchors.fill: parent
        anchors.rightMargin: -root.gap
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cellWidth: root.cellWidth
        cellHeight: 144 + 12
        model: files

        header: Column {
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

        delegate: Item {
            id: cell

            required property var model

            width: grid.cellWidth
            height: grid.cellHeight

            FileTile {
                width: parent.width - root.gap
                height: 144
                name: cell.model.name
                subtitle: root.fileSubtitle(cell.model.typeLabel, cell.model.sizeText)
                icon: cell.model.icon
                kind: cell.model.kind
                onOpened: root.openRequested(cell.model.path)
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
