/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <eikehein@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 ***************************************************************************/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami

FocusScope {
    id: searchResults

    signal keyNavUp
    signal keyNavDown
    signal resultActivated

    property var model
    property color textColor: "white"
    property alias grid: resultsGrid
    readonly property int columns: Math.max(1, Math.min(8, Math.floor((width + 16) / 184)))
    readonly property int pageCapacity: columns * 4
    readonly property int pageCount: Math.max(1, Math.ceil(resultsGrid.count / pageCapacity))
    readonly property int currentPage: Math.min(pageCount - 1, Math.floor(resultsGrid.contentY / (resultsGrid.cellHeight * 4)))
    readonly property var matchesModel: model && model.count > 0 ? model.modelForRow(0) : null
    readonly property var currentMatch: resultsGrid.currentItem

    function selectFirst() {
        if (resultsGrid.count > 0) {
            resultsGrid.currentIndex = 0;
            resultsGrid.forceActiveFocus();
        }
    }

    function selectLast() {
        if (resultsGrid.count > 0) {
            resultsGrid.currentIndex = resultsGrid.count - 1;
            resultsGrid.forceActiveFocus();
        }
    }

    function removeSelection() {
        resultsGrid.currentIndex = -1;
    }

    function triggerSelected() {
        if (matchesModel && resultsGrid.currentIndex >= 0) {
            matchesModel.trigger(resultsGrid.currentIndex, "", null);
            resultActivated();
        }
    }

    GridView {
        id: resultsGrid
        anchors {
            top: parent.top
            bottom: pageDots.top
            bottomMargin: 48
            horizontalCenter: parent.horizontalCenter
        }
        width: searchResults.columns * cellWidth
        cellWidth: 184
        cellHeight: 196
        model: searchResults.matchesModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        keyNavigationWraps: false
        currentIndex: -1

        onCountChanged: {
            contentY = 0;
            currentIndex = -1;
        }

        delegate: Item {
            id: appCell
            required property int index
            required property string display
            required property string decoration
            width: searchResults.grid.cellWidth
            height: searchResults.grid.cellHeight

            Item {
                anchors.centerIn: parent
                width: 168
                height: 148

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: searchResults.grid.currentIndex === appCell.index ? "#18ffffff" : "transparent"
                    border.width: searchResults.grid.currentIndex === appCell.index ? 1 : 0
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
                    width: 144
                    text: appCell.display
                    color: searchResults.textColor
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    wrapMode: Text.NoWrap
                }
            }

            HoverHandler {
                onHoveredChanged: if (hovered)
                    searchResults.grid.currentIndex = appCell.index
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    searchResults.grid.currentIndex = appCell.index;
                    searchResults.triggerSelected();
                }
            }

            Accessible.role: Accessible.Button
            Accessible.name: appCell.display
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                searchResults.triggerSelected();
            } else if (event.key === Qt.Key_Up && (currentIndex < searchResults.columns || currentIndex < 0)) {
                event.accepted = true;
                searchResults.keyNavUp();
            } else if (event.key === Qt.Key_Down && (currentIndex < 0 || currentIndex + searchResults.columns >= count)) {
                event.accepted = true;
                searchResults.keyNavDown();
            } else if (event.key === Qt.Key_Left && currentIndex === 0) {
                event.accepted = true;
                searchResults.keyNavUp();
            } else if (event.key === Qt.Key_Right && currentIndex === count - 1) {
                event.accepted = true;
                searchResults.keyNavDown();
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                event.accepted = true;
                const delta = event.key === Qt.Key_Left ? -1 : event.key === Qt.Key_Right ? 1 : event.key === Qt.Key_Up ? -searchResults.columns : searchResults.columns;
                const nextIndex = currentIndex + delta;
                if (nextIndex >= 0 && nextIndex < count)
                    currentIndex = nextIndex;
            }
        }
    }

    Row {
        id: pageDots
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 88
        spacing: 12
        visible: searchResults.pageCount > 1

        Repeater {
            model: searchResults.pageCount
            delegate: Rectangle {
                id: pageDot
                required property int index
                width: 12
                height: 12
                radius: 6
                color: pageDot.index === searchResults.currentPage ? searchResults.textColor : "#939bab"

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        searchResults.grid.currentIndex = -1;
                        searchResults.grid.contentY = pageDot.index * searchResults.pageCapacity * searchResults.grid.cellHeight / searchResults.columns;
                    }
                }
            }
        }
    }
}
