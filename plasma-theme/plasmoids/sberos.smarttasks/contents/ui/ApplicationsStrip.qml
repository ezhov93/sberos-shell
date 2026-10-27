/* SPDX-License-Identifier: GPL-2.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick

FocusScope {
    id: strip
    required property var taskModel
    required property int launcherCount
    property int normalCellSize: 48
    property bool vertical: false
    property bool overflowExpanded: false
    property bool launcherOpen: false
    readonly property int launcherLength: normalCellSize + Math.round(normalCellSize / 6)
    readonly property alias metrics: tasks.metrics
    readonly property alias overflowButton: tasks.overflowButton
    readonly property alias launchpadButton: launcher
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}

    signal launchpadRequested()
    signal activated(int index, bool active)
    signal newInstanceRequested(int index)
    signal contextRequested(int index, var task)
    signal previewEntered(int index, var task, string label)
    signal previewExited()
    signal overflowRequested()
    signal dismissed()

    function focusTask(index) { tasks.focusTask(index); }

    Rectangle {
        anchors.fill: parent
        radius: Math.min(24, height / 3)
        color: strip.smartTheme.shell
        border.width: 1
        border.color: strip.smartTheme.edge
        Rectangle {
            anchors.fill: parent
            anchors.margins: Math.min(7, strip.normalCellSize * 7 / 48)
            radius: 16
            color: strip.smartTheme.inner
        }
    }
    LaunchpadButton {
        id: launcher
        x: strip.vertical ? (strip.width - width) / 2 : 0
        width: strip.normalCellSize
        height: strip.vertical ? strip.normalCellSize : strip.height
        iconSize: Math.round(strip.normalCellSize * 2 / 3)
        launcherOpen: strip.launcherOpen
        onClicked: strip.launchpadRequested()
        Keys.onRightPressed: tasks.focusTask(0)
        Keys.onDownPressed: tasks.focusTask(0)
        Keys.onLeftPressed: tasks.focusTask(tasks.lastIndex)
        Keys.onUpPressed: tasks.focusTask(tasks.lastIndex)
    }
    TaskList {
        id: tasks
        x: strip.vertical ? 0 : strip.launcherLength
        y: strip.vertical ? strip.launcherLength : 0
        width: strip.vertical ? strip.width : Math.max(0, strip.width - strip.launcherLength)
        height: strip.vertical ? Math.max(0, strip.height - strip.launcherLength) : strip.height
        taskModel: strip.taskModel
        launcherCount: strip.launcherCount
        normalCellSize: strip.normalCellSize
        vertical: strip.vertical
        overflowExpanded: strip.overflowExpanded
        leadingControl: launcher
        onActivated: (index, active) => strip.activated(index, active)
        onNewInstanceRequested: index => strip.newInstanceRequested(index)
        onContextRequested: (index, task) => strip.contextRequested(index, task)
        onPreviewEntered: (index, task, label) => strip.previewEntered(index, task, label)
        onPreviewExited: strip.previewExited()
        onOverflowRequested: strip.overflowRequested()
        onDismissed: strip.dismissed()
    }
}
