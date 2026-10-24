import QtQuick
import Sanar.Filer

Item {
    id: root

    property string name
    property string path
    property string subtitle
    property int scheme: 0

    property bool selected: false

    signal selectRequested(int mode)
    signal opened
    signal contextMenuRequested(point position)

    function pick(first, second, third, fourth) {
        switch (scheme % 4) {
        case 0:
            return first
        case 1:
            return second
        case 2:
            return third
        }
        return fourth
    }

    readonly property color tileColor: pick(Theme.primaryContainer, Theme.secondaryContainer,
                                            Theme.tertiaryContainer, Theme.surfaceHigh)
    readonly property color textColor: pick(Theme.onPrimaryContainer, Theme.onSecondaryContainer,
                                            Theme.onTertiaryContainer, Theme.onSurface)
    readonly property color badgeColor: pick(Theme.primary, Theme.onSecondaryContainer,
                                             Theme.tertiary, Theme.surfaceHighest)
    readonly property color badgeIconColor: pick(Theme.onPrimary, Theme.secondaryContainer,
                                                 Theme.tertiaryContainer, Theme.onSurface)

    implicitHeight: 64

    Accessible.role: Accessible.Button
    Accessible.name: name
    Accessible.onPressAction: root.opened()

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.tileColor
        border.width: root.selected ? 2 : 0
        border.color: Theme.primary
    }

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: Qt.alpha(root.textColor, 0.08)
        visible: input.hovered
    }

    Rectangle {
        id: badge
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        height: 44
        color: root.badgeColor
        topLeftRadius: [22, 15, 22, 22][root.scheme % 4]
        topRightRadius: [22, 15, 6, 22][root.scheme % 4]
        bottomLeftRadius: [22, 15, 6, 8][root.scheme % 4]
        bottomRightRadius: [22, 15, 22, 8][root.scheme % 4]

        Icon {
            anchors.centerIn: parent
            name: "folder"
            filled: true
            color: root.badgeIconColor
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: root.name
            elide: Text.ElideRight
            color: root.textColor
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }

        Text {
            width: parent.width
            text: root.subtitle
            elide: Text.ElideRight
            color: root.textColor
            opacity: 0.8
            font.pixelSize: 12
        }
    }

    EntryInput {
        id: input
        anchors.fill: parent
        onSelectRequested: mode => root.selectRequested(mode)
        onOpened: root.opened()
        onContextMenuRequested: position => root.contextMenuRequested(position)
    }
}
