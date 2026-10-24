pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root

    required property Window window

    readonly property int edge: 6
    readonly property int corner: 14

    enabled: window.visibility === Window.Windowed
    visible: enabled

    component Handle: Item {
        id: handle

        required property int edges
        property alias cursorShape: hover.cursorShape

        HoverHandler {
            id: hover
        }

        DragHandler {
            target: null
            onActiveChanged: if (active) root.window.startSystemResize(handle.edges)
        }
    }

    Handle {
        edges: Qt.TopEdge
        cursorShape: Qt.SizeVerCursor
        x: root.corner; y: 0
        width: root.width - 2 * root.corner; height: root.edge
    }
    Handle {
        edges: Qt.BottomEdge
        cursorShape: Qt.SizeVerCursor
        x: root.corner; y: root.height - root.edge
        width: root.width - 2 * root.corner; height: root.edge
    }
    Handle {
        edges: Qt.LeftEdge
        cursorShape: Qt.SizeHorCursor
        x: 0; y: root.corner
        width: root.edge; height: root.height - 2 * root.corner
    }
    Handle {
        edges: Qt.RightEdge
        cursorShape: Qt.SizeHorCursor
        x: root.width - root.edge; y: root.corner
        width: root.edge; height: root.height - 2 * root.corner
    }
    Handle {
        edges: Qt.TopEdge | Qt.LeftEdge
        cursorShape: Qt.SizeFDiagCursor
        x: 0; y: 0
        width: root.corner; height: root.corner
    }
    Handle {
        edges: Qt.TopEdge | Qt.RightEdge
        cursorShape: Qt.SizeBDiagCursor
        x: root.width - root.corner; y: 0
        width: root.corner; height: root.corner
    }
    Handle {
        edges: Qt.BottomEdge | Qt.LeftEdge
        cursorShape: Qt.SizeBDiagCursor
        x: 0; y: root.height - root.corner
        width: root.corner; height: root.corner
    }
    Handle {
        edges: Qt.BottomEdge | Qt.RightEdge
        cursorShape: Qt.SizeFDiagCursor
        x: root.width - root.corner; y: root.height - root.corner
        width: root.corner; height: root.corner
    }
}
