import QtQuick
import QtQuick.Layouts
import Sanar.Filer

Rectangle {
    id: root

    property alias path: details.path

    signal closeRequested
    signal openRequested(string path)

    color: Theme.surface
    radius: 28
    clip: true

    FileDetails {
        id: details
    }

    component DetailRow: Item {
        id: row

        property string label
        property string value

        Layout.fillWidth: true
        visible: value !== ""
        implicitHeight: visible ? Math.max(labelText.implicitHeight, valueText.implicitHeight) + 24 : 0

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outlineVariant
            visible: row.y > 0
        }

        Text {
            id: labelText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: row.label
            color: Theme.onSurfaceVariant
            font.pixelSize: 14
        }

        Text {
            id: valueText
            anchors.left: labelText.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: row.value
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.Wrap
            color: Theme.onSurface
            font.pixelSize: 14
            font.weight: Font.Medium
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: Tr.t("Details")
                color: Theme.onSurface
                font.pixelSize: 20
                font.weight: Font.DemiBold
            }

            IconButton {
                icon: "close"
                label: Tr.t("Close panel")
                onClicked: root.closeRequested()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 176
            radius: 28
            color: Theme.surfaceHighest
            clip: true

            EntryThumb {
                anchors.fill: parent
                icon: details.icon
                kind: details.kind
            }

            Rectangle {
                visible: details.suffix !== ""
                x: 12
                y: parent.height - height - 12
                width: suffixText.implicitWidth + 24
                height: 28
                radius: 10
                color: Theme.background

                Text {
                    id: suffixText
                    anchors.centerIn: parent
                    text: details.suffix
                    color: Theme.onSurface
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
        }

        Column {
            Layout.fillWidth: true

            Text {
                width: parent.width
                text: details.name
                elide: Text.ElideMiddle
                color: Theme.onSurface
                font.pixelSize: 22
                font.weight: Font.DemiBold
                font.letterSpacing: -0.2
                font.variableAxes: ({ "wdth": 106 })
            }

            Text {
                width: parent.width
                text: details.description
                elide: Text.ElideRight
                color: Theme.onSurfaceVariant
                font.pixelSize: 14
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 48

            Accessible.role: Accessible.Button
            Accessible.name: Tr.t("Open")
            Accessible.onPressAction: root.openRequested(details.path)

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: Theme.primary
            }

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: Qt.alpha(Theme.onPrimary, 0.12)
                visible: openHover.hovered
            }

            Row {
                anchors.centerIn: parent
                spacing: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "open_in_new"
                    color: Theme.onPrimary
                    font.pixelSize: 20
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Tr.t("Open")
                    color: Theme.onPrimary
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
            }

            HoverHandler {
                id: openHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.openRequested(details.path)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            DetailRow {
                label: Tr.t("Size")
                value: details.sizeText
            }

            DetailRow {
                label: Tr.t("Modified")
                value: details.modifiedText
            }

            DetailRow {
                label: Tr.t("Created")
                value: details.createdText
            }

            DetailRow {
                label: Tr.t("Permissions")
                value: details.permissionsText
            }

            DetailRow {
                label: Tr.t("Location")
                value: details.locationText
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
