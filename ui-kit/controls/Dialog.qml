import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme


T.Dialog {
    id: control
    modal: true

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            implicitHeaderWidth,
                            implicitFooterWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding
                             + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                             + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))
    padding: 20
    spacing: 20

    parent: Overlay.overlay
    x: (Overlay.overlay.width - width) / 2
    y: (Overlay.overlay.height - height) / 2

    property alias closeButtonVisible: closeButton.visible
    closePolicy: closeButton.visible ?
                     Popup.CloseOnEscape | Popup.CloseOnPressOutside :
                     Popup.NoAutoClose

    background: Item {
        z: contentItem.z
        Rectangle {
            id: background
            anchors.fill: parent
            color: Theme.Palette.Background.Default.Secondary
            radius: Theme.Sizes.BorderRadius.L
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
            height: 24

            type: Widget.Default
            backgroundType: Widget.Clear
            icon.name: "Close"
            iconItem.size: 24
            onReleased: control.close();
        }
    }

    header: Label {
        leftPadding: control.padding
        topPadding: control.padding

        text: control.title
        visible: control.title
        font: Theme.Fonts.HeaderH4B
    }

    footer: DialogButtonBox {
        visible: count > 0
    }

    T.Overlay.modal: DefaultOverlay {}
    T.Overlay.modeless: DefaultOverlay {}
}
