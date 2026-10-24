import QtQuick
import Sanar.Filer

Column {
    id: root

    spacing: 16

    Item {
        width: parent.width
        height: 120

        Rectangle {
            anchors.centerIn: parent
            width: 96
            height: 96
            color: Theme.primary
            topLeftRadius: 36
            topRightRadius: 36
            bottomRightRadius: 36
            bottomLeftRadius: 10

            Icon {
                anchors.centerIn: parent
                name: "folder"
                filled: true
                color: Theme.onPrimary
                font.pixelSize: 56
            }
        }
    }

    Column {
        width: parent.width

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Sanar Filer"
            color: Theme.onSurface
            font.pixelSize: 28
            font.weight: Font.Bold
            font.variableAxes: ({ "wdth": 110 })
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Tr.t("Version") + " " + Qt.application.version
            color: Theme.onSurfaceVariant
            font.pixelSize: 14
        }
    }

    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: Tr.t("File manager for SanarDE, part of NurOS.")
        color: Theme.onSurface
        font.pixelSize: 14
    }

    Column {
        width: parent.width

        Repeater {
            model: [
                { label: Tr.t("License"), value: "GNU GPL v3.0" },
                { label: Tr.t("Toolkit"), value: "Qt Quick" }
            ]

            Item {
                id: row

                required property var modelData
                required property int index

                width: parent.width
                height: 48

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.outlineVariant
                    visible: row.index > 0
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.label
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 14
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.value
                    color: Theme.onSurface
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
            }
        }
    }
}
