import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.desktop.modules.dock
import qs.desktop.modules.common
import qs.desktop.modules.applauncher
import qs.desktop.modules.platform

// One concrete top Bar surface. Its content is shared with the optional
// unified Dock host; this file owns layer-shell geometry and auto-hide.
PanelWindow {
    id: root

    property bool barEnabled: true

    // Exclude the panel surface from KWin's application-window effects.
    WlrLayershell.namespace: "dock"
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    // The Bar lives on Top, but the fullscreen launcher (a Top surface
    // covering the whole output) must render beneath the Bar. While that
    // launcher is open, the Bar promotes to Overlay; the launcher demotes
    // itself to Top in the same frame.
    WlrLayershell.layer: (AppLauncherService.open && AppLauncherConfigService.displayMode === "fullscreen") ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: ((barContentLoader.item?.statusArea?.collectionExpanded ?? false) || (barContentLoader.item?.statusArea?.statusDragActive ?? false)) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    implicitHeight: ConfigService.barHeight
    // ── Auto-hide controller ──
    BarAutoHideController {
        id: hide
        mode: AppearanceConfigService.barVisibilityMode
        configReady: AppearanceConfigService.ready
        windowDataReady: WindowService.providerReady
        targetScreen: root.screen
        barHeight: root.implicitHeight
        edgeMargin: 15
        pointerInsideBar: contentHoverHandler.hovered
        popupOpen: (barContentLoader.item?.statusArea?.keepBarOpen ?? false) || (barContentLoader.item?.globalMenu?.menuOpen ?? false) || (barContentLoader.item?.systemMenu?.menuOpen ?? false)
        launcherOpen: AppLauncherService.open
    }

    readonly property int reservedWorkspaceHeight: (root.barEnabled && hide.workspaceReserved) ? Math.round(implicitHeight + margins.top) : 0
    exclusiveZone: root.reservedWorkspaceHeight
    visible: root.barEnabled

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: (false && AppearanceConfigService.barVisibilityMode === "always") ? 6 : 0
        left: (false) ? 15 : 0
        right: (false) ? 15 : 0
    }

    function publishWorkspaceReservation() {
        if (root.screen)
            WorkspaceLayoutService.updateBar(root.screen, root.reservedWorkspaceHeight);
    }

    onScreenChanged: publishWorkspaceReservation()
    onReservedWorkspaceHeightChanged: publishWorkspaceReservation()
    Component.onCompleted: publishWorkspaceReservation()

    // ── Visual Bar content ──
    Item {
        id: barWrapper
        x: 0
        y: hide.offsetY
        width: root.width
        height: root.height
        opacity: hide.barOpacity
        visible: root.barEnabled && hide.revealProgress > 0.001

        // Passive observation of clicks elsewhere on this bar, without a backdrop
        // covering application windows or consuming their first click.
        TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            enabled: barContentLoader.item?.statusArea?.collectionExpanded ?? false
            onTapped: point => barContentLoader.item?.statusArea?.closeCollectionOutside(point.scenePosition.x, point.scenePosition.y)
        }
        Rectangle {
            anchors.fill: parent
            visible: true
            radius: 0
            color: AppearanceTokens.surface.barFill
            opacity: 1
            border.width: 0
            z: -1
        }

        HoverHandler {
            id: contentHoverHandler
        }

        Loader {
            id: barContentLoader
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            active: root.barEnabled
            sourceComponent: Component {
                Item {
                    id: barContentItem
                    readonly property alias statusArea: barStatusArea
                    readonly property alias globalMenu: barGlobalMenu
                    readonly property alias systemMenu: barSystemMenu

                    SystemMenu {
                        id: barSystemMenu
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    BarDateStatus {
                        id: barDateStatus
                        anchors {
                            left: barSystemMenu.right
                            leftMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        onActivated: sourceItem => barCalendar.toggle(sourceItem)
                    }

                    BarCalendarPopup {
                        id: barCalendar
                        barHosted: true
                    }

                    // This loader only exists in the standalone top Bar.
                    // DesktopEnvironment disables Bar entirely when it is
                    // integrated into the Dock, so the Dock never owns or
                    // fetches an application menu.
                    GlobalMenu {
                        id: barGlobalMenu
                        anchors.left: barDateStatus.right
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        maximumWidth: Math.max(0, barStatusArea.x - x - 18)
                    }

                    BarStatusArea {
                        id: barStatusArea
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        // The popup surfaces anchored to this cluster must know
                        // when the Bar has stopped sliding, because a popup's
                        // anchor rectangle is measured only when its window is
                        // created (see ControlCenterPanel.anchorSettled).
                        barRevealProgress: hide.revealProgress
                    }
                }
            }
        }
    }

    // ── Touch-top invisible trigger ──
    // A narrow hit area at the screen top reveals a hidden Bar without
    // intercepting normal top-edge interactions while it is visible.
    Item {
        id: topTriggerArea
        x: 0
        y: 0
        width: root.width
        height: (hide.handleActive && (hide.hidden || hide.phase === "RevealPending")) ? 2 : 0
        visible: hide.handleActive

        HoverHandler {
            id: topHoverHandler
            enabled: hide.handleActive && (hide.hidden || hide.phase === "RevealPending")
            onHoveredChanged: {
                if (hovered) {
                    hide.handleEntered();
                } else {
                    hide.handleExited();
                }
            }
        }

        TapHandler {
            enabled: hide.handleActive && (hide.hidden || hide.phase === "RevealPending")
            onTapped: hide.handleClicked()
        }
    }

    // Input mask mirror for visual content and top trigger.
    Item {
        id: barHitRegion
        x: 0
        y: hide.offsetY
        width: root.width
        height: root.height
        visible: false
    }

    Item {
        id: topHitRegion
        x: 0
        y: 0
        width: root.width
        height: (hide.handleActive && (hide.hidden || hide.phase === "RevealPending")) ? 2 : 0
        visible: false
    }

    // Shape the input region so transparent background passes clicks through.
    mask: Region {
        Region {
            item: barHitRegion
        }
        Region {
            item: topHitRegion
        }
    }
}
