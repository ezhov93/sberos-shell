import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.TextArea {
    id: control

    property alias status: backgroundConfig.status
    property alias type: backgroundConfig.type
    font: label.font
    color: label.color
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

    property int spacing: 12
    property int verticalSpacing: spacing
    property int horizontalSpacing: spacing
    property alias lineHeight: backgroundConfig.lineHeight
    property alias radius: bg.radius
    property alias border: bg.border

    opacity: enabled ? 1 : 0.4
    readOnly: false
    hoverEnabled: true

    implicitWidth: contentWidth + leftPadding + rightPadding
    width: implicitWidth
    implicitHeight: contentHeight + topPadding + bottomPadding
    height: implicitHeight

    topInset: label.visible ? label.implicitHeight + verticalSpacing : 0
    topPadding: topInset + backgroundConfig.horizontalPadding
    bottomPadding: backgroundConfig.horizontalPadding + ((caption.visible || counter.visible) ? Math.max(caption.implicitHeight, counter.implicitHeight) + verticalSpacing : 0)
    leftPadding: backgroundConfig.horizontalPadding + (iconLeft.visible ? iconLeft.width + horizontalSpacing : 0)
    rightPadding: backgroundConfig.horizontalPadding + (iconRight.visible ? iconRight.width + horizontalSpacing : 0)

    KeyNavigation.priority: KeyNavigation.BeforeItem

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
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: control.topInset
    }
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: control.bottomInset
    }

    // Center
    background: Rectangle {
        id: bg
        anchors.topMargin: label.visible ? label.implicitHeight + verticalSpacing : 0
        opacity: control.enabled ? 1 : 0.4
        radius: backgroundConfig.radius
        color: Theme.Palette.Background.Default.Basic
        border.width: colorizer.borderWidth
        border.color: colorizer.currentColor

        Label {
            id: label
            visible: label.text != ""
            anchors.top: parent.top
            anchors.topMargin: -parent.anchors.topMargin
            anchors.left: parent.left
            lineHeight: backgroundConfig.lineHeight
        }

        Icon {
            id: iconLeft
            anchors.top: parent.top
            anchors.topMargin: backgroundConfig.horizontalPadding
            anchors.left: parent.left
            anchors.leftMargin: backgroundConfig.horizontalPadding
            size: control.lineHeight <= Theme.Sizes.LineHeight.S ? 14 : 20
            color: control.color
        }

        Label {
            id: placeholder

            anchors {
                top: parent.top
                topMargin: backgroundConfig.horizontalPadding
                left: parent.left
                leftMargin: control.leftPadding
            }

            width: parent.width - control.leftPadding - control.rightPadding
            wrapMode: Text.WordWrap
            visible: control.placeholderText != "" && control.text == "" && !control.focus
            text: control.placeholderText
            color: Theme.Palette.Text.Default.Secondary
            lineHeight: backgroundConfig.lineHeight
        }

        Icon {
            id: iconRight
            anchors.top: parent.top
            anchors.topMargin: backgroundConfig.horizontalPadding
            anchors.right: parent.right
            anchors.rightMargin: backgroundConfig.horizontalPadding
            size: control.lineHeight <= Theme.Sizes.LineHeight.S ? 14 : 20
            color: control.color
        }

        Label {
            id: caption
            visible: caption.text != ""
            anchors.bottom: parent.bottom
            anchors.bottomMargin: backgroundConfig.horizontalPadding
            anchors.left: parent.left
            anchors.leftMargin: backgroundConfig.horizontalPadding
            lineHeight: backgroundConfig.lineHeight
            secondary: true
        }
        Label {
            id: counter
            visible: control.textLimit != 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: backgroundConfig.horizontalPadding
            anchors.right: parent.right
            anchors.rightMargin: backgroundConfig.horizontalPadding
            text: control.text.length + "/" + control.textLimit
            font: caption.font
            color: caption.color
            lineHeight: backgroundConfig.lineHeight
        }

        Indicator {
            id: requiredIndicator
            x: control.requiredPlacement == Widget.Left ? label.visible ? label.x - width - 4 : bg.x : label.visible ? label.x + label.width + 4 : bg.x + bg.width - width
            y: label.visible ? label.y + 4 : bg.y
            status: Widget.Error
            visible: false
            lineHeight: Theme.Sizes.LineHeight.S
        }
    }

    onTextChanged: text => {
        control.status = control.textLimit && (control.text.length > control.textLimit) ? Widget.Error : Widget.None;
    }

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
            control.contextMenu = defaultMenu.createObject(control);
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
            event.accept = true;
        control.focus = false;
    }
    Keys.onEscapePressed: function (event) {
        closeEvent(event);
    }
}
