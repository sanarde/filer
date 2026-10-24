import QtQuick
import QtQuick.Effects
import Sanar.Filer

Item {
    id: root

    property string icon
    property int kind: FileKind.Other
    property string path
    property real radius: 0

    readonly property bool hasImage: kind === FileKind.Image && path !== "" && picture.status === Image.Ready

    Rectangle {
        visible: !root.hasImage && root.kind === FileKind.Document
        anchors.centerIn: parent
        width: 76
        height: 88
        radius: 10
        color: Theme.surfaceLowest

        Column {
            x: 10
            y: 12
            spacing: 6

            Repeater {
                model: [0.6, 1, 1, 0.8, 0.5]

                Rectangle {
                    required property real modelData
                    required property int index

                    width: (76 - 20) * modelData
                    height: index === 0 ? 6 : 4
                    radius: 2
                    color: index === 0 ? Theme.primary : Theme.outlineVariant
                }
            }
        }
    }

    Rectangle {
        visible: !root.hasImage && root.kind !== FileKind.Document
        anchors.centerIn: parent
        width: 72
        height: 72
        color: [Theme.primaryContainer, Theme.primaryContainer, Theme.surfaceHigh,
                Theme.secondaryContainer, Theme.tertiaryContainer, Theme.primaryContainer,
                Theme.tertiaryContainer, Theme.surfaceHigh][root.kind]
        topLeftRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 26 : 8)
        topRightRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 8 : 26)
        bottomLeftRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 8 : 26)
        bottomRightRadius: root.kind === FileKind.Code ? 36 : (root.kind === FileKind.Archive ? 26 : 8)

        Icon {
            anchors.centerIn: parent
            name: root.icon
            filled: true
            color: [Theme.onPrimaryContainer, Theme.onPrimaryContainer, Theme.onSurface,
                    Theme.onSecondaryContainer, Theme.onTertiaryContainer,
                    Theme.onPrimaryContainer, Theme.onTertiaryContainer,
                    Theme.onSurface][root.kind]
            font.pixelSize: 36
        }
    }

    Image {
        id: picture
        anchors.fill: parent
        visible: false
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectCrop
        source: root.kind === FileKind.Image && root.path !== "" && root.width > 0
                ? "image://thumb/" + encodeURIComponent(root.path) : ""
        sourceSize: Qt.size(Math.ceil(root.width * Screen.devicePixelRatio),
                            Math.ceil(root.height * Screen.devicePixelRatio))
    }

    Item {
        id: mask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: root.radius
        }
    }

    MultiEffect {
        anchors.fill: parent
        visible: root.hasImage
        source: picture
        maskEnabled: true
        maskSource: mask
    }
}
