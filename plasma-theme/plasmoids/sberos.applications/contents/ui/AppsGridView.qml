/***************************************************************************
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 ***************************************************************************/

import QtQuick
import org.kde.kirigami as Kirigami

import "../code/tools.js" as Tools

FocusScope {
    id: appsGrid

    signal keyNavLeft
    signal keyNavRight
    signal keyNavUp
    signal keyNavDown

    required property var model

    property string query: ""
    property var allApps: []
    readonly property var apps: allApps.filter(entry => entry.display.toLocaleLowerCase().includes(query.trim().toLocaleLowerCase()))
    readonly property var appSources: apps.map(entry => ({model: entry.sourceModel, row: entry.sourceRow}))
    onQueryChanged: {
        appsView.currentIndex = -1;
        appsView.contentY = 0;
    }
    readonly property int columns: Math.max(1, Math.min(8, Math.floor((width + 16) / 184)))
    readonly property int pageCapacity: columns * 4
    readonly property int pageCount: Math.max(1, Math.ceil(apps.length / pageCapacity))
    readonly property int currentPage: Math.min(pageCount - 1, Math.floor(appsView.contentY / (appsView.cellHeight * 4)))
    readonly property var currentMatch: appsView.currentItem

    function rebuild() {
        const entries = [];
        const sources = [];
        const seen = Object.create(null);
        collectApps(model, entries, sources, seen);

        const sorted = entries.map((entry, index) => ({entry: entry, source: sources[index]}));
        sorted.sort((a, b) => a.entry.display.localeCompare(b.entry.display));
        allApps = sorted.map(item => item.entry);
        appsView.contentY = 0;
        appsView.currentIndex = -1;
    }

    function collectApps(sourceModel, entries, sources, seen) {
        if (!sourceModel) {
            return;
        }

        for (let row = 0; row < sourceModel.count; ++row) {
            const sourceIndex = sourceModel.index(row, 0);
            if (sourceModel.data(sourceIndex, 0x0107)) {
                collectApps(sourceModel.modelForRow(row), entries, sources, seen);
                continue;
            }

            const display = sourceModel.data(sourceIndex, Qt.DisplayRole);
            if (!display) {
                continue;
            }

            const favoriteId = sourceModel.data(sourceIndex, 0x0104);
            const url = sourceModel.data(sourceIndex, 0x0105);
            const identity = favoriteId ? String(favoriteId) : (url ? url.toString() : display);
            if (seen[identity]) {
                continue;
            }
            seen[identity] = true;

            entries.push({
                display: display,
                decoration: sourceModel.data(sourceIndex, Qt.DecorationRole),
                url: url,
                sourceModel: sourceModel,
                sourceRow: row
            });
            sources.push({model: sourceModel, row: row});
        }
    }

    function selectFirst() {
        if (apps.length > 0) {
            appsView.currentIndex = 0;
            appsView.forceActiveFocus();
        }
    }

    function selectLast() {
        if (apps.length > 0) {
            appsView.currentIndex = apps.length - 1;
            appsView.forceActiveFocus();
        }
    }

    function removeSelection() {
        appsView.currentIndex = -1;
    }

    function triggerSelected() {
        if (appsView.currentIndex < 0 || appsView.currentIndex >= appSources.length) {
            return;
        }

        const source = appSources[appsView.currentIndex];
        source.model.trigger(source.row, "", null);
        root.toggle();
    }

    function openActionMenu(x, y, actionList) {
        if (!actionList || !actionList.length) {
            return;
        }
        actionMenu.actionList = actionList;
        actionMenu.targetIndex = appsView.currentIndex;
        actionMenu.open(x, y);
    }

    ActionMenu {
        id: actionMenu
        property int targetIndex: -1
        visualParent: appsView

        onActionClicked: function(actionId, actionArgument) {
            const source = appsGrid.appSources[targetIndex];
            const closeRequested = Tools.triggerAction(plasmoid, source.model, source.row, actionId, actionArgument);
            if (closeRequested) {
                root.toggle();
            }
        }
    }

    GridView {
        id: appsView
        anchors.top: parent.top
        anchors.bottom: pageDots.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: appsGrid.columns * cellWidth
        cellWidth: 184
        cellHeight: 208
        model: appsGrid.apps
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        snapMode: GridView.SnapToRow
        keyNavigationEnabled: false
        currentIndex: -1
        focus: true

        delegate: Item {
            id: appCell
            required property int index
            required property string display
            required property var decoration
            readonly property var source: appsGrid.appSources[index]
            readonly property bool hasActionList: source
                ? source.model.data(source.model.index(source.row, 0), 0x0108)
                : false

            function getActionList() {
                return source ? source.model.data(source.model.index(source.row, 0), 0x0109) : [];
            }

            width: appsView.cellWidth
            height: appsView.cellHeight

            Item {
                id: tile
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 168
                height: 176

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: cellMouse.containsMouse || appsView.currentIndex === appCell.index ? "#18ffffff" : "transparent"
                    border.width: appsView.currentIndex === appCell.index ? 1 : 0
                    border.color: "#35ffffff"
                }

                Kirigami.Icon {
                    id: appIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: 120
                    height: width
                    source: appCell.decoration
                    roundToIconSize: false
                }

                Text {
                    anchors.top: appIcon.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 168
                    text: appCell.display
                    color: drawerTheme.textColor
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
            }

            Accessible.role: Accessible.Button
            Accessible.name: appCell.display
            MouseArea {
                id: cellMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: appsView.currentIndex = appCell.index
                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton) {
                        appsGrid.openActionMenu(appCell.x, appCell.y, appCell.getActionList());
                    } else {
                        appsGrid.triggerSelected();
                    }
                }
            }
        }

        Keys.onLeftPressed: function(event) {
            if (currentIndex < 0) {
                currentIndex = 0;
            } else if (currentIndex % appsGrid.columns === 0) {
                event.accepted = true;
                appsGrid.keyNavLeft();
            } else {
                event.accepted = true;
                moveCurrentIndexLeft();
            }
        }

        Keys.onRightPressed: function(event) {
            if (currentIndex < 0) {
                currentIndex = 0;
            } else if (currentIndex % appsGrid.columns === appsGrid.columns - 1 || currentIndex === count - 1) {
                event.accepted = true;
                appsGrid.keyNavRight();
            } else {
                event.accepted = true;
                moveCurrentIndexRight();
            }
        }

        Keys.onUpPressed: function(event) {
            if (currentIndex < 0) {
                currentIndex = 0;
            } else if (currentIndex < appsGrid.columns) {
                event.accepted = true;
                appsGrid.keyNavUp();
            } else {
                event.accepted = true;
                moveCurrentIndexUp();
                positionViewAtIndex(currentIndex, GridView.Contain);
            }
        }

        Keys.onDownPressed: function(event) {
            if (currentIndex < 0) {
                currentIndex = 0;
            } else if (currentIndex + appsGrid.columns >= count) {
                event.accepted = true;
                appsGrid.keyNavDown();
            } else {
                event.accepted = true;
                currentIndex += appsGrid.columns;
                positionViewAtIndex(currentIndex, GridView.Contain);
            }
        }

        Keys.onReturnPressed: appsGrid.triggerSelected()
        Keys.onEnterPressed: appsGrid.triggerSelected()
        Keys.onMenuPressed: function(event) {
            if (currentItem && currentItem.hasActionList) {
                openActionMenu(currentItem.x, currentItem.y, currentItem.getActionList());
                event.accepted = true;
            }
        }
    }

    Row {
        id: pageDots
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12
        visible: appsGrid.pageCount > 1

        Repeater {
            model: appsGrid.pageCount
            delegate: Rectangle {
                required property int index
                width: 12
                height: 12
                radius: 6
                MouseArea {
                    anchors.fill: parent
                    onClicked: appsView.positionViewAtIndex(index * appsGrid.pageCapacity, GridView.Beginning)
                }
                color: index === appsGrid.currentPage ? drawerTheme.textColor : "#66ffffff"
            }
        }
    }

    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        visible: appsGrid.query.length > 0 && appsGrid.apps.length === 0
        text: i18n("Ничего не найдено")
        color: "white"
        font.pixelSize: 24
    }

    onModelChanged: rebuild()
    Connections {
        target: appsGrid.model
        enabled: target !== null
        function onCountChanged() { appsGrid.rebuild(); }
    }

    Component.onCompleted: rebuild()
}
