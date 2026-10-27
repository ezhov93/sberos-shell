/* SPDX-License-Identifier: GPL-2.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic

FocusScope {
    id: root
    required property var taskModel
    required property int launcherCount
    property int normalCellSize: 48
    property bool vertical: false
    property Item leadingControl: null
    property bool gridMode: false
    property bool includeLaunchpad: false
    readonly property alias launchpadButton: launcher
    property bool overflowExpanded: false
    property int maximumHeight: 480
    readonly property alias metrics: metrics
    readonly property alias overflowButton: overflowButton
    readonly property int gridColumns: Math.max(1, Math.min(12, Math.floor((width - 24) / metrics.compactCellSize)))
    readonly property int lastIndex: gridMode ? taskModel.count - 1
        : metrics.hiddenCount > 0 ? metrics.visibleCount : taskModel.count - 1
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}

    signal launchpadRequested()
    signal activated(int index, bool active)
    signal newInstanceRequested(int index)
    signal contextRequested(int index, var task)
    signal previewEntered(int index, var task, string label)
    signal previewExited()
    signal overflowRequested()
    signal dismissed()

    implicitWidth: gridMode ? Math.min(12, Math.max(1, taskModel.count + (includeLaunchpad ? 1 : 0))) * metrics.compactCellSize + 24
        : vertical ? 72 : metrics.preferredLength
    implicitHeight: gridMode ? Math.min(maximumHeight,
        Math.ceil((taskModel.count + (includeLaunchpad ? 1 : 0)) / gridColumns) * normalCellSize + 24)
        : vertical ? metrics.preferredLength : normalCellSize

    TaskLayoutMetrics {
        id: metrics
        count: root.taskModel.count
        launcherCount: root.launcherCount
        availableLength: root.vertical ? root.height : root.width
        normalCellSize: root.normalCellSize
    }

    function focusTask(index) {
        const item = gridMode && includeLaunchpad && index === -1 ? launcher : !gridMode && index === metrics.visibleCount && metrics.hiddenCount > 0
            ? overflowButton : tasks.itemAt(Math.max(0, Math.min(lastIndex, index)));
        if (!item) return;
        item.forceActiveFocus(Qt.TabFocusReason);
        if (gridMode) {
            viewport.contentY = Math.max(0, Math.min(viewport.contentHeight - viewport.height,
                Math.max(item.y + item.height - viewport.height, Math.min(viewport.contentY, item.y))));
        }
    }

    function moveFocus(step) {
        let current = overflowButton.activeFocus ? metrics.visibleCount : -1;
        for (let index = 0; index < tasks.count; index++) {
            if (tasks.itemAt(index)?.activeFocus) { current = index; break; }
        }
        if (gridMode && includeLaunchpad) {
            const total = taskModel.count + 1;
            focusTask((current + 1 + step + total) % total - 1);
            return;
        }
        if (!gridMode && current === 0 && step < 0 && leadingControl) {
            leadingControl.forceActiveFocus(Qt.BacktabFocusReason);
            return;
        }
        if (lastIndex >= 0) focusTask((current + step + lastIndex + 1) % (lastIndex + 1));
    }

    Keys.onEscapePressed: event => { root.dismissed(); event.accepted = true; }
    Keys.onLeftPressed: event => { moveFocus(-1); event.accepted = true; }
    Keys.onRightPressed: event => { moveFocus(1); event.accepted = true; }
    Keys.onUpPressed: event => { moveFocus(gridMode ? -gridColumns : -1); event.accepted = true; }
    Keys.onDownPressed: event => { moveFocus(gridMode ? gridColumns : 1); event.accepted = true; }
    Keys.onTabPressed: event => { if (gridMode) moveFocus(1); event.accepted = gridMode; }
    Keys.onBacktabPressed: event => { if (gridMode) moveFocus(-1); event.accepted = gridMode; }

    Flickable {
        id: viewport
        objectName: "taskViewport"
        anchors.fill: parent
        anchors.margins: root.gridMode ? 12 : 0
        contentWidth: width
        contentHeight: root.gridMode || root.vertical ? taskGrid.height : height
        interactive: root.gridMode && contentHeight > height
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: ScrollBar { policy: root.gridMode ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff }

        Grid {
            id: taskGrid
            x: root.vertical ? (viewport.width - width) / 2 : 0
            y: root.gridMode || root.vertical ? 0 : (viewport.height - height) / 2
            columns: root.gridMode ? root.gridColumns : root.vertical ? 1 : Math.max(1, root.lastIndex + 1)
            spacing: 0

            LaunchpadButton {
                id: launcher
                visible: root.gridMode && root.includeLaunchpad
                width: metrics.compactCellSize
                height: root.normalCellSize
                iconSize: Math.round(root.normalCellSize * 2 / 3)
                onClicked: root.launchpadRequested()
                Keys.onTabPressed: event => { root.moveFocus(1); event.accepted = true; }
                Keys.onBacktabPressed: event => { root.moveFocus(-1); event.accepted = true; }
            }

            Repeater {
                id: tasks
                model: root.taskModel
                delegate: AppButton {
                    required property int index
                    required property var model
                    visible: root.gridMode || index < metrics.visibleCount
                    cellSize: root.normalCellSize
                    slotWidth: root.gridMode || metrics.compact ? metrics.compactCellSize : metrics.normalCellSize
                    iconSize: index < 2 || root.gridMode || metrics.compact
                        ? Math.round(root.normalCellSize * 2 / 3) : Math.round(root.normalCellSize * 5 / 6)
                    label: String(model.AppName || model.display || qsTr("Приложение"))
                    iconSource: model.decoration
                    runningCount: model.IsLauncher ? 0 : model.IsGroupParent ? Math.max(2, Number(model.ChildCount)) : 1
                    active: Boolean(model.IsActive)
                    separatorBefore: !root.gridMode && index === root.launcherCount && index > 0
                    Keys.onTabPressed: event => { if (root.gridMode) root.moveFocus(1); event.accepted = root.gridMode; }
                    Keys.onBacktabPressed: event => { if (root.gridMode) root.moveFocus(-1); event.accepted = root.gridMode; }
                    onActivated: root.activated(index, active)
                    onNewInstanceRequested: root.newInstanceRequested(index)
                    onContextRequested: root.contextRequested(index, model)
                    onPreviewHoverEntered: root.previewEntered(index, model, label)
                    onPreviewHoverExited: root.previewExited()
                }
            }

            Button {
                id: overflowButton
                visible: !root.gridMode && metrics.hiddenCount > 0
                opacity: root.overflowExpanded ? 0 : 1
                enabled: !root.overflowExpanded
                width: metrics.cellSize
                height: root.normalCellSize
                padding: 0
                text: qsTr("+%1").arg(metrics.hiddenCount)
                Accessible.name: qsTr("Показать ещё %1 приложений").arg(metrics.hiddenCount)
                onClicked: root.overflowRequested()
                Keys.onReturnPressed: root.overflowRequested()
                Keys.onEnterPressed: root.overflowRequested()
                background: Rectangle {
                    radius: 10
                    color: overflowButton.down ? root.smartTheme.pressed
                        : overflowButton.hovered || overflowButton.visualFocus ? root.smartTheme.hover : "transparent"
                    border.width: overflowButton.visualFocus ? 2 : 0
                    border.color: root.smartTheme.focus
                }
                contentItem: Text {
                    text: overflowButton.text
                    color: root.smartTheme.foreground
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
