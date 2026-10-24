import QtQuick
import Sanar.Filer

Item {
    id: root

    readonly property bool hovered: hover.hovered

    signal selectRequested(int mode)
    signal opened
    signal contextMenuRequested(point position)

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedModifiers: Qt.NoModifier
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.selectRequested(DirectoryModel.SelectReplace)
        onDoubleTapped: root.opened()
    }

    TapHandler {
        acceptedModifiers: Qt.ControlModifier
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.selectRequested(DirectoryModel.SelectToggle)
    }

    TapHandler {
        acceptedModifiers: Qt.ShiftModifier
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.selectRequested(DirectoryModel.SelectRange)
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: point => root.contextMenuRequested(point.scenePosition)
    }
}
