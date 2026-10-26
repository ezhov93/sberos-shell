import QtQuick
import Kos.Ui

// A round button in the window's title strip: history on the left, the mode
// menu on the right. The reference draws both the same way — a flat white wash
// in a circle with an outlined glyph inside — and turns the one whose thing is
// open into a solid accent disc.
//
// The diameter is a fixed 28px rather than the reference's 10.4% of the window
// width: a desktop window's title-bar controls do not grow with the window, and
// ours spans 360 to 1341 wide.
Item {
    id: root

    property var colors
    property string iconName: "clock"
    property bool active: false
    property real size: 28

    signal clicked

    implicitWidth: size
    implicitHeight: size

    // The flat wash is the disc's resting state, which is the state the
    // reference photographs. Hover is not a brighter wash on top of it: it is
    // the shell's glass plate, the same one the menu rows use, so the two kinds
    // of floating control in this app answer the pointer the same way.
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.active ? root.colors.chromeButtonActive : root.colors.chromeButton
        antialiasing: true
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.size / 2
        visible: !root.active && (mouse.containsMouse || mouse.pressed)
        color: mouse.pressed ? AppearanceTokens.state.pressed : AppearanceTokens.state.hover
    }

    CalculatorIcon {
        anchors.centerIn: parent
        name: root.iconName
        // Measured off the reference: both glyphs ink out at 50.5% of the disc,
        // and the clock's line is 4.2% of it. At our 28px disc that is 14.1px of
        // ink and a 1.2px line, which is where the 0.57 and the 1.8 come from.
        size: Math.round(root.size * 0.57)
        strokeWidth: 1.8
        color: root.active ? root.colors.textOnOperator : root.colors.chromeButtonIcon
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
