import QtQuick
import Sanar.Filer

Row {
    id: root

    spacing: 2

    component ModeButton: Item {
        id: button

        required property int mode
        property string icon
        property string label
        property int radiusLeft: 8
        property int radiusRight: 8
        readonly property bool selected: Settings.themeMode === mode

        width: 112
        height: 48

        Accessible.role: Accessible.RadioButton
        Accessible.name: label
        Accessible.checked: selected
        Accessible.onPressAction: Settings.themeMode = button.mode

        Rectangle {
            anchors.fill: parent
            color: button.selected ? Theme.secondaryContainer
                                   : hover.hovered ? Qt.tint(Theme.surfaceHigh, Qt.alpha(Theme.onSurface, 0.08))
                                                   : Theme.surfaceHigh
            topLeftRadius: button.radiusLeft
            bottomLeftRadius: button.radiusLeft
            topRightRadius: button.radiusRight
            bottomRightRadius: button.radiusRight
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: button.selected ? "check" : button.icon
                color: button.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
                font.pixelSize: 20
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.label
                color: button.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
        }

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: Settings.themeMode = button.mode
        }
    }

    ModeButton {
        mode: Theme.System
        icon: "brightness_auto"
        label: Tr.t("System")
        radiusLeft: 24
    }

    ModeButton {
        mode: Theme.Light
        icon: "light_mode"
        label: Tr.t("Light")
    }

    ModeButton {
        mode: Theme.Dark
        icon: "dark_mode"
        label: Tr.t("Dark")
        radiusRight: 24
    }
}
