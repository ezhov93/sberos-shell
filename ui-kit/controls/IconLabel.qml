import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

Label {
    id: label

    horizontalAlignment: Text.AlignLeft
    verticalAlignment: Text.AlignVCenter

    property bool iconOnRight: false
    property int spacing: lineHeight <= Theme.Sizes.LineHeight.S ? 8 : 10
    leftPadding: icon.visible && !iconOnRight ? icon.width + (text != "" ? spacing : 0) : 0
    rightPadding: icon.visible && iconOnRight ? icon.width + (text != "" ? spacing : 0) : 0
    height: Math.max(implicitHeight, icon.height)
    visible: icon.source != "" || icon.name != "" || text

    property alias icon: icon
    Icon {
        id: icon
        x: label.iconOnRight ? label.width - size : 0
        anchors.verticalCenter: label.verticalCenter
        color: label.color
        lineHeight: label.lineHeight
    }
}
