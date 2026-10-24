import QtQuick
import QtQuick.Layouts
import Sanar.Filer

Rectangle {
    id: root

    property alias text: input.text

    signal filtersRequested

    implicitHeight: 56
    radius: 28
    color: Theme.surfaceHigh

    function focusInput() {
        input.forceActiveFocus()
        input.selectAll()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 10
        spacing: 12

        Icon { name: "search" }

        TextInput {
            id: input
            Layout.fillWidth: true
            color: Theme.onSurface
            font.pixelSize: 16
            clip: true
            selectByMouse: true
            selectionColor: Theme.primaryContainer
            selectedTextColor: Theme.onPrimaryContainer
            Accessible.name: Tr.t("Search files")

            Text {
                anchors.fill: parent
                visible: !input.text && !input.activeFocus
                text: Tr.t("Search")
                color: Theme.onSurfaceVariant
                font: input.font
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            implicitWidth: hint.implicitWidth + 20
            implicitHeight: 28
            radius: 8
            color: Theme.surfaceHighest

            Text {
                id: hint
                anchors.centerIn: parent
                text: "Ctrl K"
                color: Theme.onSurfaceVariant
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        IconButton {
            icon: "tune"
            label: Tr.t("Search filters")
            onClicked: root.filtersRequested()
        }
    }

    Shortcut {
        sequence: "Ctrl+K"
        onActivated: root.focusInput()
    }
}
