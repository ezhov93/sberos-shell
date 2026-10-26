/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtQuick.Window
import org.kde.ksvg as KSvg

Item {
    id: placement
    required property Item content
    required property Item anchorItem
    required property rect screenGeometry
    property string alignment: "center"
    property bool overlapPanel: false
    property url frameSource: Qt.resolvedUrl("../assets/smart-panel/popup-frame.svg")
    property int frameBorders: KSvg.FrameSvg.AllBorders
    readonly property var popupWindow: content.Window.window
    property bool updatingFrame: false

    Item {
        id: anchor
        parent: placement.anchorItem
        width: 0
        height: 0
        readonly property point origin: placement.anchorItem.mapToGlobal(0, 0)
        x: {
            const w = placement.popupWindow;
            if (!w) return 0;
            if (placement.alignment === "left") return w.width / 2 - Math.round(w.leftPadding || 0);
            if (placement.alignment === "right") return placement.screenGeometry.x + placement.screenGeometry.width - 16
                + Math.round(w.rightPadding || 0) - w.width / 2 - origin.x;
            return placement.screenGeometry.x + placement.screenGeometry.width / 2 - origin.x;
        }
        y: (placement.overlapPanel ? placement.anchorItem.height : -8)
            + Math.round(placement.popupWindow?.bottomPadding || 0)
    }

    function applyFrame() {
        const w = popupWindow;
        if (!w || updatingFrame) return;
        updatingFrame = true;
        // Plasma 6.7 derives blur/contrast and resize margins from this frame.
        // Match our rounded surface without adding native padding around it.
        for (const child of w.contentItem.children) {
            if (String(child).indexOf("PlasmaQuick::DialogBackground") !== 0) continue;
            child.opacity = 0;
            for (const frame of child.children) {
                if (frame.imagePath === undefined || frame.fixedMargins === undefined) continue;
                frame.imagePath = decodeURIComponent(placement.frameSource
                    .toString().replace(/^file:\/\//, ""));
                // Window borders also select the native theme's shadow tiles.
                // Remove those tiles, then retain all corners in our blur mask.
                w.borders = 0;
                frame.enabledBorders = placement.frameBorders;
            }
        }
        updatingFrame = false;
    }

    function apply() {
        const w = popupWindow;
        if (!w || !anchorItem) return;
        applyFrame();
        // Plasma 6.7 PopupPlasmaWindow supports overlap through its floating API.
        w.floating = overlapPanel;
        w.animated = false;
        w.margin = overlapPanel ? 0 : 8;
        w.popupDirection = Qt.TopEdge;
        w.visualParent = anchor;
        // Resizing the frame can leave Plasma's placement at the previous size.
        Qt.callLater(() => {
            if (placement.popupWindow !== w) return;
            w.animated = false;
            w.requestUpdate();
        });
    }
    onPopupWindowChanged: Qt.callLater(apply)
    onOverlapPanelChanged: Qt.callLater(apply)
    onFrameSourceChanged: Qt.callLater(apply)
    onFrameBordersChanged: Qt.callLater(apply)
    Component.onCompleted: Qt.callLater(apply)
    Connections {
        target: placement.popupWindow
        ignoreUnknownSignals: true
        function onBordersChanged() { placement.applyFrame(); }
        function onVisibleChanged() { if (placement.popupWindow.visible) Qt.callLater(placement.apply); }
    }
}
