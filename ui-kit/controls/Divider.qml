import QtQuick

import Sber.Theme

Rectangle {
    property bool vertical: false
    implicitWidth: vertical ? 1 : parent.width
    implicitHeight: vertical ? parent.height : 1
    width: implicitWidth
    height: implicitHeight
    color: Theme.Palette.Surface.Default.SolidSecondary
}
