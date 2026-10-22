import QtQuick

import Sber.Controls
import Sber.Theme


Item {
    id: colorizer

    property color currentColor: defaultColor
    property real borderWidth: 1.5

    property bool hovered:   false
    property bool activated: false
    property bool selected:  false

    property color defaultColor: Theme.Palette.Surface.Default.Accent
    property color hoverColor:   Theme.Palette.Surface.Default.AccentHover
    property color activeColor:  Theme.Palette.Surface.Default.AccentActive

    state: activated ? "activated" :
           selected  ? "selected"  :
           hovered   ? "hovered"   :
           "default"
    states: [
        State {
            name: "default"
            PropertyChanges {
                target: colorizer
                currentColor: defaultColor
                borderWidth: 1.5
            }
        },
        State {
            name: "hovered"
            PropertyChanges {
                target: colorizer
                currentColor: hoverColor
                borderWidth: 2
            }
        },
        State {
            name: "activated"
            PropertyChanges {
                target: colorizer
                currentColor: activeColor
                borderWidth: 2
            }
        },
        State {
            name: "selected"
            PropertyChanges {
                target: colorizer
                currentColor: activeColor
                borderWidth: 2
            }
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "*"
            PropertyAnimation {
                property: "currentColor"
                duration: 300
                easing.type: Easing.InOutQuint
            }
            PropertyAnimation {
                property: "borderWidth"
                duration: 250
                easing.type: Easing.OutInQuad
            }
        }
    ]
}
