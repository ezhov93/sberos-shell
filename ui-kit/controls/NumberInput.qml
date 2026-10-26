import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

import Sber.Controls
import Sber.Theme

TextField {
    id: control
    objectName: "NumberInput"

    property real from: 0
    property real to: 999
    property int decimals: 0
    property double stepSize: 1.0
    property string prefixText
    property string postfixText
    property int notation: DoubleValidator.StandardNotation
    property var locale: Qt.locale()

    implicitWidth: Math.max(internal.metricsFrom.boundingRect.width, internal.metricsTo.boundingRect.width, internal.metricsPlaceholder.boundingRect.width) + leftPadding + rightPadding
    width: implicitWidth
    leftPadding: backgroundConfig.horizontalPadding + (prefixLabel.visible ? prefixLabel.implicitWidth + 5 : 0) + (iconLeft.visible ? iconLeft.width + horizontalSpacing : 0)
    rightPadding: backgroundConfig.horizontalPadding + (postfixLabel.visible ? postfixLabel.implicitWidth + 5 : 0) + (iconRight.visible ? iconRight.width + horizontalSpacing : 0)

    validator: DoubleValidator {
        bottom: control.from
        top: control.to
        decimals: control.decimals
        notation: control.notation
        locale: control.locale.name
    }
    inputMethodHints: Qt.ImhFormattedNumbersOnly
    text: internal.textFromValue(control.value)

    Label {
        id: prefixLabel
        anchors.left: parent.left
        anchors.leftMargin: backgroundConfig.horizontalPadding + (iconLeft.visible ? iconLeft.width + horizontalSpacing : 0)
        y: control.background.y + (control.background.height - height) / 2
        secondary: true
        font: control.font
        text: control.prefixText
        visible: text != ""
        lineHeight: control.lineHeight
        color: control.color
    }
    Label {
        id: postfixLabel
        anchors.right: parent.right
        anchors.rightMargin: backgroundConfig.horizontalPadding + (iconRight.visible ? iconRight.width + horizontalSpacing : 0)
        y: control.background.y + (control.background.height - height) / 2
        secondary: true
        font: control.font
        text: control.postfixText
        visible: text != ""
        lineHeight: control.lineHeight
        color: control.color
    }

    onActiveFocusChanged: {
        if (!control.activeFocus)
            internal.setValueFromInput();
    }
    onValueChanged: {
        internal.updateDisplayText();
    }
    onFromChanged: {
        setValue(value);
    }
    onToChanged: {
        setValue(value);
    }
    onDecimalsChanged: {
        setValue(value);
    }
    onPlaceholderTextChanged: {
        setValue(value);
    }
    onTextChanged: {
        if (!internal.isUpDownChanging)
            internal.setValueFromInput();
    }

    signal valueChanged(real value)
    function setValue(v) {
        var newValue = internal.bound(v);
        if (internal.value !== newValue) {
            internal.isUpDownChanging = true;
            internal.value = newValue;
            valueChanged(internal.value);
        }
    }
    function value() {
        return isNaN(internal.value) && placeholderText == "" ? internal.bound(0) : internal.value;
    }
    function stepBy(steps) {
        setValue(value() + (stepSize * steps));
    }
    function increase() {
        stepBy(1);
    }
    function decrease() {
        stepBy(-1);
    }

    QtObject {
        id: internal
        property bool isUpDownChanging: true
        property real value: NaN
        property QtObject metricsFrom: TextMetrics {
            font: control.font
            text: control.from.toLocaleString(control.locale, control.notation === DoubleValidator.StandardNotation ? 'f' : 'e', Math.max(control.decimals, 0))
        }
        property QtObject metricsTo: TextMetrics {
            font: control.font
            text: control.to.toLocaleString(control.locale, control.notation === DoubleValidator.StandardNotation ? 'f' : 'e', Math.max(control.decimals, 0))
        }
        property QtObject metricsPlaceholder: TextMetrics {
            font: control.font
            text: placeholderText
        }

        function textFromValue(value) {
            return !isNaN(value) ? control.value().toLocaleString(control.locale, control.notation === DoubleValidator.StandardNotation ? 'f' : 'e', Math.max(control.decimals, 0)) : placeholderText == "" ? control.value().toLocaleString(control.locale, control.notation === DoubleValidator.StandardNotation ? 'f' : 'e', Math.max(control.decimals, 0)) : "";
        }
        function valueFromText(text) {
            return text == "" ? placeholderText == "" ? bound(0) : NaN : Number.fromLocaleString(control.locale, text);
        }
        function bound(v) {
            return !isNaN(v) ? (v < control.from ? control.from : v > control.to ? control.to : v) : NaN;
        }
        function setValueFromInput() {
            var newValue = bound(valueFromText(control.text, control.locale));
            if (value !== newValue) {
                value = newValue;
            }
            updateDisplayText();
        }
        function updateDisplayText() {
            control.text = textFromValue(bound(value));
            internal.isUpDownChanging = false;
        }
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Up:
            increase();
            event.accepted = true;
            break;
        case Qt.Key_Down:
            decrease();
            event.accepted = true;
            break;
        }
    }
}
