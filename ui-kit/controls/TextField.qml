import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.TextField {
    id: control

    property alias status: backgroundConfig.status
    property alias type: backgroundConfig.type
    font: label.textConfig.font
    color: label.textConfig.defaultColor
    placeholderTextColor: Theme.Palette.Text.Default.Secondary
    property alias label: label
    property alias labelText: label.text
    property alias labelColor: label.color
    property alias labelFont: label.font
    property alias caption: caption
    property alias captionText: caption.text
    property alias captionColor: caption.color
    property alias captionFont: caption.font
    property alias iconLeft: iconLeft
    property alias iconRight: iconRight
    property alias required: requiredIndicator.visible
    property int requiredPlacement: Widget.Left
    property int textLimit: 0

    property int verticalSpacing: lineHeight <= Theme.Sizes.LineHeight.S ? 8 : lineHeight <= Theme.Sizes.LineHeight.M ? 10 : 12
    property int horizontalSpacing: 6
    property alias lineHeight: backgroundConfig.lineHeight
    property alias radius: bg.radius
    property alias border: bg.border

    property alias centerBackgroundColor: bg.color

    opacity: enabled ? 1 : 0.4
    readOnly: false
    hoverEnabled: true

    implicitWidth: leftPadding + 100 + rightPadding
    width: implicitWidth
    implicitHeight: lineHeight + topInset + bottomInset
    height: implicitHeight
    topPadding: (bg.height - contentHeight) / 2 + topInset
    bottomPadding: (bg.height - contentHeight) / 2 + bottomInset
    leftPadding: backgroundConfig.horizontalPadding + (iconLeft.visible ? iconLeft.width + horizontalSpacing : 0)
    rightPadding: backgroundConfig.horizontalPadding + (iconRight.visible ? iconRight.width + horizontalSpacing : 0)

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        backgroundType: Widget.Outline
    }
    property Colorizer colorizer: Colorizer {
        id: colorizer
        defaultColor: backgroundConfig.defaultColor
        hovered: control.enabled && control.hovered
        hoverColor: backgroundConfig.hoverColor
        activated: control.activeFocus
        activeColor: backgroundConfig.activeColor
    }

    // Rewrite default cursor shape logic
    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        height: control.topInset
    }
    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: control.bottomInset
    }

    // Top
    topInset: label.visible ? label.implicitHeight + verticalSpacing : 0
    Label {
        id: label
        visible: text != ""
        anchors.left: bg.left
        anchors.topMargin: -bg.anchors.topMargin
        anchors.top: bg.top
        lineHeight: control.lineHeight
    }

    // Center
    background: Rectangle {
        id: bg
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: control.topInset
        anchors.bottomMargin: control.bottomInset
        height: control.lineHeight
        radius: backgroundConfig.radius
        color: Theme.Palette.Background.Default.Basic
        border.width: colorizer.borderWidth
        border.color: colorizer.currentColor
    }
    Icon {
        id: iconLeft
        anchors.left: bg.left
        anchors.leftMargin: backgroundConfig.horizontalPadding
        anchors.verticalCenter: bg.verticalCenter
        size: control.lineHeight <= Theme.Sizes.LineHeight.S ? 14 : 20
        color: control.color
    }
    Label {
        id: placeholder
        anchors.left: bg.left
        anchors.leftMargin: control.leftPadding
        anchors.verticalCenter: bg.verticalCenter
        visible: control.placeholderText != "" && control.text == "" && !control.focus
        text: control.placeholderText
        color: control.placeholderTextColor
        lineHeight: control.lineHeight
    }
    Icon {
        id: iconRight
        anchors.right: bg.right
        anchors.rightMargin: backgroundConfig.horizontalPadding
        anchors.verticalCenter: bg.verticalCenter
        size: control.lineHeight <= Theme.Sizes.LineHeight.S ? 14 : 20
        color: control.color
    }
    Indicator {
        id: requiredIndicator
        x: control.requiredPlacement == Widget.Left ? label.visible ? label.x - width - 4 : bg.x : label.visible ? label.x + label.width + 4 : bg.x + bg.width - width
        y: label.visible ? label.y + 4 : bg.y
        status: Widget.Error
        visible: false
        lineHeight: Theme.Sizes.LineHeight.S
    }

    // Bottom
    bottomInset: caption.visible || counter.visible ? Math.max(caption.implicitHeight, counter.implicitHeight) + verticalSpacing : 0
    Label {
        id: caption
        visible: caption.text != ""
        anchors.left: bg.left
        anchors.top: bg.bottom
        anchors.topMargin: control.verticalSpacing
        lineHeight: control.lineHeight
        secondary: true
    }
    Label {
        id: counter
        visible: control.textLimit > 0
        anchors.top: bg.bottom
        anchors.right: bg.right
        anchors.topMargin: control.verticalSpacing
        text: control.text.length + "/" + control.textLimit
        font: caption.font
        color: caption.color
        lineHeight: control.lineHeight
    }

    onTextChanged: text => {
        if (control.textLimit) {
            control.status = control.text.length > control.textLimit ? Widget.Error : Widget.None;
        }
    }

    cursorDelegate: CursorDelegate {}
    property FocusItem focusItem: FocusItem {
        parent: control
    }
    property Menu contextMenu
    Component {
        id: defaultMenu
        DefaultTextMenu {}
    }
    function onMenuToggled(event) {
        if (!control.contextMenu) {
            contextMenu = defaultMenu.createObject(control);
        }
        if (event.button == Qt.RightButton) {
            var menu = control.contextMenu;
            var showContextMenu = menu["showContextMenu"];
            if (typeof showContextMenu === "function")
                showContextMenu.call(menu, event.x, event.y);
            else
                menu.popup(event.x, event.y);
        }
    }
    onReleased: event => {
        onMenuToggled(event);
    }
    onPressAndHold: event => {
        onMenuToggled(event);
    }

    function closeEvent(event) {
        if (event)
            event.accepted = true;
        control.focus = false;
        control.accepted();
    }

    Keys.onReturnPressed: function (event) {
        closeEvent(event);
    }
    Keys.onEnterPressed: function (event) {
        closeEvent(event);
    }
    Keys.onEscapePressed: function (event) {
        closeEvent(event);
    }
}
