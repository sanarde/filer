import QtQuick
import Sanar.Filer

Row {
    spacing: 2

    signal backRequested
    signal forwardRequested
    signal upRequested

    property bool canGoBack: false
    property bool canGoForward: false
    property bool canGoUp: false

    IconButton {
        width: 52
        icon: "arrow_back"
        iconSize: 20
        label: "Back"
        enabled: parent.canGoBack
        color: Theme.surfaceHigh
        hoverColor: Theme.surfaceHighest
        iconColor: Theme.onSurface
        radius: 8
        topLeftRadius: 20
        bottomLeftRadius: 20
        onClicked: parent.backRequested()
    }

    IconButton {
        width: 52
        icon: "arrow_forward"
        iconSize: 20
        label: "Forward"
        enabled: parent.canGoForward
        color: Theme.surfaceHigh
        hoverColor: Theme.surfaceHighest
        iconColor: Theme.onSurface
        radius: 8
        onClicked: parent.forwardRequested()
    }

    IconButton {
        width: 52
        icon: "arrow_upward"
        iconSize: 20
        label: "Up"
        enabled: parent.canGoUp
        color: Theme.surfaceHigh
        hoverColor: Theme.surfaceHighest
        iconColor: Theme.onSurface
        radius: 8
        topRightRadius: 20
        bottomRightRadius: 20
        onClicked: parent.upRequested()
    }
}
