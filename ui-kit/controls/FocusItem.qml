import QtQuick

import Sber.Controls
import Sber.Theme


Rectangle {
    id: control

    property QtObject target: parent.handle ? parent.handle :
                              parent.indicator ? parent.indicator :
                              parent.background

    property int margin: 4
    property int delta: margin + border.width / 2

    color: 'transparent'
    border.width: 1.5
    border.color: Theme.Palette.Surface.Default.Accent

    layer.enabled: false
    layer.samples: 0
    layer.smooth: false

    visible: parent.focus && (parent.focusReason == Qt.TabFocus || parent.focusReason == Qt.BacktabFocusReason)
    radius: target.radius + delta - 1
    topLeftRadius: target.topLeftRadius ? target.topLeftRadius + delta : radius
    topRightRadius: target.topRightRadius ? target.topRightRadius + delta : radius
    bottomLeftRadius: target.bottomLeftRadius ? target.bottomLeftRadius + delta : radius
    bottomRightRadius: target.bottomRightRadius ? target.bottomRightRadius + delta : radius
    x: target.x - margin
    y: target.y - margin
    width: target.width + margin * 2
    height: target.height + margin * 2
}
