import QtQuick
import Sanar.Filer
import Sanar.Style

Row {
    id: root

    property string title
    property int count

    topPadding: 20
    bottomPadding: 8
    spacing: 8

    Text {
        anchors.baseline: countText.baseline
        text: root.title
        color: Theme.onSurface
        font.pixelSize: 16
        font.weight: Font.DemiBold
    }

    Text {
        id: countText
        text: root.count
        color: Theme.onSurfaceVariant
        font.pixelSize: 13
        font.weight: Font.Medium
    }
}
