/* SPDX-License-Identifier: GPL-2.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick
import org.kde.kirigami as Kirigami

FocusScope {
    id: expansion
    objectName: "applicationsExpansion"
    required property var controller
    required property var taskModel
    required property int launcherCount
    required property int gridWidth
    required property int gridHeight
    property var childRect: []
    property real reveal: 0
    property bool replaced: false
    property bool closing: false
    property bool wantsOpen: false
    readonly property alias frameSource: mask.source
    readonly property string framePrefix: "reveal-" + Math.round(reveal * 64)
    readonly property real surfaceWidth: controller.width + (gridWidth - controller.width) * reveal
    readonly property real surfaceHeight: controller.height + (gridHeight - controller.height) * reveal
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    signal closed()

    function focusTask(index) { grid.focusTask(index); }
    function openIsland() {
        wantsOpen = true;
        closing = false;
        if (replaced) animateTo(1);
        else if (mask.ready) handoff.restart();
    }
    function animateTo(value) {
        motion.stop();
        motion.to = value;
        motion.duration = value ? Kirigami.Units.longDuration : Kirigami.Units.shortDuration;
        motion.easing.type = value ? Easing.OutCubic : Easing.InCubic;
        motion.start();
    }
    function closeIsland() {
        wantsOpen = false;
        handoff.stop();
        closing = true;
        if (!replaced) closed();
        else animateTo(0);
    }
    function resetIsland() {
        wantsOpen = false;
        handoff.stop();
        motion.stop();
        replaced = false;
        closing = false;
        reveal = 0;
    }
    NumberAnimation {
        id: motion
        target: expansion
        property: "reveal"
        onFinished: {
            if (expansion.closing) expansion.closed();
            else grid.focusTask(expansion.controller.overflowFocusIndex);
        }
    }
    Timer {
        id: handoff
        interval: 18
        onTriggered: {
            expansion.replaced = true;
            expansion.animateTo(1);
        }
    }
    ApplicationsRevealMask {
        id: mask
        sizes: [expansion.width, expansion.height, expansion.controller.width,
            expansion.controller.height, expansion.gridWidth, expansion.gridHeight]
        childRect: expansion.childRect
        onReadyChanged: if (ready && expansion.wantsOpen && !expansion.replaced) handoff.restart()
    }
    Rectangle {
        id: surface
        anchors.bottom: parent.bottom
        width: expansion.surfaceWidth
        height: expansion.surfaceHeight
        radius: Math.min(24, expansion.controller.height / 3)
        color: expansion.smartTheme.shell
        border.width: 1
        border.color: expansion.smartTheme.edge
        clip: true
        Rectangle {
            anchors.fill: parent
            anchors.margins: Math.min(7, expansion.controller.height * 7 / 72)
            radius: 16
            color: expansion.smartTheme.inner
        }
        ApplicationsStrip {
            anchors.bottom: parent.bottom
            width: expansion.controller.width
            height: expansion.controller.height
            taskModel: expansion.taskModel
            launcherCount: expansion.launcherCount
            normalCellSize: expansion.controller.cellSize
            paintBackground: false
            opacity: Math.max(0, 1 - expansion.reveal * 3)
            visible: opacity > 0
            enabled: false
        }
        TaskList {
            id: grid
            anchors.bottom: parent.bottom
            width: expansion.gridWidth
            height: expansion.gridHeight
            taskModel: expansion.taskModel
            launcherCount: expansion.launcherCount
            normalCellSize: expansion.controller.cellSize
            gridMode: true
            includeLaunchpad: true
            maximumHeight: expansion.gridHeight
            opacity: Math.max(0, (expansion.reveal - .25) / .75)
            visible: opacity > 0
            enabled: expansion.reveal >= 1 && !expansion.closing && !expansion.controller.contextMenuVisible
            onLaunchpadRequested: expansion.controller.toggleLaunchpad()
            onActivated: (index, active) => expansion.controller.activateTask(index, active)
            onNewInstanceRequested: index => expansion.controller.newTaskInstance(index)
            onContextRequested: (index, task) => expansion.controller.openTaskMenu(index, task)
            onPreviewEntered: (index, task, label) => {
                expansion.controller.overflowFocusIndex = index;
                expansion.controller.schedulePreview(index, task, label);
            }
            onPreviewExited: expansion.controller.leaveTaskPreview()
            onDismissed: expansion.controller.dismissPopup(true)
        }
    }
    Component.onCompleted: openIsland()
}
