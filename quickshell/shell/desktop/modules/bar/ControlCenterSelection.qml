import QtQuick
import qs.desktop.modules.common

// Paint-only state feedback. It observes the existing input handler and never
// installs another mouse area or takes the grab from a control.
Rectangle {
    id: root

    property var pointer: null
    property real cornerRadius: Math.min(width, height) / 2
    property bool selected: false
    property bool hovered: pointer !== null && (pointer.containsMouse || pointer.activeFocus)
    property bool pressed: pointer !== null && pointer.pressed

    anchors.fill: parent
    radius: cornerRadius
    visible: (pointer === null || pointer.enabled) && (selected || hovered || pressed)
    color: selected ? AppearanceTokens.state.selected : pressed ? AppearanceTokens.state.pressed : AppearanceTokens.state.hover
    z: 100
}
