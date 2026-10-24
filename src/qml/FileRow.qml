import QtQuick
import Sanar.Filer

Item {
    id: root

    property string name
    property string icon
    property bool directory: false
    property string typeText
    property string sizeText
    property date modified

    property bool selected: false

    signal selectRequested(int mode)
    signal opened

    implicitHeight: 56

    Accessible.role: Accessible.Button
    Accessible.name: name
    Accessible.onPressAction: root.opened()

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.selected ? Theme.secondaryContainer
                             : input.hovered ? Theme.surface : "transparent"
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        filled: true
        color: root.directory ? Theme.primary : Theme.onSurfaceVariant
    }

    Text {
        anchors.left: glyph.right
        anchors.leftMargin: 16
        anchors.right: dateText.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root.name
        elide: Text.ElideMiddle
        color: Theme.onSurface
        font.pixelSize: 14
        font.weight: Font.DemiBold
    }

    Text {
        id: dateText
        anchors.right: typeColumn.left
        anchors.verticalCenter: parent.verticalCenter
        width: 140
        text: root.modified.toLocaleString(Qt.locale(), Locale.ShortFormat)
        color: Theme.onSurfaceVariant
        font.pixelSize: 13
    }

    Text {
        id: typeColumn
        anchors.right: sizeColumn.left
        anchors.verticalCenter: parent.verticalCenter
        width: 80
        text: root.typeText
        color: Theme.onSurfaceVariant
        font.pixelSize: 13
    }

    Text {
        id: sizeColumn
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        width: 80
        horizontalAlignment: Text.AlignRight
        text: root.sizeText
        color: Theme.onSurfaceVariant
        font.pixelSize: 13
    }

    EntryInput {
        id: input
        anchors.fill: parent
        onSelectRequested: mode => root.selectRequested(mode)
        onOpened: root.opened()
    }
}
