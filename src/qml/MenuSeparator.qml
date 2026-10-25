import QtQuick
import Sanar.Filer
import Sanar.Style

Item {
    width: parent ? parent.width : 220
    height: 1

    Rectangle {
        x: 16
        width: parent.width - 32
        height: 1
        color: Theme.outlineVariant
    }
}
