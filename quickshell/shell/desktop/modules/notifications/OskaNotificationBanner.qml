import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.desktop.modules.bar
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../Kos/Ui"

// Brief notification banner above the Oska search island, matching the mock
// and Sirca's compact Oska notification card.
AnimatedPopupWindow {
    id: banner

    property Item anchorItem: null
    implicitWidth: 456
    implicitHeight: 64
    color: "transparent"
    mask: requestedOpen ? null : bannerInput
    grabFocus: false
    contentItem.scale: 1
    motionOrigin: Item.Bottom

    PopupAnchorBinding {
        popupAnchor: banner.anchor
        sourceItem: banner.anchorItem
    }
    anchor {
        edges: Edges.Bottom
        gravity: Edges.Bottom
        adjustment: PopupAdjustment.Slide
        margins.bottom: -8
    }

    Region {
        id: bannerInput
    }

    Item {
        id: bannerCard
        anchors.fill: parent
        Accessible.role: Accessible.AlertMessage
        Accessible.name: OskaNotificationService.summary

        OpaqueSurface {
            anchors.fill: parent
            radius: 22
        }
        Rectangle {
            anchors.fill: parent
            radius: 22
            color: AppearanceTokens.content.shellInk()
            opacity: 0.08
            border.width: 1
            border.color: AppearanceTokens.content.shellInk()
        }
        NotificationSourceIcon {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            appIcon: OskaNotificationService.appIcon
            desktopEntry: OskaNotificationService.desktopEntry
            ink: AppearanceTokens.content.shellInk()
        }
        ThemeText {
            anchors {
                left: parent.left
                leftMargin: 52
                right: eventIcon.left
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            text: OskaNotificationService.summary
            textFormat: Text.PlainText
            color: AppearanceTokens.content.shellInk()
            elide: Text.ElideRight
            maximumLineCount: 1
            font {
                pixelSize: 14
                weight: Font.Medium
            }
        }
        NotificationSourceIcon {
            id: eventIcon
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            width: 20
            height: 20
            visible: OskaNotificationService.eventIcon.length > 0
            appIcon: OskaNotificationService.eventIcon
            ink: AppearanceTokens.content.shellInk()
        }
        TapHandler {
            onTapped: OskaNotificationService.dismiss()
        }
    }

    onVisibleChanged: if (!visible)
        DockModelService.releaseDockPopup(banner)
    Component.onDestruction: DockModelService.releaseDockPopup(banner)
    onClosed: if (banner.requestedOpen)
        banner.hide()

    Connections {
        target: OskaNotificationService
        function onActiveChanged() {
            if (OskaNotificationService.active) {
                banner.show();
                DockModelService.openDockPopup(banner);
            } else
                banner.hide();
        }
    }

    Component.onCompleted: if (OskaNotificationService.active) {
        banner.show();
        DockModelService.openDockPopup(banner);
    }
}
