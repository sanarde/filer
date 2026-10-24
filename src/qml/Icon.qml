import QtQuick
import Sanar.Filer

Text {
    property string name
    property bool filled: false

    text: Icons.glyph(name)
    color: Theme.onSurfaceVariant
    font.family: filled ? "Material Symbols Rounded Filled" : "Material Symbols Rounded"
    font.pixelSize: 24
    font.hintingPreference: Font.PreferNoHinting
    renderType: Text.CurveRendering
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
