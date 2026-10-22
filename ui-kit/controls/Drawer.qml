import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme


T.Drawer {
    id: control
    modal: true

    padding: 20
    leftPadding: padding
    topPadding: padding + headerLabel.height
    rightPadding: padding
    bottomPadding: padding
    implicitWidth: Math.max(contentWidth, headerLabel.implicitWidth) + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding

    parent: Overlay.overlay
    x: control.edge === Qt.RightEdge ? parent.width - width : 0
    y: control.edge === Qt.BottomEdge ? parent.height - height : 0
    width: (control.edge === Qt.TopEdge || control.edge === Qt.BottomEdge) ? parent.width : implicitWidth
    height: (control.edge === Qt.RightEdge || control.edge === Qt.LeftEdge) ? parent.height : implicitHeight

    property alias header: headerLabel
    property alias closeButtonVisible: closeButton.visible
    focus: true

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    T.Overlay.modal: DefaultOverlay {}
    T.Overlay.modeless: DefaultOverlay {}

    enter: Transition { SmoothedAnimation { velocity: 5 } }
    exit: Transition { SmoothedAnimation { velocity: 5 } }

    background: Item {
        z: contentItem.z
        Rectangle {
            id: background
            anchors.fill: parent
            color: Theme.Palette.Background.Default.Secondary
            Label {
                id: headerLabel
                x: control.padding
                y: control.padding
                width: control.width - control.padding * 2
                height: text == "" ? 0 : implicitHeight
                font: Theme.Fonts.HeaderH4B
            }
        }
        ShadowBox {
            source: background
        }
        IconButton {
            id: closeButton
            x: control.width - width - control.padding
            y: control.padding
            z: contentItem.z + 1
            width: 24
            height: visible ? 24 : 0

            type: Widget.Default
            backgroundType: Widget.Clear
            iconItem.name: "Close"
            iconItem.size: 24
            onReleased: control.close();
        }
    }
}
