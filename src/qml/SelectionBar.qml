import QtQuick
import Sanar.Filer

Rectangle {
    id: root

    property int count: 0

    signal cleared

    visible: count > 0
    implicitWidth: row.implicitWidth + 16
    implicitHeight: 64
    radius: 32
    color: Theme.primaryContainer

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            width: 48
            height: 48
            icon: "close"
            label: Tr.t("Clear selection")
            iconColor: Theme.onPrimaryContainer
            hoverColor: Qt.alpha(Theme.onPrimaryContainer, 0.12)
            onClicked: root.cleared()
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 2
            rightPadding: 14
            text: Tr.n("%1 item selected", "%1 items selected", root.count).replace("%1", root.count)
            color: Theme.onPrimaryContainer
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
    }
}
