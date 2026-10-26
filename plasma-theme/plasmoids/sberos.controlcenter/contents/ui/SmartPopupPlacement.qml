/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtQuick.Window

Item {
    id: placement
    required property Item content
    required property Item anchorItem
    required property rect screenGeometry
    property string alignment: "center"
    property bool overlapPanel: false
    readonly property var popupWindow: content.Window.window

    Item {
        id: anchor
        parent: placement.anchorItem
        width: 0
        height: 0
        readonly property point origin: placement.anchorItem.mapToGlobal(0, 0)
        x: {
            const w = placement.popupWindow;
            if (!w) return 0;
            if (placement.alignment === "left") return w.width / 2 - (w.leftPadding || 0);
            if (placement.alignment === "right") return placement.screenGeometry.x + placement.screenGeometry.width - 16
                + (w.rightPadding || 0) - w.width / 2 - origin.x;
            return placement.screenGeometry.x + placement.screenGeometry.width / 2 - origin.x;
        }
        y: (placement.overlapPanel ? placement.anchorItem.height : -8)
            + (placement.popupWindow?.bottomPadding || 0)
    }

    function apply() {
        const w = popupWindow;
        if (!w || !anchorItem) return;
        // Plasma 6.7 PopupPlasmaWindow supports overlap through its floating API.
        w.floating = overlapPanel;
        w.animated = false;
        w.margin = overlapPanel ? 0 : 4;
        w.popupDirection = Qt.TopEdge;
        w.visualParent = anchor;
        // Keep the native blur/mask but draw the Smart Panel material only once.
        for (const child of w.contentItem.children) {
            if (String(child).indexOf("PlasmaQuick::DialogBackground") === 0) child.opacity = 0;
        }
    }
    onPopupWindowChanged: Qt.callLater(apply)
    Component.onCompleted: Qt.callLater(apply)
    Connections {
        target: placement.popupWindow
        ignoreUnknownSignals: true
        function onVisibleChanged() { if (placement.popupWindow.visible) Qt.callLater(placement.apply); }
    }
}
