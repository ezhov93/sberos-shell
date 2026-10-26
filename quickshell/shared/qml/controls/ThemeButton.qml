import QtQuick
import Sber.Theme

// Compact opaque icon button for shared controls.
Item {
    id: root

    property string symbol: ""
    property bool primary: false
    property bool enabled: true
    property color accentColor: Theme.Palette.Surface.Default.Accent
    property color iconColor: primary ? Theme.Palette.Text.OnDark.Primary : Theme.Palette.Text.Default.Primary
    signal triggered

    property bool _pressed: false
    property bool _hovered: false

    implicitWidth: primary ? 52 : 40
    implicitHeight: implicitWidth
    opacity: enabled ? 1.0 : 0.5
    scale: _pressed ? 0.96 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.primary ? root.accentColor : Theme.Palette.Background.Default.Secondary
        border.width: 1
        border.color: root._pressed ? root.accentColor : Theme.Palette.Background.Default.Tertiary
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.symbol
        color: root.iconColor
        font.pixelSize: root.primary ? 16 : 12
        font.weight: Font.Medium
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onEntered: root._hovered = true
        onExited: root._hovered = false
        onPressed: root._pressed = true
        onReleased: root._pressed = false
        onCanceled: root._pressed = false
        onClicked: root.triggered()
    }
}
