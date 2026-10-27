/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtTest
import "../plasmoids/sberos.smarttasks/contents/ui" as Applications

TestCase {
    id: test
    name: "ApplicationsReveal"
    visible: true
    width: 620
    height: 168
    when: windowShown
    QtObject {
        id: controller
        property int width: 620
        property int height: 72
        property int cellSize: 48
        property int overflowFocusIndex: 12
        property bool contextMenuVisible: false
        function leaveTaskPreview() {}
    }
    ListModel { id: apps }
    Applications.ApplicationsExpansion {
        id: island
        width: 620
        height: 168
        controller: controller
        taskModel: apps
        launcherCount: 2
        gridWidth: 504
        gridHeight: 168
    }
    SignalSpy { id: closedSpy; target: island; signalName: "closed" }
    function initTestCase() {
        for (let index = 0; index < 30; index++)
            apps.append({AppName: "App " + index, decoration: "application-x-executable", IsLauncher: true})
    }
    function init() { island.resetIsland(); closedSpy.clear(); }
    function test_openAndCloseKeepsHostAndLowerEdge() {
        compare(island.surfaceWidth, 620)
        compare(island.surfaceHeight, 72)
        island.openIsland()
        tryCompare(island, "replaced", true, 3000)
        tryCompare(island, "reveal", 1)
        compare(island.surfaceWidth, 504)
        compare(island.surfaceHeight, 168)
        compare(island.width, 620)
        compare(island.height, 168)
        compare(island.framePrefix, "reveal-64")
        island.closeIsland()
        compare(island.closing, true)
        compare(island.replaced, true)
        tryCompare(closedSpy, "count", 1)
        compare(island.surfaceWidth, 620)
        compare(island.surfaceHeight, 72)
        compare(island.framePrefix, "reveal-0")
    }
    function test_reopenDuringCollapse() {
        island.openIsland()
        tryCompare(island, "reveal", 1)
        island.closeIsland()
        island.openIsland()
        tryCompare(island, "reveal", 1)
        verify(!island.closing)
        compare(closedSpy.count, 0)
    }
}
