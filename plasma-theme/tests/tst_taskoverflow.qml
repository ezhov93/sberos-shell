/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtTest
import "../plasmoids/sberos.smarttasks/contents/ui" as Tasks

TestCase {
    id: testCase
    name: "TaskOverflow"
    width: 640
    height: 400
    when: windowShown

    Tasks.TaskLayoutMetrics {
        id: metrics
        count: 6
        launcherCount: 2
        availableLength: 248
    }

    ListModel { id: apps }
    Tasks.TaskList {
        id: list
        width: 248
        height: 72
        taskModel: apps
        launcherCount: 2
    }
    SignalSpy { id: overflowSpy; target: list; signalName: "overflowRequested" }
    SignalSpy { id: activationSpy; target: list; signalName: "activated" }
    SignalSpy { id: contextSpy; target: list; signalName: "contextRequested" }
    SignalSpy { id: dismissSpy; target: list; signalName: "dismissed" }

    function init() {
        apps.clear()
        for (let index = 0; index < 30; index++)
            apps.append({AppName: "Application " + index, decoration: "application-x-executable", IsLauncher: true})
        list.gridMode = false
        list.overflowExpanded = false
        list.width = 248
        list.height = 72
        overflowSpy.clear()
        activationSpy.clear()
        contextSpy.clear()
        dismissSpy.clear()
    }

    function test_capacity_data() {
        return [
            {tag: "normal", count: 4, launchers: 2, width: 208, compact: false, hidden: 0},
            {tag: "shrinkBeforeOverflow", count: 5, launchers: 2, width: 248, compact: true, hidden: 0},
            {tag: "exactCompactFit", count: 6, launchers: 2, width: 256, compact: true, hidden: 0},
            {tag: "reserveCounterAndSeparator", count: 6, launchers: 2, width: 248, compact: true, hidden: 2},
            {tag: "separatorNotVisible", count: 7, launchers: 2, width: 128, compact: true, hidden: 5},
            {tag: "noLaunchers", count: 7, launchers: 0, width: 168, compact: true, hidden: 4},
            {tag: "counterOnly", count: 9, launchers: 2, width: 64, compact: true, hidden: 9},
            {tag: "empty", count: 0, launchers: 0, width: 64, compact: false, hidden: 0}
        ]
    }

    function test_capacity(data) {
        metrics.count = data.count
        metrics.launcherCount = data.launchers
        metrics.availableLength = data.width
        compare(metrics.compact, data.compact)
        compare(metrics.hiddenCount, data.hidden)
        compare(metrics.visibleCount + metrics.hiddenCount, data.count)
        const used = metrics.lengthFor(metrics.visibleCount, metrics.cellSize) + metrics.padding
            + (metrics.hiddenCount ? metrics.cellSize : 0)
        verify(used <= data.width)
        if (metrics.hiddenCount)
            verify(metrics.lengthFor(metrics.visibleCount + 1, metrics.cellSize) + metrics.cellSize + metrics.padding > data.width)
    }

    function test_counterTracksModel() {
        compare(list.metrics.hiddenCount, 26)
        compare(list.overflowButton.text, "+26")
        apps.remove(29)
        compare(list.overflowButton.text, "+25")
        apps.remove(5, 24)
        compare(list.metrics.hiddenCount, 0)
        compare(list.overflowButton.visible, false)
    }

    function test_counterKeyboard() {
        list.focusTask(list.metrics.visibleCount)
        verify(list.overflowButton.activeFocus)
        keyClick(Qt.Key_Return)
        compare(overflowSpy.count, 1)
        keyClick(Qt.Key_Space)
        compare(overflowSpy.count, 2)
        list.overflowExpanded = true
        compare(list.overflowButton.opacity, 0)
        compare(list.overflowButton.enabled, false)
    }

    function test_gridNavigationAndActions() {
        list.gridMode = true
        list.width = 504
        list.height = 120
        list.focusTask(0)
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Return)
        compare(activationSpy.signalArguments[0][0], 12)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_F10, Qt.ShiftModifier)
        compare(contextSpy.signalArguments[0][0], 13)
        list.focusTask(29)
        verify(findChild(list, "taskViewport").contentY > 0)
        keyClick(Qt.Key_Return)
        compare(activationSpy.signalArguments[1][0], 29)
        keyClick(Qt.Key_Escape)
        compare(dismissSpy.count, 1)
    }
}
