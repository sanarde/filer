import QtQuick
import Sanar.Filer
import Sanar.Style

Rectangle {
    id: root

    required property DirectoryModel directory

    signal cleared

    readonly property bool single: directory.selectedCount === 1

    visible: directory.selectedCount > 0
    implicitHeight: 40
    radius: 20
    color: Theme.surface

    FileDetails {
        id: details
        path: root.directory.selectedPath
    }

    IconButton {
        id: clearButton
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 32
        icon: "close"
        iconSize: 18
        label: Tr.t("Clear selection")
        onClicked: root.cleared()
    }

    Text {
        anchors.left: clearButton.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideMiddle
        color: Theme.onSurfaceVariant
        font.pixelSize: 13
        text: root.single
              ? [details.name, details.description, details.sizeText, details.modifiedText]
                    .filter(part => part !== "").join(" · ")
              : Tr.n("%1 item selected", "%1 items selected", root.directory.selectedCount)
                    .replace("%1", root.directory.selectedCount) + " · " + root.directory.selectedSizeText
    }
}
