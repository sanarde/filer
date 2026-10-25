pragma ComponentBehavior: Bound

import QtQuick
import Sanar.Filer
import Sanar.Style

ListView {
    id: root

    property var crumbs: []

    signal crumbClicked(string path)

    implicitHeight: 32
    orientation: ListView.Horizontal
    clip: true
    interactive: contentWidth > width
    model: crumbs
    onCountChanged: positionViewAtEnd()
    onWidthChanged: positionViewAtEnd()

    delegate: Row {
        id: item

        required property var modelData
        required property int index
        readonly property bool current: index === root.count - 1

        height: root.height
        spacing: 2

        Icon {
            visible: item.index > 0
            height: parent.height
            name: "chevron_right"
            color: Theme.outline
            font.pixelSize: 18
        }

        Rectangle {
            height: parent.height
            width: label.implicitWidth + 20
            radius: 16
            color: hover.hovered && !item.current ? Qt.alpha(Theme.onSurface, 0.08) : "transparent"

            Row {
                id: label
                anchors.centerIn: parent
                spacing: 6

                Icon {
                    visible: item.modelData.root !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    name: item.modelData.root === "trash" ? "delete" : item.modelData.root === "recent" ? "history" : "home"
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 18
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: item.modelData.root === "home" ? Tr.t("Home")
                          : item.modelData.root === "trash" ? Tr.t("Trash")
                          : item.modelData.root === "recent" ? Tr.t("Recent") : item.modelData.label
                    color: item.current ? Theme.onSurface : Theme.onSurfaceVariant
                    font.pixelSize: 14
                    font.weight: item.current ? Font.Bold : Font.Medium
                }
            }

            HoverHandler {
                id: hover
                enabled: !item.current
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                enabled: !item.current
                onTapped: root.crumbClicked(item.modelData.path)
            }
        }
    }
}
