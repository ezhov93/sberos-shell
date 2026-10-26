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

    readonly property int cellSize: 48
    readonly property int iconSize: 32
    readonly property int preferredCellCount: tasksModel.count
    readonly property int contentWidth: Math.max(168, preferredCellCount * cellSize + 16
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

    Layout.minimumWidth: root.contentWidth
    Layout.preferredWidth: root.contentWidth
    Layout.maximumWidth: root.contentWidth
    Layout.minimumHeight: 48
    Layout.preferredHeight: 48
    Layout.maximumHeight: 48

    function openTaskMenu(index, task) {
        selectedTaskIndex = index
        selectedAppName = String(task.AppName || task.display || qsTr("Приложение"))
        selectedLauncherUrl = task.LauncherUrlWithoutIcon ? String(task.LauncherUrlWithoutIcon) : ""
        selectedIsActive = Boolean(task.IsActive)
        selectedWindowCount = task.IsGroupParent ? Math.max(2, Number(task.ChildCount)) : (task.IsLauncher ? 0 : 1)
        root.expanded = true
    }

    function activateTask(index) {
        tasksModel.requestActivate(tasksModel.makeModelIndex(index))
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
            tasksModel.requestToggleMinimized(index)
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

        onLauncherListChanged: Plasmoid.configuration.launchers = launcherList
    }

    compactRepresentation: Item {
        implicitWidth: root.contentWidth
        implicitHeight: root.cellSize

        Row {
            anchors.centerIn: parent
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
                    onActivated: root.activateTask(index)
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
            actions: root.contextActions
            onTriggered: action => root.runContextAction(action)
            onDismissed: root.expanded = false
        }
    }
}
