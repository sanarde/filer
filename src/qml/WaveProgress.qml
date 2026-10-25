import QtQuick
import QtQuick.Shapes
import Sanar.Filer
import Sanar.Style

Item {
    id: root

    property real value: 0

    readonly property int segments: Math.max(1, Math.round(value * (width - 7) / 10))
    readonly property real waveEnd: 3 + 10 * segments

    implicitWidth: 204
    implicitHeight: 14

    Shape {
        anchors.fill: parent

        ShapePath {
            strokeColor: Theme.primary
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathSvg {
                path: "M3 7 q5 -5 10 0" + " t10 0".repeat(root.segments - 1)
            }
        }

        ShapePath {
            strokeColor: Theme.outlineVariant
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: root.waveEnd + 8
            startY: 7

            PathLine {
                x: Math.max(root.waveEnd + 8, root.width - 11)
                y: 7
            }
        }
    }

    Rectangle {
        x: root.width - 6
        y: 5
        width: 4
        height: 4
        radius: 2
        color: Theme.primary
    }
}
