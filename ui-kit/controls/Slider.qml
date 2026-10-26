import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.Slider {
    id: control

    enum View {
        Default,
        Accient,
        Gradient
    }

    // User-only events: model updates never emit these signals.
    signal valueEdited(real value)
    signal editingFinished(real value)
    QtObject {
        id: interaction
        property bool pointerActive: false
    }
    onMoved: {
        valueEdited(value);
        if (!interaction.pointerActive)
            editingFinished(value);
    }

    property int view: Slider.View.Default
    property int labelPacement: Widget.Inner
    property alias label: label
    property alias labelText: label.text
    property alias labelColor: label.color
    property alias labelFont: label.font
    property alias icon: label.icon

    property int rangeValuesPlacement: Widget.Inner
    property alias showRangeValues: textFrom.visible
    property alias rangeValuesFont: textFrom.font
    property alias rangeValuesColor: textFrom.color
    property int decimials: 0
    property int handleWidth: 16

    property int lineHeight: Core.Settings.LineHeight
    implicitWidth: Math.max(100, contentItem.x + contentItem.implicitWidth, rangeItem.x + rangeItem.implicitWidth, label.x + label.width)
    width: implicitWidth
    implicitHeight: Math.max(contentItem.y + contentItem.height, rangeItem.y + rangeItem.implicitHeight, label.y + label.height)
    height: implicitHeight
    spacing: 6
    clip: false
    hoverEnabled: true
    focusPolicy: Qt.TabFocus

    IconLabel {
        id: label
        anchors.left: parent.left
        anchors.verticalCenter: parent.top
        lineHeight: control.lineHeight
        visible: control.labelText
    }

    Item {
        id: contentItem
        anchors.top: labelPacement == Widget.Outer ? label.top : label.bottom
        x: rangeValuesPlacement == Widget.Outer ? rangeItem.x + textFrom.implicitWidth + 8 : rangeItem.x
        width: rangeValuesPlacement == Widget.Outer ? parent.width - x - textTo.implicitWidth - 8 : parent.width - x
        height: control.handleWidth

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: handle.visialPosition - handle.width / 2 + handle.border.width
            height: 4
            radius: height / 2
            z: 0
            color: colorizer.defaultColor
        }
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - handle.visialPosition - handle.width / 2
            height: 4
            radius: height / 2
            z: 0
            color: Theme.Palette.Surface.Default.SolidSecondary
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            preventStealing: true
            onPressed: mouse => {
                interaction.pointerActive = true;
                control.pressed = true;
                control.forceActiveFocus(Qt.MouseFocusReason);
                updateValue(mouse);
            }
            onMouseXChanged: mouse => {
                if (pressed)
                    updateValue(mouse);
            }
            onReleased: mouse => {
                updateValue(mouse);
                finish();
            }
            onCanceled: finish()
            function finish() {
                if (!interaction.pointerActive)
                    return;
                control.editingFinished(control.value);
                interaction.pointerActive = false;
                control.pressed = false;
            }
            function updateValue(mouse) {
                const position = Math.max(0, Math.min(1, mouse.x / Math.max(1, width)));
                const raw = control.from + (control.to - control.from) * position;
                const snapped = control.stepSize > 0 ? control.from + Math.round((raw - control.from) / control.stepSize) * control.stepSize : raw;
                const next = Math.max(Math.min(control.from, control.to), Math.min(Math.max(control.from, control.to), snapped));
                if (control.value !== next) {
                    control.value = next;
                    control.moved();
                }
                mouse.accepted = true;
            }
        }
    }
    handle: Rectangle {
        id: handle
        property int workWidth: contentItem.width
        property int visialPosition: workWidth * (control.value - control.from) / (control.to - control.from)
        x: contentItem.x + visialPosition - control.handleWidth / 2
        anchors.verticalCenter: contentItem.verticalCenter
        color: "transparent"
        border.color: colorizer.currentColor
        border.width: 3
        width: control.handleWidth
        height: width
        z: 1
        radius: control.handleWidth / 2

        Colorizer {
            id: colorizer
            defaultColor: control.view == Slider.View.Accient ? Theme.Palette.Surface.Default.Accent : Theme.Palette.Surface.Default.SolidPrimary
            hovered: control.enabled && handleArea.containsMouse
            hoverColor: control.view == Slider.View.Accient ? Theme.Palette.Surface.Default.AccentHover : Theme.Palette.Surface.Default.SolidPrimaryHover
            activated: control.pressed
            activeColor: control.view == Slider.View.Accient ? Theme.Palette.Surface.Default.AccentActive : Theme.Palette.Surface.Default.SolidPrimaryActive
        }
        Behavior on width {
            PropertyAnimation {
                duration: 300
                easing.type: Easing.InOutQuint
            }
        }

        MouseArea {
            id: handleArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
        }
    }
    FocusItem {}

    Item {
        id: rangeItem
        anchors.left: labelPacement == Widget.Outer ? label.right : parent.left
        anchors.leftMargin: labelPacement == Widget.Outer && label.width ? control.spacing : 0
        anchors.right: parent.right
        anchors.top: rangeValuesPlacement == Widget.Outer ? contentItem.top : contentItem.verticalCenter
        anchors.topMargin: rangeValuesPlacement == Widget.Outer ? 0 : control.spacing
        anchors.bottom: parent.bottom
        implicitHeight: Math.max(textFrom.height, textTo.height)

        Label {
            id: textFrom
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: control.from.toLocaleString(control.locale, 'f', control.decimials)
            lineHeight: control.lineHeight
        }
        Label {
            id: textTo
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: control.to.toLocaleString(control.locale, 'f', control.decimials)
            lineHeight: control.lineHeight
            visible: textFrom.visible
            font: textFrom.font
            color: textFrom.color
        }
    }
}
