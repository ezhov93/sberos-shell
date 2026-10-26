import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.Menu {
    id: control

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding
    width: implicitWidth

    padding: 2
    overlap: 1
    property alias radius: background.radius

    transformOrigin: Item.Top
    closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape

    delegate: MenuItem {
        highlight: false
    }

    contentItem: ListView {
        implicitHeight: contentHeight
        model: control.contentModel
        clip: true
        currentIndex: -1
        keyNavigationWraps: true
        highlightFollowsCurrentItem: true

        ScrollBar.vertical: ScrollBar {
            width: 4
        }
    }

    background: Item {
        Rectangle {
            id: background
            anchors.fill: parent
            radius: Theme.Sizes.BorderRadius.S
            color: Theme.Palette.Background.Default.Secondary
            border.width: 1.5
            border.color: Theme.Palette.Background.Default.Basic
        }
        ShadowBox {
            source: background
        }
    }

    T.Overlay.modal: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.5)
    }

    T.Overlay.modeless: Rectangle {
        color: Color.transparent(control.palette.shadow, 0.12)
    }
}
