import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme


T.ScrollBar {
    id: control

    property int handleSize: 6
    implicitWidth: vertical ? handleSize : width
    implicitHeight: horizontal ? handleSize : height
    property alias backgroundColor: bg.color
    property alias handleColor: handle.color
    visible: policy !== T.ScrollBar.AlwaysOff
    policy: T.ScrollBar.AsNeeded

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse
    }

    background: Rectangle {
        id: bg
        implicitWidth: vertical ? handleSize : control.width
        implicitHeight: horizontal ? handleSize : control.height
        radius: (horizontal ? height : width) / 2
        color: bgColorizer.currentColor

        Colorizer {
            id: bgColorizer
            defaultColor: Theme.Palette.Surface.Default.TransparentPrimaryHover
            hovered: hoverHandler.hovered
            hoverColor: Theme.Palette.Surface.Default.TransparentPrimaryActive
        }
    }

    contentItem: Rectangle {
        id: handle
        implicitWidth: vertical ? handleSize : control.width
        implicitHeight: horizontal ? handleSize : control.height
        radius: (horizontal ? height : width) / 2
        color: handleColorizer.currentColor

        Colorizer {
            id: handleColorizer
            defaultColor: Theme.Palette.Surface.Default.SolidPrimaryHover
            hovered: hoverHandler.hovered
            hoverColor: Theme.Palette.Surface.Default.SolidPrimaryActive
        }
    }

    state: (control.policy === T.ScrollBar.AlwaysOn ||
            control.policy === T.ScrollBar.AsNeeded &&
            (hoverHandler.hovered || control.active && control.size < 1.0)) ?
        "active" :
        "default"

    states: [
        State {
            name: "default"
            PropertyChanges { target: control; opacity: 0; }
        },
        State {
            name: "active"
            PropertyChanges { target: control; opacity: 1; }
        }
    ]

    transitions: Transition {
        from: "active"
        SequentialAnimation {
            PauseAnimation { duration: 3000 }
            NumberAnimation { target: control; duration: 200; property: "opacity"; }
        }
    }
}
