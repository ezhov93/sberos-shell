import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../Kos/Ui"

// Full application grid opened from the Smart Panel's +N affordance.
AnimatedPopupWindow {
    id: popup

    required property Item anchorItem
    property var entries: []
    signal entryActivated(var entry)

    readonly property int columns: 12
    readonly property int cellWidth: 40
    readonly property int cellHeight: 48
    readonly property int gridSpacing: 0
    readonly property int framePadding: 7
    readonly property int rowCount: Math.max(1, Math.ceil(entries.length / columns))

    implicitWidth: columns * cellWidth + 2 * framePadding + 2
    implicitHeight: rowCount * cellHeight + 2 * framePadding + 2
    color: "transparent"
    grabFocus: false
    motionOrigin: Item.Bottom

    PopupAnchorBinding {
        popupAnchor: popup.anchor
        sourceItem: popup.anchorItem
    }

    anchor {
        edges: Edges.Top
        gravity: Edges.Top
        adjustment: PopupAdjustment.Slide
        margins.top: -8
    }

    onEffectiveOpenChanged: {
        if (!effectiveOpen && DockModelService.activeDockPopup === popup)
            DockModelService.releaseDockPopup(popup)
    }

    FrostedSurface {
        anchors.fill: parent
        radius: 24
        cornerExponent: 2
        blurSigma: 22
    }

    OpaqueSurface {
        anchors.fill: parent
        anchors.margins: popup.framePadding
        radius: 17

        Grid {
            anchors.centerIn: parent
            columns: popup.columns
            spacing: popup.gridSpacing

            Repeater {
                model: popup.entries

                delegate: Item {
                    required property var modelData
                    required property int index
                    width: popup.cellWidth
                    height: popup.cellHeight

                    AppIcon {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        source: modelData.icon ?? ""
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: popup.entryActivated(modelData)
                    }
                }
            }
        }
    }
}
