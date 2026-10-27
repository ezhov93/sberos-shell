// Search results and the active notification extend the Oska island in place.
import QtQuick
import SircaShell

Item {
    id: island
    required property rect compactRect
    required property real contentHeight
    required property real maximumHeight
    property bool expanded: false
    property real reveal: expanded ? 1 : 0
    readonly property real expansionHeight: Math.max(0, Math.min(contentHeight, maximumHeight))
    readonly property rect surfaceRect: Qt.rect(x, y, width, height)
    readonly property rect contentRect: Qt.rect(x, y, width, Math.max(0, height - compactRect.height))

    x: compactRect.x
    y: compactRect.y + compactRect.height - height
    width: compactRect.width
    height: compactRect.height + expansionHeight * reveal

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
