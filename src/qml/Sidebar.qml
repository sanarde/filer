pragma ComponentBehavior: Bound
import QtQuick
import Sanar.Filer

Flickable {
    id: root

    property string currentPath

    signal pathRequested(string path)

    contentHeight: column.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    PlacesModel {
        id: places
    }

    DevicesModel {
        id: devices
    }

    Column {
        id: column
        width: root.width
        spacing: 4

        Repeater {
            model: places

            NavItem {
                required property var model

                width: column.width
                icon: model.icon
                label: model.label
                selected: model.path === root.currentPath
                onClicked: root.pathRequested(model.path)
            }
        }

        Text {
            topPadding: 20
            leftPadding: 16
            bottomPadding: 8
            text: Tr.t("Devices")
            color: Theme.onSurfaceVariant
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Repeater {
            model: devices

            Loader {
                id: loader

                required property var model

                width: column.width
                sourceComponent: model.primary ? card : row

                Component {
                    id: card

                    DeviceCard {
                        icon: loader.model.icon
                        label: loader.model.label
                        usedText: loader.model.usedText
                        usedFraction: loader.model.usedFraction
                        onClicked: root.pathRequested(loader.model.path)
                    }
                }

                Component {
                    id: row

                    NavItem {
                        icon: loader.model.icon
                        label: loader.model.label
                        selected: loader.model.path === root.currentPath
                        onClicked: root.pathRequested(loader.model.path)
                    }
                }
            }
        }
    }
}
