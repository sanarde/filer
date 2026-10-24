import QtQuick
import QtQuick.Layouts
import Sanar.Filer

Item {
    id: root

    property bool aboutOpen: false
    property real radius: 0

    signal closeRequested

    function open() {
        aboutOpen = false
        visible = true
        forceActiveFocus()
    }

    visible: false
    focus: true

    Shortcut {
        sequence: "Esc"
        enabled: root.visible
        onActivated: root.closeRequested()
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha("black", 0.5)

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onClicked: root.closeRequested()
            onWheel: wheel => wheel.accepted = true
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(560, parent.width - 48)
        height: Math.min(content.implicitHeight + 48, parent.height - 48)
        radius: 28
        color: Theme.surface
        clip: true

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onWheel: wheel => wheel.accepted = true
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true

                IconButton {
                    visible: root.aboutOpen
                    icon: "arrow_back"
                    label: Tr.t("Back")
                    onClicked: root.aboutOpen = false
                }

                Text {
                    Layout.fillWidth: true
                    text: root.aboutOpen ? Tr.t("About") : Tr.t("Settings")
                    color: Theme.onSurface
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }

                IconButton {
                    icon: "close"
                    label: Tr.t("Close")
                    onClicked: root.closeRequested()
                }
            }

            ColumnLayout {
                visible: !root.aboutOpen
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: Tr.t("Theme")
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                ThemeModeSelector {}

                Text {
                    Layout.topMargin: 12
                    text: Tr.t("Accent color")
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                AccentPicker {}

                Text {
                    Layout.topMargin: 12
                    text: Tr.t("Files")
                    color: Theme.onSurfaceVariant
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                SettingsSwitch {
                    Layout.fillWidth: true
                    label: Tr.t("Show hidden files")
                    checked: Settings.showHidden
                    onToggled: value => Settings.showHidden = value
                }

                SettingsSwitch {
                    Layout.fillWidth: true
                    label: Tr.t("Separate folders and files")
                    description: Tr.t("Show folders first, in their own section")
                    checked: Settings.separateFolders
                    onToggled: value => Settings.separateFolders = value
                }

                NavItem {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    icon: "info"
                    label: Tr.t("About Sanar Filer")
                    onClicked: root.aboutOpen = true
                }
            }

            AboutPage {
                visible: root.aboutOpen
                Layout.fillWidth: true
            }
        }
    }
}
