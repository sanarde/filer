import QtQuick
import Sanar.Filer
import Sanar.Style

Item {
    id: root

    required property DirectoryModel directory
    property string title

    signal sortMenuRequested

    readonly property string sortLabel: {
        switch (Settings.sortKey) {
        case DirectoryModel.SortByModified:
            return Tr.t("By date")
        case DirectoryModel.SortBySize:
            return Tr.t("By size")
        case DirectoryModel.SortByType:
            return Tr.t("By type")
        }
        return Tr.t("By name")
    }
    readonly property int itemCount: directory.folderCount + directory.fileCount
    readonly property real sortButtonX: controls.x + sortButton.x

    implicitHeight: 62

    Column {
        anchors.left: parent.left
        anchors.right: controls.left
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom

        Text {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            color: Theme.onSurface
            font.pixelSize: 38
            font.weight: Font.Bold
            font.letterSpacing: -0.5
            font.variableAxes: ({ "wdth": 110 })
        }

        Text {
            text: Tr.n("%1 item", "%1 items", root.itemCount).replace("%1", root.itemCount)
                  + " · " + root.directory.totalSizeText
            color: Theme.onSurfaceVariant
            font.pixelSize: 14
        }
    }

    Row {
        id: controls
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 8

        Item {
            id: sortButton
            width: sortRow.implicitWidth + 32
            height: 48

            Accessible.role: Accessible.Button
            Accessible.name: root.sortLabel
            Accessible.onPressAction: root.sortMenuRequested()

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: sortHover.hovered ? Qt.tint(Theme.surfaceHigh, Qt.alpha(Theme.onSurface, 0.08))
                                         : Theme.surfaceHigh
            }

            Row {
                id: sortRow
                anchors.centerIn: parent
                spacing: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "swap_vert"
                    color: Theme.onSurface
                    font.pixelSize: 20
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.sortLabel
                    color: Theme.onSurface
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
            }

            HoverHandler {
                id: sortHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.sortMenuRequested()
            }
        }

        ViewSwitcher {
            id: switcher
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
