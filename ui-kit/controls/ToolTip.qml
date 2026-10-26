import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.ToolTip {
    id: control

    property alias arrowSize: background.arrowSize
    property alias arrowPosition: background.arrowPosition
    property alias lineHeight: label.lineHeight

    horizontalPadding: background.backgroundConfig.horizontalPadding
    verticalPadding: background.backgroundConfig.horizontalPadding
    implicitWidth: label.implicitWidth + leftPadding + rightPadding
    implicitHeight: label.implicitHeight + topPadding + bottomPadding
    width: implicitWidth
    height: implicitHeight

    x: control.arrowPosition & ArrowRectangle.Edge.Left ? -width - arrowSize : control.arrowPosition & ArrowRectangle.Edge.Right ? parent.width + arrowSize : control.arrowPosition & ArrowRectangle.Position.Start ? 0 : control.arrowPosition & ArrowRectangle.Position.End ? parent.width - width : parent ? (parent.width - width) / 2 : 0
    y: control.arrowPosition & ArrowRectangle.Edge.Top ? -height - arrowSize : control.arrowPosition & ArrowRectangle.Edge.Bottom ? parent.height + arrowSize : control.arrowPosition & ArrowRectangle.Position.Start ? 0 : control.arrowPosition & ArrowRectangle.Position.End ? parent.height - height : (control.height - height) / 2

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside | Popup.CloseOnReleaseOutside
    delay: 1000

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            easing.type: Easing.OutQuad
            duration: 500
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            easing.type: Easing.InQuad
            duration: 500
        }
    }

    background: ArrowRectangle {
        id: background
        lineHeight: label.lineHeight
        inverse: true
        shadow: false
    }

    contentItem: Label {
        id: label
        text: control.text
        color: Theme.Palette.Text.Inverse.Primary
    }
}
