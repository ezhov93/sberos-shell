/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtTest
import "../plasmoids/sberos.smarttasks/contents/ui" as Applications

TestCase {
    name: "CombinedApplications"
    visible: true
    width: 640
    height: 400
    when: windowShown
    ListModel { id: apps }
    Applications.ApplicationsStrip {
        id: strip
        width: 304
        height: 72
        taskModel: apps
        launcherCount: 2
    }
    SignalSpy { id: launchpadSpy; target: strip; signalName: "launchpadRequested" }
    SignalSpy { id: taskSpy; target: strip; signalName: "activated" }
    SignalSpy { id: overflowSpy; target: strip; signalName: "overflowRequested" }

    function init() {
        apps.clear();
        for (let index = 0; index < 6; index++)
            apps.append({AppName: "App " + index, decoration: "application-x-executable", IsLauncher: true});
        strip.width = 304;
        strip.normalCellSize = 48;
        launchpadSpy.clear(); taskSpy.clear(); overflowSpy.clear();
    }
    function test_reserveLaunchpadBeforeCountingOverflow() {
        compare(strip.launcherLength, 56);
        compare(strip.metrics.availableLength, 248);
        compare(strip.metrics.hiddenCount, 2);
        strip.width = 312;
        compare(strip.metrics.hiddenCount, 0);
    }
    function test_launchpadAndTasksRemainIndependent() {
        mouseClick(strip.launchpadButton, 24, 36);
        compare(launchpadSpy.count, 1);
        compare(taskSpy.count, 0);
        strip.focusTask(0);
        keyClick(Qt.Key_Return);
        compare(taskSpy.count, 1);
        compare(launchpadSpy.count, 1);
    }
    function test_keyboardCrossesLaunchpadBoundary() {
        strip.focusTask(0);
        keyClick(Qt.Key_Left);
        verify(strip.launchpadButton.activeFocus);
        keyClick(Qt.Key_Right);
        verify(!strip.launchpadButton.activeFocus);
        keyClick(Qt.Key_Return);
        compare(taskSpy.count, 1);
        strip.launchpadButton.forceActiveFocus();
        keyClick(Qt.Key_Space);
        compare(launchpadSpy.count, 1);
    }
    function test_counterAfterLaunchpad() {
        mouseClick(strip.overflowButton, 20, 24);
        compare(overflowSpy.count, 1);
        compare(launchpadSpy.count, 0);
        compare(taskSpy.count, 0);
    }
}
