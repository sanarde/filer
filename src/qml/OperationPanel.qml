import QtQuick
import Sanar.Filer

Rectangle {
    id: root

    property bool busy: false
    property real progress: 0
    property string title
    property string detail
    property string error
    property int queued: 0

    signal cancelRequested
    signal dismissed

    visible: busy || error !== ""
    width: Math.min(400, parent.width - 48)
    height: column.implicitHeight + 32
    radius: 20
    color: Theme.surfaceHighest
    border.width: 1
    border.color: Theme.outlineVariant

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = true
    }

    Column {
        id: column
        x: 20
        y: 16
        width: parent.width - 40 - 48
        spacing: 8

        Text {
            width: parent.width
            text: root.busy ? root.title : Tr.t("Operation failed")
            color: Theme.onSurface
            font.pixelSize: 16
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.busy ? root.detail : root.error
            color: Theme.onSurfaceVariant
            font.pixelSize: 14
            elide: root.busy ? Text.ElideMiddle : Text.ElideNone
            wrapMode: root.busy ? Text.NoWrap : Text.WordWrap
        }

        Text {
            visible: root.busy && root.queued > 0
            width: parent.width
            text: Tr.n("%1 more queued", "%1 more queued", root.queued).replace("%1", root.queued)
            color: Theme.onSurfaceVariant
            font.pixelSize: 13
        }

        WaveProgress {
            visible: root.busy
            width: parent.width
            value: root.progress
        }
    }

    IconButton {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 12
        icon: "close"
        label: root.busy ? Tr.t("Cancel") : Tr.t("Close")
        onClicked: root.busy ? root.cancelRequested() : root.dismissed()
    }
}
