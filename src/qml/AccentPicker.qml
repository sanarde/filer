import QtQuick
import Sanar.Filer

Row {
    id: root

    spacing: 8

    Repeater {
        model: [
            { palette: Theme.Teal, name: Tr.t("Teal") },
            { palette: Theme.Coral, name: Tr.t("Coral") },
            { palette: Theme.Indigo, name: Tr.t("Indigo") },
            { palette: Theme.Green, name: Tr.t("Green") }
        ]

        Item {
            id: swatch

            required property var modelData
            readonly property bool selected: Settings.palette === modelData.palette

            width: 88
            height: 72

            Accessible.role: Accessible.RadioButton
            Accessible.name: modelData.name
            Accessible.checked: selected
            Accessible.onPressAction: Settings.palette = swatch.modelData.palette

            Rectangle {
                id: circle
                anchors.horizontalCenter: parent.horizontalCenter
                width: 48
                height: 48
                radius: 24
                color: Theme.swatch(swatch.modelData.palette)
                border.width: swatch.selected ? 3 : 0
                border.color: Theme.onSurface

                Icon {
                    anchors.centerIn: parent
                    visible: swatch.selected
                    name: "check"
                    filled: true
                    color: Theme.surface
                    font.pixelSize: 24
                }
            }

            Text {
                anchors.top: circle.bottom
                anchors.topMargin: 6
                anchors.horizontalCenter: parent.horizontalCenter
                text: swatch.modelData.name
                color: swatch.selected ? Theme.onSurface : Theme.onSurfaceVariant
                font.pixelSize: 12
                font.weight: swatch.selected ? Font.DemiBold : Font.Medium
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Settings.palette = swatch.modelData.palette
            }
        }
    }
}
