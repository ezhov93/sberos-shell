/*
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1
import QtQml 2.15

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.kwindowsystem 1.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.shell.panel as Panel

import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    Component.onCompleted: Qt.callLater(() => {
        panel.floating = false
        panel.floatingApplets = false
        panel.opacityMode = Panel.Global.Translucent
    })

    Connections {
        target: panel

        function onFloatingChanged() {
            if (panel.floating) {
                panel.floating = false
            }
        }

        function onFloatingAppletsChanged() {
            if (panel.floatingApplets) {
                panel.floatingApplets = false
            }
        }
    }

    Connections {
        target: root

        function onContainmentChanged() {
            // HACK: add PanelView into the containment so that it can be used
            if (containment.panel !== undefined) {
                containment.panel = panel;
            }
        }
    }

    property real dpi: root.Window.window ? root.Window.window.devicePixelRatio : 1.0

    property Item containment
    readonly property bool verticalPanel: containment?.plasmoid?.formFactor === PlasmaCore.Types.Vertical

    readonly property real spacingAtMinSize: Math.round(Math.max(1, (verticalPanel ? root.width : root.height) - Kirigami.Units.iconSizes.smallMedium)/2)
    KSvg.FrameSvgItem {
        id: thickPanelSvg
        visible: false
        prefix: 'thick'
        imagePath: "widgets/panel-background"
    }
    // NOTE: Many of the properties in this file are accessed directly in C++ PanelView!
    // If you change these, make sure to also correct the related code in panelview.cpp.

    readonly property bool topEdge: containment?.plasmoid?.location === PlasmaCore.Types.TopEdge
    readonly property bool leftEdge: containment?.plasmoid?.location === PlasmaCore.Types.LeftEdge
    readonly property bool rightEdge: containment?.plasmoid?.location === PlasmaCore.Types.RightEdge
    readonly property bool bottomEdge: containment?.plasmoid?.location === PlasmaCore.Types.BottomEdge

    // PanelView keeps these values in its geometry contract; floating margins stay zero.
    readonly property int fixedBottomFloatingPadding: 0
    readonly property int fixedLeftFloatingPadding: 0
    readonly property int fixedRightFloatingPadding: 0
    readonly property int fixedTopFloatingPadding: 0
    readonly property int bottomFloatingPadding: 0
    readonly property int leftFloatingPadding: 0
    readonly property int rightFloatingPadding: 0
    readonly property int topFloatingPadding: 0

    readonly property int topPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.top + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int bottomPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.bottom + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int leftPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.left + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int rightPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.right + Kirigami.Units.smallSpacing, spacingAtMinSize));

    readonly property int minPanelHeight: translucentItem.minimumDrawingHeight
    readonly property int minPanelWidth: translucentItem.minimumDrawingWidth

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    // We need to have a little gap between the raw visibleWindowsModel count
    // and actually determining if a window is touching.
    // This is because certain dialog windows start off with a position of (screenwidth/2, screenheight/2)
    // and they register as "touching" in the split-second before KWin can place them correctly.
    // This avoids the panel flashing if it is auto-hide etc and such a window is shown.
    // Examples of such windows: properties of a file on desktop, or portal "open with" dialog
    property bool touchingWindow: false
    property bool touchingWindowDirect: visibleWindowsModel.count > 0
    property bool showingDesktop: KWindowSystem.showingDesktop
    Timer {
        id: touchingWindowDebounceTimer
        interval: 10  // ms, I find that this value is enough while not causing unresponsiveness while dragging windows close
        onTriggered: root.touchingWindow = !KWindowSystem.showingDesktop && root.touchingWindowDirect
    }
    onTouchingWindowDirectChanged: touchingWindowDebounceTimer.start()
    onShowingDesktopChanged: touchingWindowDebounceTimer.start()

    TaskManager.TasksModel {
        id: visibleWindowsModel
        filterByVirtualDesktop: true
        filterByActivity: true
        filterByScreen: false
        filterByRegion: TaskManager.RegionFilterMode.Intersect
        filterHidden: true
        filterMinimized: true

        screenGeometry: panel.screenGeometry
        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity

        groupMode: TaskManager.TasksModel.GroupDisabled

        Binding on regionGeometry {
            delayed: true
            value: panel.width, panel.height, panel.x, panel.y, panel.dogdeGeometryByDistance(panel.visibilityMode === Panel.Global.DodgeWindows ? -1 : 1) // +1 is for overlap detection, -1 is for snapping to panel
        }
    }

    Connections {
        target: root.containment?.plasmoid ?? null
        function onActivated() {
            if (root.containment.plasmoid.status === PlasmaCore.Types.AcceptingInputStatus) {
                root.containment.plasmoid.status = PlasmaCore.Types.PassiveStatus;
            } else {
                root.containment.plasmoid.status = PlasmaCore.Types.AcceptingInputStatus;
            }
        }
    }

    // PanelView reads these compatibility properties; floating mode is fixed off.
    readonly property int floatingnessAnimationDuration: Kirigami.Units.longDuration
    property double floatingnessTarget: 0.0
    property double floatingness: 0.0

    // PanelOpacity is a value in [0, 1] that's used as the opacity of the opaque elements over the transparent ones; values between 0 and 1 are used for animations
    property double panelOpacity
    Behavior on panelOpacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    // PanelView reads these properties while the panel remains attached to its edge.
    readonly property bool hasShadows: true
    property var panelMask: panelOpacity === 1 ? opaqueItem.mask : translucentItem.mask

    // PanelView reads the mask offset; an attached panel has no floating offset.
    readonly property point floatingTranslucentItemOffset: Qt.point(0, 0)

    KSvg.FrameSvgItem {
        id: translucentItem
        visible: panelOpacity !== 1
        enabledBorders: panel.enabledBorders
        anchors.fill: parent
        /*anchors.rightMargin: {
            if(containment) {
                if(!containment.isHorizontal) return 0;
                return containment.isShowDesktopApplet ? containment.isShowDesktopApplet.Layout.maximumWidth + Kirigami.Units.mediumSpacing : 0;
            }
            return 0;
        }*/
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: opaqueItem
        visible: panelOpacity !== 0
        opacity: panelOpacity
        enabledBorders: panel.enabledBorders
        anchors.fill: parent
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
    }

    Keys.onEscapePressed: {
        root.parent.focus = false
    }

    property bool isOpaque: panel.opacityMode === Panel.Global.Opaque
    property bool isTransparent: panel.opacityMode === Panel.Global.Translucent
    property bool isAdaptive: panel.opacityMode === Panel.Global.Adaptive
    property bool hasCompositing: KWindowSystem.isPlatformX11 ? KX11Extras.compositingActive : true
    readonly property bool screenCovered: touchingWindow && panel.visibilityMode == Panel.Global.NormalPanel
    property var stateTriggers: [touchingWindow, isOpaque, isAdaptive, isTransparent, hasCompositing, containment]
    onStateTriggersChanged: {
        let opaqueApplets = false
        if (isOpaque || (touchingWindow && isAdaptive)) {
            panelOpacity = 1
            opaqueApplets = true
        } else {
            panelOpacity = 0
        }
        if (!KWindowSystem.isPlatformWayland && !KX11Extras.compositingActive) {
            opaqueApplets = false
            panelOpacity = 0
        }

        // Not using panelOpacity to check as it has a NumberAnimation, and it will thus
        // be still read as the initial value here, before the animation starts.
        if (containment) {
            if (opaqueApplets) {
                containment.plasmoid.containmentDisplayHints |= PlasmaCore.Types.ContainmentPrefersOpaqueBackground
            } else {
                containment.plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersOpaqueBackground
            }
            containment.plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersFloatingApplets
        }
    }

    function adjustPrefix() {
        if (!containment) {
            return "";
        }
        var pre;
        switch (containment.plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            pre = "west";
            break;
        case PlasmaCore.Types.TopEdge:
            pre = "north";
            break;
        case PlasmaCore.Types.RightEdge:
            pre = "east";
            break;
        case PlasmaCore.Types.BottomEdge:
            pre = "south";
            break;
        default:
            pre = "";
            break;
        }
        translucentItem.prefix = opaqueItem.prefix = [pre, ""];
    }

    onContainmentChanged: {
        if (!containment) {
            return;
        }
        containment.parent = containmentParent;
        containment.visible = true;
        containment.anchors.fill = containmentParent;
        containment.plasmoid.locationChanged.connect(adjustPrefix);
        adjustPrefix();
    }

    Binding {
        target: panel
        property: "length"
        when: containment
        value: {
            if (!containment) {
                return;
            }
            if (verticalPanel) {
                return containment.Layout.preferredHeight
            } else {
                return containment.Layout.preferredWidth
            }
        }
        restoreMode: Binding.RestoreBinding
    }

    Binding {
        target: panel
        property: "backgroundHints"
        when: containment
        value: {
            if (!containment) {
                return;
            }

            return containment.plasmoid.backgroundHints;
        }
        restoreMode: Binding.RestoreBinding
    }

    KSvg.FrameSvgItem {

        Accessible.name: i18n("Panel Focus Indicator")

        x: root.verticalPanel || !panel.activeFocusItem
            ? translucentItem.x
            : Math.max(panel.activeFocusItem.Kirigami.ScenePosition.x, panel.activeFocusItem.Kirigami.ScenePosition.x)
        y: root.verticalPanel && panel.activeFocusItem
            ? Math.max(panel.activeFocusItem.Kirigami.ScenePosition.y, panel.activeFocusItem.Kirigami.ScenePosition.y)
            : translucentItem.y

        width: panel.activeFocusItem
            ? (root.verticalPanel ? translucentItem.width : Math.min(panel.activeFocusItem.width, panel.activeFocusItem.width))
            : 0
        height: panel.activeFocusItem
            ? (root.verticalPanel ?  Math.min(panel.activeFocusItem.height, panel.activeFocusItem.height) : translucentItem.height)
            : 0

        visible: panel.active && panel.activeFocusItem

        imagePath: "widgets/tabbar"
        prefix: {
            if (!root.containment) {
                return "";
            }
            var prefix = ""
            switch (root.containment.plasmoid.location) {
                case PlasmaCore.Types.LeftEdge:
                    prefix = "west-active-tab";
                    break;
                case PlasmaCore.Types.TopEdge:
                    prefix = "north-active-tab";
                    break;
                case PlasmaCore.Types.RightEdge:
                    prefix = "east-active-tab";
                    break;
                default:
                    prefix = "south-active-tab";
            }
            if (!hasElementPrefix(prefix)) {
                prefix = "active-tab";
            }
            return prefix;
        }
    }
    Item {
        id: containmentParent
        anchors.fill: isOpaque ? opaqueItem : translucentItem
        //anchors.leftMargin: root.verticalPanel ? 0 : -Kirigami.Units.mediumSpacing
        width: root.verticalPanel ? panel.thickness : root.width
        height: root.verticalPanel ? root.height : panel.thickness
    }
}
