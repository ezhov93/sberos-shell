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
    readonly property int iconSize: Math.max(1, Math.round(cellSize * 2 / 3))
    readonly property int preferredCellCount: tasksModel.count
    readonly property int contentWidth: Math.max(cellSize + 16, preferredCellCount * cellSize + 8
                                                + (tasksModel.count > tasksModel.launcherCount ? 8 : 0))
    readonly property int contextMenuHeight: 56 + contextActions.reduce((height, item) => height + (item.separator ? 9 : 40), 0)
    property int selectedTaskIndex: -1
    property string selectedAppName: ""
    property string selectedLauncherUrl: ""
    property bool selectedIsActive: false
    property int selectedWindowCount: 0

    Plasmoid.title: qsTr("Приложения")
    Plasmoid.icon: "view-app-grid-symbolic"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: compactRepresentation

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
        selectedTaskIndex = index
        selectedAppName = String(task.AppName || task.display || qsTr("Приложение"))
        selectedLauncherUrl = task.LauncherUrlWithoutIcon ? String(task.LauncherUrlWithoutIcon) : ""
        selectedIsActive = Boolean(task.IsActive)
        selectedWindowCount = task.IsGroupParent ? Math.max(2, Number(task.ChildCount)) : (task.IsLauncher ? 0 : 1)
        root.expanded = true
    }

    function activateTask(index, active) {
        const taskIndex = tasksModel.makeModelIndex(index);
        if (active) tasksModel.requestToggleMinimized(taskIndex);
        else tasksModel.requestActivate(taskIndex);
    }

    function runContextAction(action) {
        const index = tasksModel.makeModelIndex(selectedTaskIndex)
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
        root.expanded = false
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

    compactRepresentation: Flickable {
        id: taskViewport
        implicitWidth: root.vertical ? 72 : root.contentWidth
        implicitHeight: root.vertical ? root.contentWidth : 72
        contentWidth: root.vertical ? width : taskRow.implicitWidth + 8
        contentHeight: root.vertical ? taskRow.implicitHeight + 16 : height
        flickableDirection: root.vertical ? Flickable.VerticalFlick : Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Grid {
            id: taskRow
            x: root.vertical ? (taskViewport.width - width) / 2 : 0
            y: root.vertical ? 8 : (taskViewport.height - height) / 2
            rows: root.vertical ? -1 : 1
            columns: root.vertical ? 1 : -1
            spacing: 0

            Repeater {
                model: tasksModel

                delegate: AppButton {
                    required property int index
                    required property var model

                    cellSize: root.cellSize
                    iconSize: root.iconSize
                    label: String(model.AppName || model.display || qsTr("Приложение"))
                    iconSource: model.decoration
                    runningCount: model.IsLauncher
                                  ? 0
                                  : model.IsGroupParent ? Math.max(2, Number(model.ChildCount)) : 1
                    active: Boolean(model.IsActive)
                    separatorBefore: index === tasksModel.launcherCount && index > 0
                    onActivated: root.activateTask(index, active)
                    onNewInstanceRequested: tasksModel.requestNewInstance(tasksModel.makeModelIndex(index))
                    onContextRequested: root.openTaskMenu(index, model)
                }
            }
        }
    }

    fullRepresentation: Item {
        id: fullView
        readonly property int popupWidth: 248
        readonly property int popupHeight: root.contextMenuHeight
        implicitWidth: popupWidth
        implicitHeight: popupHeight
        width: implicitWidth
        height: implicitHeight

        Loader {
            anchors.fill: parent
            sourceComponent: taskContextMenu
        }
    }

    Component {
        id: taskContextMenu
        TaskContextMenu {
            appName: root.selectedAppName
            taskIndex: root.selectedTaskIndex
            actions: root.contextActions
            onTriggered: action => root.runContextAction(action)
            onDismissed: root.expanded = false
        }
    }
}
