import QtQuick
import QtQuick.Layouts
import Sanar.Filer
import Sanar.Style

Item {
    id: root

    required property Window window

    property alias search: search
    property bool canGoBack: false
    property bool canGoForward: false
    property bool canGoUp: false

    signal backRequested
    signal forwardRequested
    signal upRequested
    signal settingsRequested

    implicitHeight: 72

    DragHandler {
        target: null
        onActiveChanged: if (active) root.window.startSystemMove()
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onDoubleTapped: root.window.visibility === Window.Maximized ? root.window.showNormal()
                                                                    : root.window.showMaximized()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Item {
            Layout.preferredWidth: 236
            Layout.fillHeight: true

            NavigationButtons {
                anchors.verticalCenter: parent.verticalCenter
                canGoBack: root.canGoBack
                canGoForward: root.canGoForward
                canGoUp: root.canGoUp
                onBackRequested: root.backRequested()
                onForwardRequested: root.forwardRequested()
                onUpRequested: root.upRequested()
            }
        }

        SearchField {
            id: search
            Layout.fillWidth: true
            Layout.maximumWidth: 720
        }

        Item { Layout.fillWidth: true }

        IconButton {
            icon: "settings"
            label: Tr.t("Settings")
            onClicked: root.settingsRequested()
        }

        WindowControls {
            window: root.window
        }
    }
}
