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
    signal contextMenuRequested(string path, point position)
    signal backgroundContextMenuRequested(point position)

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

    TapHandler {
        acceptedButtons: Qt.RightButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: point => root.backgroundContextMenuRequested(point.scenePosition)
    }

    GridView {
        id: grid
        visible: root.viewMode === "grid"
        anchors.fill: parent
        anchors.rightMargin: -root.gap
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: false
        Behavior on contentY {
            enabled: root.animateScroll
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
        cellWidth: root.cellWidth
        cellHeight: 170 + 12
        model: Settings.separateFolders ? files : root.directory
        header: Settings.separateFolders ? sectionHeader : null

        delegate: Item {
            id: cell

            required property var model

            readonly property Item tile: fileTile

            width: grid.cellWidth
            height: grid.cellHeight

            FileTile {
                id: fileTile
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
                onContextMenuRequested: position => root.contextMenuRequested(cell.model.path, position)
            }
        }
    }

    Component {
        id: sectionHeader

        Column {
            width: grid.width

            function folderTiles() {
                const tiles = []
                for (let i = 0; i < folderRepeater.count; ++i)
                    tiles.push(folderRepeater.itemAt(i))
                return tiles
            }

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
                    id: folderRepeater
                    model: folders

                    FolderTile {
                        required property var model
                        required property int index

                        width: root.cellWidth - root.gap
                        name: model.name
                        path: model.path
                        subtitle: root.itemCountText(model.itemCount)
                        scheme: index
                        selected: model.selected
                        onSelectRequested: mode => root.selectRequested(model.path, mode)
                        onOpened: root.openRequested(model.path)
                        onContextMenuRequested: position => root.contextMenuRequested(model.path, position)
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
        interactive: false
        Behavior on contentY {
            enabled: root.animateScroll
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }
        }
        spacing: 2
        model: root.directory

        delegate: FileRow {
            id: row

            required property var model

            width: list.width
            name: model.name
            path: model.path
            icon: model.icon
            directory: model.isDirectory
            typeText: model.typeLabel
            sizeText: model.isDirectory ? root.itemCountText(model.itemCount) : model.sizeText
            modified: model.modified
            selected: model.selected
            onSelectRequested: mode => root.selectRequested(model.path, mode)
            onOpened: root.openRequested(model.path)
            onContextMenuRequested: position => root.contextMenuRequested(model.path, position)
        }
    }

    readonly property bool bandActive: band.active
    readonly property Flickable view: viewMode === "list" ? list : grid

    property real scrollTarget: 0
    property bool animateScroll: false

    function scrollBy(delta, animated) {
        const top = view.originY
        const bottom = Math.max(top, top + view.contentHeight - view.height)
        animateScroll = animated
        if (!animated || Math.abs(view.contentY - scrollTarget) < 0.5)
            scrollTarget = view.contentY
        scrollTarget = Math.max(top, Math.min(bottom, scrollTarget - delta))
        view.contentY = scrollTarget
    }

    function visibleEntries() {
        const items = []
        if (viewMode === "list") {
            for (const child of list.contentItem.children) {
                if (child.path)
                    items.push(child)
            }
        } else {
            if (grid.headerItem)
                items.push(...grid.headerItem.folderTiles())
            for (const child of grid.contentItem.children) {
                if (child.tile)
                    items.push(child.tile)
            }
        }
        return items
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (event.pixelDelta.y !== 0)
                root.scrollBy(event.pixelDelta.y, false)
            else
                root.scrollBy(event.angleDelta.y / 120 * 180, true)
        }
    }

    Item {
        id: band

        property bool additive: false
        property var base: []
        property real startX: 0
        property real startContentY: 0
        property real currentX: 0
        property real currentY: 0
        readonly property real startY: startContentY - root.view.contentY
        readonly property real minX: Math.min(startX, currentX)
        readonly property real minY: Math.min(startY, currentY)
        readonly property real maxX: Math.max(startX, currentX)
        readonly property real maxY: Math.max(startY, currentY)
        readonly property bool active: dragPlain.active || dragAdditive.active

        function begin(handler, additive) {
            band.additive = additive
            band.base = additive ? root.directory.selectedPaths() : []
            band.startX = handler.centroid.pressPosition.x
            band.startContentY = handler.centroid.pressPosition.y + root.view.contentY
            track(handler)
        }

        function track(handler) {
            currentX = Math.max(0, Math.min(width, handler.centroid.position.x))
            currentY = Math.max(0, Math.min(height, handler.centroid.position.y))
            update()
        }

        function update() {
            const hits = []
            for (const item of root.visibleEntries()) {
                const origin = item.mapToItem(band, 0, 0)
                if (origin.x < maxX && origin.x + item.width > minX
                        && origin.y < maxY && origin.y + item.height > minY)
                    hits.push(item.path)
            }
            root.directory.selectPaths(additive ? base.concat(hits) : hits)
        }

        anchors.fill: parent
        z: 5

        Rectangle {
            visible: band.active && (band.maxX - band.minX > 3 || band.maxY - band.minY > 3)
            x: band.minX
            y: band.minY
            width: band.maxX - band.minX
            height: band.maxY - band.minY
            radius: 6
            color: Qt.alpha(Theme.primary, 0.14)
            border.width: 1
            border.color: Theme.primary
        }

        DragHandler {
            id: dragPlain
            target: null
            acceptedButtons: Qt.LeftButton
            acceptedModifiers: Qt.NoModifier
            onActiveChanged: if (active) band.begin(dragPlain, false)
            onCentroidChanged: if (active) band.track(dragPlain)
        }

        DragHandler {
            id: dragAdditive
            target: null
            acceptedButtons: Qt.LeftButton
            acceptedModifiers: Qt.ControlModifier
            onActiveChanged: if (active) band.begin(dragAdditive, true)
            onCentroidChanged: if (active) band.track(dragAdditive)
        }

        Timer {
            interval: 16
            repeat: true
            running: band.active && (band.currentY < 24 || band.currentY > band.height - 24)
            onTriggered: {
                root.scrollBy(band.currentY < 24 ? 14 : -14, false)
                band.update()
            }
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
