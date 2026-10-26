import QtQuick
import QtQuick.Controls
import Sber.Theme

// Opaque search and text input surface.
TextField {
    id: root

    implicitHeight: 34
    leftPadding: 12
    rightPadding: 12
    verticalAlignment: TextInput.AlignVCenter
    selectByMouse: true

    property color surfaceColor: Theme.Palette.Background.Default.Secondary
    property real cornerRadius: height
    property color outlineColor: Theme.Palette.Background.Default.Tertiary
    property color focusedOutlineColor: Theme.Palette.Surface.Default.Accent
    property color textColor: Theme.Palette.Text.Default.Primary
    property color mutedTextColor: Theme.Palette.Text.Default.Secondary

    color: textColor
    placeholderTextColor: mutedTextColor

    HoverHandler {
        id: hover
        cursorShape: Qt.IBeamCursor
    }

    background: Rectangle {
        radius: root.cornerRadius
        color: root.surfaceColor
        border.width: 1
        border.color: root.activeFocus ? root.focusedOutlineColor : root.outlineColor
        Behavior on border.color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
