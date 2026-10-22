import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

import Sber.Controls
import Sber.Core
import Sber.Theme


Control {
    id: control
    objectName: "SpinBox"

    enum Type {
        Default,
        Segmented,
        Solid
    }

    property int cornersType: Widget.Square
    property int type: Widget.Secondary
    property int editorType: SpinBox.Type.Default

    property alias from: input.from
    property alias to: input.to
    property alias decimals: input.decimals
    property alias stepSize: input.stepSize

    property alias prefixText: input.prefixText
    property alias postfixText: input.postfixText
    property bool editable: true
    property alias inputMethodHints: input.inputMethodHints
    property alias validator: input.validator
    readonly property alias text: input.text
    property alias notation: input.notation

    property bool loading: false
    property alias loadingPercent: loadingIndicator.loadingPercent

    readonly property alias up: indicatorUp
    readonly property alias down: indicatorDown

    property int lineHeight: Core.Settings.LineHeight
    spacing: 2
    implicitHeight: lineHeight
    height: implicitHeight
    implicitWidth: input.implicitWidth + leftInset + rightInset
    width: implicitWidth
    leftInset: indicatorDown.width + (control.editorType == SpinBox.Type.Solid ? 0 : spacing)
    rightInset: indicatorUp.width + (control.editorType == SpinBox.Type.Solid ? 0 : spacing)

    function value() { return input.value(); }
    function setValue(val) { input.setValue(val); }
    signal valueChanged(real value);

    IconButton {
        id: indicatorDown
        lineHeight: control.lineHeight
        icon.name: "Minus"
        type: control.type
        focusPolicy: Qt.NoFocus
        enabled: control.value() > control.from
        onClicked: input.decrease()
        leftCornersType: control.cornersType
        rightCornersType: control.editorType == SpinBox.Type.Default ?
                              control.cornersType :
                              Widget.Flat
    }

    contentItem: NumberInput {
        id: input
        anchors.fill: control
        anchors.leftMargin: indicatorDown.visible
                                ? indicatorDown.width + (control.editorType == SpinBox.Type.Solid ? 0 : control.spacing)
                                : 0
        anchors.rightMargin: indicatorUp.visible
                                 ? indicatorUp.width + (control.editorType == SpinBox.Type.Solid ? 0 : control.spacing)
                                 : 0
        z: 100
        lineHeight: control.lineHeight
        visible: !control.loading
        readOnly: !control.editable
        locale: control.locale
        onValueChanged: (v) => { control.valueChanged(v) }
        radius: control.editorType == SpinBox.Type.Default ?
                    input.backgroundConfig.radius :
                    0
        backgroundConfig.type: control.type
    }

    Rectangle {
        x: input.x
        z: 100
        width: input.width
        height: input.height
        color: Theme.Palette.Background.Default.Basic
        radius: input.radius
        border.width: 1.5
        border.color: input.colorizer.defaultColor
        visible: control.loading
        opacity: control.enabled ? 1 : 0.4

        BusyIndicator {
            id: loadingIndicator
            anchors.centerIn: parent
            color: input.color
            lineHeight: control.lineHeight <= Theme.Sizes.LineHeight.S ? 14 : 20
        }
    }

    IconButton {
        id: indicatorUp
        x: input.x + input.width + (control.editorType == SpinBox.Type.Solid ? 0 : control.spacing)
        lineHeight: control.lineHeight
        icon.name: "Plus"
        type: control.type
        focusPolicy: Qt.NoFocus
        enabled: control.value() < control.to
        onClicked: input.increase()
        rightCornersType: control.cornersType
        leftCornersType: control.editorType == SpinBox.Type.Default ?
                             control.cornersType :
                             Widget.Flat
    }
}
