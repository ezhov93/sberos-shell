pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property int cellSize: Math.max(1, Math.round((vertical ? width : height) * 2 / 3))
    readonly property int contentWidth: stripMetrics.preferredLength
    property bool overflowOpen: false
    property bool contextMenuVisible: false
    property int overflowFocusIndex: 0
    readonly property bool childOpen: contextMenuVisible || previewVisible
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    readonly property int contextMenuHeight: 56 + contextActions.reduce((height, item) => height + (item.separator ? 9 : 40), 0)
    property int selectedTaskIndex: -1
    property string selectedAppName: ""
    property string selectedLauncherUrl: ""
    property bool selectedIsActive: false
    property int selectedWindowCount: 0
    property bool previewVisible: false
    property int previewTaskIndex: -1
    property string previewAppName: ""
    property var previewWindows: []

    Plasmoid.title: qsTr("Приложения")
    Plasmoid.icon: "view-app-grid-symbolic"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation
    hideOnWindowDeactivate: !(overflowOpen && childOpen)

    onExpandedChanged: expanded => {
        if (!expanded) {
            previewOpenTimer.stop()
            previewCloseTimer.stop()
            previewVisible = false
            contextMenuVisible = false
            overflowOpen = false
        }
    }

    TaskLayoutMetrics {
        id: stripMetrics
        count: tasksModel.count
        launcherCount: tasksModel.launcherCount
        availableLength: root.vertical ? root.height : root.width
        normalCellSize: root.cellSize
        onHiddenCountChanged: {
            if (hiddenCount === 0 && root.overflowOpen) root.expanded = false
        }
    }

    function openOverflow() {
        if (stripMetrics.hiddenCount === 0) return
        previewOpenTimer.stop()
        previewCloseTimer.stop()
        previewVisible = false
        contextMenuVisible = false
        overflowFocusIndex = stripMetrics.visibleCount
        overflowOpen = true
        expanded = true
        Qt.callLater(focusOverflow)
    }

    function focusOverflow() {
        root.fullRepresentationItem?.focusOverflow()
    }

    function dismissPopup(keyboard) {
        previewOpenTimer.stop()
        previewCloseTimer.stop()
        if (overflowOpen && childOpen) {
            contextMenuVisible = false
            previewVisible = false
            Qt.callLater(focusOverflow)
        } else {
            const wasOverflow = overflowOpen
            expanded = false
            if (keyboard) Qt.callLater(() => {
                const strip = root.compactRepresentationItem
                if (wasOverflow && stripMetrics.hiddenCount > 0)
                    strip?.overflowButton.forceActiveFocus(Qt.TabFocusReason)
                else strip?.focusTask(Math.max(0, root.selectedTaskIndex))
            })
        }
    }

    function schedulePreview(index, task, label) {
        previewCloseTimer.stop()
        if (contextMenuVisible) return
        if (task.IsLauncher) { previewOpenTimer.stop(); return; }
        previewTaskIndex = index
        previewAppName = label
        previewWindows = windowPreviewData(index, task)
        if (previewWindows.length) previewOpenTimer.restart()
    }

    Layout.minimumWidth: vertical ? 0 : cellSize + 16
    Layout.preferredWidth: vertical ? 72 : contentWidth
    Layout.maximumWidth: vertical ? Infinity : contentWidth
    Layout.minimumHeight: vertical ? cellSize + 16 : 0
    Layout.preferredHeight: vertical ? contentWidth : 72
    Layout.maximumHeight: vertical ? contentWidth : Infinity

    function saveLaunchers() {
        if (tasksModel.launcherList.join("\n") !== Plasmoid.configuration.launchers.join("\n")) {
            Plasmoid.configuration.launchers = tasksModel.launcherList;
        }
    }

    function openTaskMenu(index, task) {
        previewOpenTimer.stop()
        previewCloseTimer.stop()
        previewVisible = false
        contextMenuVisible = true
        overflowFocusIndex = index
        selectedTaskIndex = index
        selectedAppName = String(task.AppName || task.display || qsTr("Приложение"))
        selectedLauncherUrl = task.LauncherUrlWithoutIcon ? String(task.LauncherUrlWithoutIcon) : ""
        selectedIsActive = Boolean(task.IsActive)
        selectedWindowCount = task.IsGroupParent ? Math.max(2, Number(task.ChildCount)) : (task.IsLauncher ? 0 : 1)
        root.expanded = true
    }

    function windowPreviewData(index, task) {
        const parentIndex = tasksModel.makeModelIndex(index)
        const grouped = Boolean(task.IsGroupParent)
        const count = grouped ? tasksModel.rowCount(parentIndex) : 1
        const windows = []
        for (let child = 0; child < count; child++) {
            const childIndex = grouped ? tasksModel.index(child, 0, parentIndex) : parentIndex
            const ids = tasksModel.data(childIndex, TaskManager.AbstractTasksModel.WinIdList) || []
            const windowId = ids.length > 0 ? String(ids[0]) : ""
            if (!windowId.length) continue
            windows.push({
                title: String(tasksModel.data(childIndex, Qt.DisplayRole) || task.AppName || qsTr("Окно")),
                windowId: windowId,
                lastActivated: Number(tasksModel.data(childIndex, TaskManager.AbstractTasksModel.LastActivated) || 0),
                childIndex: grouped ? child : -1
            })
        }
        windows.sort((left, right) => right.lastActivated - left.lastActivated)
        return windows
    }

    function activatePreviewWindow(windowIndex) {
        const windowData = previewWindows[windowIndex]
        const parentIndex = tasksModel.makeModelIndex(previewTaskIndex)
        const taskIndex = windowData.childIndex >= 0
                         ? tasksModel.index(windowData.childIndex, 0, parentIndex) : parentIndex
        root.expanded = false
        tasksModel.requestActivate(taskIndex)
    }

    function closePreviewWindow(windowIndex) {
        const windowData = previewWindows[windowIndex]
        const parentIndex = tasksModel.makeModelIndex(previewTaskIndex)
        const taskIndex = windowData.childIndex >= 0
                         ? tasksModel.index(windowData.childIndex, 0, parentIndex) : parentIndex
        tasksModel.requestClose(taskIndex)
    }

    function closeWindowPreview() {
        previewOpenTimer.stop()
        previewCloseTimer.stop()
        previewVisible = false
        if (!overflowOpen) root.expanded = false
    }

    function activateTask(index, active) {
        const taskIndex = tasksModel.makeModelIndex(index);
        if (overflowOpen) root.expanded = false
        if (active) tasksModel.requestToggleMinimized(taskIndex);
        else tasksModel.requestActivate(taskIndex);
    }

    function newTaskInstance(index) {
        root.expanded = false
        tasksModel.requestNewInstance(tasksModel.makeModelIndex(index))
    }

    function runContextAction(action) {
        const index = tasksModel.makeModelIndex(selectedTaskIndex)
        const keepOverflow = overflowOpen && (action === "pin" || action === "unpin")
        if (!keepOverflow) root.expanded = false
        switch (action) {
        case "new":
            tasksModel.requestNewInstance(index)
            break
        case "pin":
            if (selectedLauncherUrl.length > 0)
                tasksModel.requestAddLauncher(selectedLauncherUrl)
            break
        case "unpin":
            if (selectedLauncherUrl.length > 0)
                tasksModel.requestRemoveLauncher(selectedLauncherUrl)
            break
        case "toggle":
            if (selectedIsActive) tasksModel.requestToggleMinimized(index);
            else tasksModel.requestActivate(index)
            break
        case "close":
            tasksModel.requestClose(index)
            break
        }
        if (keepOverflow && root.expanded) dismissPopup(true)
    }

    readonly property var contextActions: {
        const actions = [{label: qsTr("Открыть новое окно"), action: "new"}]
        if (selectedLauncherUrl.length > 0) {
            const launcherPosition = tasksModel.launcherPosition(selectedLauncherUrl)
            if (launcherPosition >= 2) {
                actions.push({label: qsTr("Открепить от панели"), action: "unpin"})
            } else if (launcherPosition < 0) {
                actions.push({label: qsTr("Закрепить на панели"), action: "pin"})
            }
        }
        if (selectedWindowCount > 0) {
            actions.push({separator: true})
            actions.push({label: selectedIsActive ? qsTr("Свернуть") : qsTr("Показать окно"), action: "toggle"})
            actions.push({label: selectedWindowCount > 1 ? qsTr("Закрыть все окна") : qsTr("Закрыть окно"), action: "close"})
        }
        return actions
    }

    TaskManager.TasksModel {
        id: tasksModel
        launcherList: Plasmoid.configuration.launchers
        groupMode: TaskManager.TasksModel.GroupApplications
        groupInline: true
        separateLaunchers: false
        hideActivatedLaunchers: false
        launchInPlace: true
        sortMode: TaskManager.TasksModel.SortManual
        filterByScreen: false
        filterByVirtualDesktop: false
        filterByActivity: false

        onLauncherListChanged: Qt.callLater(root.saveLaunchers)
    }

    compactRepresentation: TaskList {
        taskModel: tasksModel
        launcherCount: tasksModel.launcherCount
        normalCellSize: root.cellSize
        vertical: root.vertical
        overflowExpanded: root.overflowOpen
        onOverflowRequested: root.openOverflow()
        onDismissed: root.dismissPopup(true)
        onActivated: (index, active) => root.activateTask(index, active)
        onNewInstanceRequested: index => root.newTaskInstance(index)
        onContextRequested: (index, task) => root.openTaskMenu(index, task)
        onPreviewEntered: (index, task, label) => root.schedulePreview(index, task, label)
        onPreviewExited: {
            previewOpenTimer.stop()
            if (root.previewVisible) previewCloseTimer.restart()
        }
    }

    fullRepresentation: FocusScope {
        id: fullView
        readonly property int gridWidth: Math.min(12, Math.max(1, tasksModel.count)) * stripMetrics.compactCellSize + 24
        readonly property int availableHeight: Math.max(root.cellSize + 24,
            Plasmoid.containment.availableScreenRect.height - root.height - 16)
        readonly property int gridHeight: Math.min(availableHeight,
            Math.ceil(tasksModel.count / Math.max(1, Math.floor((gridWidth - 24) / stripMetrics.compactCellSize))) * root.cellSize + 24)
        readonly property int childWidth: root.previewVisible
            ? Math.min(520, Math.max(272, root.previewWindows.length * 256 + 24)) : 248
        readonly property int childHeight: root.previewVisible ? 230 : root.contextMenuHeight
        implicitWidth: root.overflowOpen ? Math.max(gridWidth, root.childOpen ? childWidth : 0) : childWidth
        implicitHeight: root.overflowOpen ? Math.max(gridHeight, root.childOpen ? childHeight : 0) : childHeight
        Layout.minimumWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        Layout.preferredWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.maximumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight
        focus: true

        function focusOverflow() { overflowLoader.item?.focusTask(root.overflowFocusIndex); }
        Keys.onEscapePressed: event => { root.dismissPopup(true); event.accepted = true; }

        SmartPopupPlacement {
            content: fullView
            anchorItem: root.compactRepresentationItem ?? root
            screenGeometry: Plasmoid.containment.screenGeometry
            alignment: "left"
        }

        Connections {
            target: fullView.Window.window
            function onActiveChanged() {
                const popupWindow = fullView.Window.window
                if (root.expanded && root.overflowOpen && root.childOpen && !popupWindow.active) {
                    root.dismissPopup(false)
                    Qt.callLater(() => { if (root.expanded) popupWindow.requestActivate(); })
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: root.smartTheme.radius
            color: root.smartTheme.shell
            border.width: 1
            border.color: root.smartTheme.edge
            Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: 16
                color: root.smartTheme.inner
            }
        }

        Loader {
            id: overflowLoader
            anchors.fill: parent
            active: root.overflowOpen
            sourceComponent: TaskList {
                taskModel: tasksModel
                launcherCount: tasksModel.launcherCount
                normalCellSize: root.cellSize
                gridMode: true
                maximumHeight: fullView.availableHeight
                enabled: !root.contextMenuVisible
                onActivated: (index, active) => root.activateTask(index, active)
                onNewInstanceRequested: index => root.newTaskInstance(index)
                onContextRequested: (index, task) => root.openTaskMenu(index, task)
                onPreviewEntered: (index, task, label) => {
                    root.overflowFocusIndex = index
                    root.schedulePreview(index, task, label)
                }
                onPreviewExited: {
                    previewOpenTimer.stop()
                    if (root.previewVisible) previewCloseTimer.restart()
                }
                onDismissed: root.dismissPopup(true)
            }
            onLoaded: Qt.callLater(fullView.focusOverflow)
        }

        MouseArea {
            anchors.fill: parent
            visible: root.overflowOpen && root.contextMenuVisible
            onClicked: root.dismissPopup(false)
        }

        Loader {
            anchors.right: parent.right
            anchors.top: parent.top
            width: fullView.childWidth
            height: fullView.childHeight
            active: root.childOpen
            sourceComponent: root.previewVisible ? windowPreview : taskContextMenu
            onLoaded: item.forceActiveFocus(Qt.PopupFocusReason)
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) previewCloseTimer.stop()
                    else if (root.previewVisible) previewCloseTimer.restart()
                }
            }
        }
    }

    Timer {
        id: previewOpenTimer
        interval: 300
        onTriggered: {
            if (root.previewWindows.length && !root.contextMenuVisible) {
                root.previewVisible = true
                root.expanded = true
            }
        }
    }

    Timer {
        id: previewCloseTimer
        interval: 350
        onTriggered: root.closeWindowPreview()
    }

    Component {
        id: taskContextMenu
        TaskContextMenu {
            appName: root.selectedAppName
            taskIndex: root.selectedTaskIndex
            actions: root.contextActions
            onTriggered: action => root.runContextAction(action)
            onDismissed: root.dismissPopup(true)
        }
    }

    Component {
        id: windowPreview
        WindowPreview {
            appName: root.previewAppName
            windows: root.previewWindows
            smartTheme: SmartPanelTheme {}
            onActivateRequested: index => root.activatePreviewWindow(index)
            onCloseRequested: index => root.closePreviewWindow(index)
        }
    }
}
