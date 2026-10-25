import QtQuick
import Sanar.Filer
import Sanar.Style

Item {
    id: root

    property string label
    property string description
    property bool checked: false

    signal toggled(bool checked)

    implicitHeight: Math.max(texts.implicitHeight, 32) + 20

    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checked: checked
    Accessible.onToggleAction: root.toggled(!root.checked)

    Column {
        id: texts
        anchors.left: parent.left
        anchors.right: track.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: root.label
            color: Theme.onSurface
            font.pixelSize: 14
            font.weight: Font.Medium
        }

        Text {
            visible: root.description !== ""
            width: parent.width
            text: root.description
            wrapMode: Text.Wrap
            color: Theme.onSurfaceVariant
            font.pixelSize: 12
        }
    }

    Rectangle {
        id: track
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 52
        height: 32
        radius: 16
        color: root.checked ? Theme.primary : Theme.surfaceHighest
        border.width: root.checked ? 0 : 2
        border.color: Theme.outline

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 4 : (parent.border.width + 6)
            width: root.checked ? 24 : 16
            height: width
            radius: width / 2
            color: root.checked ? Theme.onPrimary : Theme.outline
        }
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: root.toggled(!root.checked)
    }
}
