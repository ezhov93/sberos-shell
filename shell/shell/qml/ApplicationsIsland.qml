// SPDX-License-Identifier: GPL-3.0-or-later
// The applications surface grows inside the existing Dock window.
import QtQuick
import SircaShell

Item {
    id: island
    required property rect compactRect
    required property int entryCount
    required property real maximumHeight
    property bool expanded: false
    property int cellWidth: 40
    property int cellHeight: 48
    readonly property int inset: 12
    readonly property int columns: Math.max(1, Math.min(12, entryCount,
        Math.floor((compactRect.width - 2 * inset) / cellWidth)))
    readonly property real expandedWidth: columns * cellWidth + 2 * inset
    readonly property real expandedHeight: Math.max(compactRect.height,
        Math.min(maximumHeight, Math.ceil(entryCount / columns) * cellHeight + 2 * inset))
    property real reveal: expanded ? 1 : 0
    readonly property bool gridActive: expanded || reveal > 0.001
    readonly property rect surfaceRect: Qt.rect(x, y, width, height)

    x: compactRect.x
    y: compactRect.y + compactRect.height - height
    width: compactRect.width + (expandedWidth - compactRect.width) * reveal
    height: compactRect.height + (expandedHeight - compactRect.height) * reveal

    Behavior on reveal {
        NumberAnimation {
            duration: Config.normal
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: Config.panelSurface
        border.width: 1
        border.color: Config.panelOutline
        Rectangle {
            anchors.fill: parent
            anchors.margins: 7
            radius: 17
            color: Config.panelInnerSurface
        }
    }
}
