import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

import Sber.Controls
import Sber.Core
import Sber.Theme


Control {
    id: control
    objectName: "Range"

    property alias prefixText: inputFrom.prefixText
    property alias postfixText: inputFrom.postfixText
    property alias label: inputFrom.label
    property alias labelText: inputFrom.labelText
    property alias labelColor: inputFrom.labelColor
    property alias labelFont: inputFrom.labelFont
    property alias caption: inputFrom.caption
    property alias captionText: inputFrom.captionText
    property alias captionColor: inputFrom.captionColor
    property alias captionFont: inputFrom.captionFont
    property alias required: inputFrom.required
    property alias requiredPlacement: inputFrom.requiredPlacement
    property alias status: backgroundConfig.status
    property alias placeholderTextFrom: inputFrom.placeholderText
    property alias placeholderTextColorFrom: inputFrom.placeholderTextColor
    property alias placeholderTextTo: inputTo.placeholderText
    property alias placeholderTextColorTo: inputTo.placeholderTextColor
    property alias iconFromLeft: inputFrom.iconLeft
    property alias iconFromRight: inputFrom.iconRight
    property alias iconToLeft: inputTo.iconLeft
    property alias iconToRight: inputTo.iconRight
    property alias decimals: inputFrom.decimals
    property alias from: inputFrom.from
    property alias to: inputTo.to
    property alias inputMethodHints: inputFrom.inputMethodHints
    property alias validator: inputFrom.validator
    readonly property alias text: inputFrom.text
    property alias notation: inputFrom.notation
    property int delimiter: Widget.Arrow

    property int lineHeight: Core.Settings.LineHeight
    hoverEnabled: true
    spacing: 6
    implicitHeight: inputFrom.implicitHeight
    height: implicitHeight
    implicitWidth: Math.max(150, inputFrom.implicitWidth, inputTo.implicitWidth) * 2 +
                   (icon.visible ? icon.implicitWidth + spacing * 2 : 0)
    width: implicitWidth

    function valueFrom() { return inputFrom.value(); }
    function setValueFrom() { return inputFrom.setValue(); }
    signal valueFromChanged(real value);

    function valueTo() { return inputTo.value(); }
    function setValueTo() { return inputTo.setValue(); }
    signal valueToChanged(real value);

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        backgroundType: Widget.Outline
    }
    property Colorizer colorizer: Colorizer {
        id: colorizer
        defaultColor: backgroundConfig.defaultColor
        hovered: control.enabled && control.hovered
        hoverColor: backgroundConfig.hoverColor
        activated: inputFrom.activeFocus || inputTo.activeFocus
        activeColor: backgroundConfig.activeColor
    }

    background: Rectangle {
        id: bg
        y: inputFrom.background.y
        height: control.lineHeight
        radius: inputFrom.backgroundConfig.radius
        color: Theme.Palette.Background.Default.Basic
        opacity: enabled ? 1 : 0.4
        border.width: colorizer.borderWidth
        border.color: colorizer.currentColor
        z: 0
    }

    onFontChanged: {
        inputFrom.font = font;
    }

    FocusItem {
        visible: inputFrom.focus && (inputFrom.focusReason == Qt.TabFocus || inputFrom.focusReason == Qt.BacktabFocusReason) ||
                 inputTo.focus && (inputTo.focusReason == Qt.TabFocus || inputTo.focusReason == Qt.BacktabFocusReason)
    }

    NumberInput {
        id: inputFrom
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: icon.left
        anchors.rightMargin: icon.visible ? control.spacing : 0
        anchors.bottom: parent.bottom
        lineHeight: control.lineHeight
        locale: control.locale
        onValueChanged: (v) => { control.valueFromChanged(v) }
        to: inputTo.to
        background.visible: false
        z: 100

        Component.onCompleted: focusItem.destroy()
    }
    Icon {
        id: icon
        anchors.centerIn: bg
        name: control.delimiter == Widget.Arrow ? "ArrowRight" :
              control.delimiter == Widget.Minus ? "Minus" :
                                                  ""
        size: 24
        visible: control.delimiter != Widget.NoDelimiter
        opacity: enabled ? 1 : 0.4
        z: 100
    }
    NumberInput {
        id: inputTo
        anchors.left: icon.right
        anchors.leftMargin: icon.visible ? control.spacing : 0
        y: inputFrom.background.y
        anchors.right: parent.right
        lineHeight: control.lineHeight
        font: inputFrom.font
        locale: control.locale
        onValueChanged: (v) => { control.valueToChanged(v) }
        from: inputFrom.from

        prefixText: inputFrom.prefixText
        postfixText: inputFrom.postfixText
        decimals: inputFrom.decimals
        inputMethodHints: inputFrom.inputMethodHints
        validator: inputFrom.validator
        text: inputFrom.text
        notation: inputFrom.notation
        background.visible: false
        z: 100

        Component.onCompleted: focusItem.destroy()
    }
}
