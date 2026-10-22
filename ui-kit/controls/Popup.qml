import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls


T.Popup {
    id: control

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding
    width: implicitWidth

    property alias arrowSize: background.arrowSize
    property alias arrowPosition: background.arrowPosition
    property alias lineHeight: background.lineHeight
    property alias radius: background.radius

    x: control.arrowPosition & ArrowRectangle.Edge.Left      ? -width - arrowSize :
       control.arrowPosition & ArrowRectangle.Edge.Right     ? (parent ? parent.width + arrowSize : 0) :
       control.arrowPosition & ArrowRectangle.Position.Start ? 0 :
       control.arrowPosition & ArrowRectangle.Position.End   ? (parent ? parent.width - width : 0) :
                                                               0
    y: control.arrowPosition & ArrowRectangle.Edge.Top       ? -height - arrowSize :
       control.arrowPosition & ArrowRectangle.Edge.Bottom    ? (parent ? parent.height + arrowSize : 0) :
       control.arrowPosition & ArrowRectangle.Position.Start ? 0 :
       control.arrowPosition & ArrowRectangle.Position.End   ? (parent ? parent.height - height : 0) :
                                                               parent ? parent.height : 0

    transformOrigin: Item.Top
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    background: ArrowRectangle {
        id: background
    }

    T.Overlay.modal: DefaultOverlay {}
    T.Overlay.modeless: Rectangle {
        color: "transparent"
    }
}
