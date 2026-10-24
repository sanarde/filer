import QtQuick
import Sanar.Filer

Text {
    property string name
    property bool filled: false

    text: Icons.glyph(name)
    color: Theme.onSurfaceVariant
    font.family: "Material Symbols Rounded"
    font.pixelSize: 24
    font.variableAxes: ({ "FILL": filled ? 1 : 0, "wght": 400, "GRAD": 0, "opsz": 24 })
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
