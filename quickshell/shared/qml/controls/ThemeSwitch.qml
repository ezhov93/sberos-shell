import QtQuick
import Sber.Theme

// Opaque Material 3 switch used by remaining QuickShell controls.
Item {
    id: root

    property bool checked: false
    property color accentColor: Theme.Palette.Surface.Default.Accent
    property color trackColor: Qt.rgba(0.5, 0.5, 0.55, 0.35)
    property color handleOnColor: Theme.Palette.Text.OnDark.Primary
    property color handleOffColor: Qt.rgba(0.47, 0.47, 0.47, 1)
    signal toggled(bool checked)

    implicitWidth: 74
    implicitHeight: 32
    opacity: enabled ? 1 : 0.5

    property bool _pressed: false
    property bool _hovered: false

    readonly property real scaleFactor: Math.min(1, height / 32)
    readonly property real handleSize: (checked ? 24 : 16) * scaleFactor
    readonly property real inset: Math.max(1, 4 * scaleFactor)
    readonly property real handleX: inset + (checked ? Math.max(1, width - inset * 2 - handleSize) : 0)

    function toggle() {
        if (enabled)
            toggled(!checked);
    }

    Rectangle {
        objectName: "switch-track"
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.accentColor : root.trackColor
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleX + root.handleSize / 2 - width / 2
        width: Math.min(root.height, 40 * root.scaleFactor)
        height: width
        radius: width / 2
        color: root.accentColor
        opacity: root._pressed ? 0.16 : (root._hovered ? 0.10 : 0)
        Behavior on opacity {
            NumberAnimation {
                duration: 120
            }
        }
    }

    Rectangle {
        objectName: "switch-thumb"
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleX
        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: root.checked ? root.handleOnColor : root.handleOffColor
        Behavior on x {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
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
        onClicked: root.toggle()
    }
}
