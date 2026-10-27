/***************************************************************************
 *   Copyright (C) 2014 by Weng Xuetian <wengxt@gmail.com>
 *   Copyright (C) 2013-2017 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick
import QtQuick.Controls

import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker as Kicker
import QtQuick.Window
import Qt5Compat.GraphicalEffects

import "../code/tools.js" as Tools

Kicker.DashboardWindow {

    id: root

    keyEventProxy: searchField
    backgroundColor: "transparent"

    readonly property bool searching: searchField.text != ""

    readonly property int contentMargin: Math.max(Kirigami.Units.iconSizes.huge, height * .12)

    // TODO: remove this and all focus debug rectangles
    property bool debugFocus: false

    function colorWithAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    onVisibleChanged: {
        if (visible) {
            searchField.text = "";
            // Set favorites here to ensure system actions are available
            systemFavoritesModel.favorites = plasmoid.configuration.favoriteSystemActions;
            Qt.callLater(() => searchField.forceActiveFocus());
        } else {
            reset();
        }
    }

    onSearchingChanged: {
        if (!searching) {
            reset();
        }
    }

    onKeyEscapePressed: {
        if (searching) {
            searchField.text = "";
        } else {
            root.leave();
        }
    }

    function toggleLauncher() {
        if (visible) root.toggle();
        else wallpaperBackdrop.prepare(() => root.toggle());
    }

    function leave() {
        root.toggle();
    }

    function reset() {
        searchField.text = "";
        content.focus = true;
    }

    function openActionMenu(x, y, actionList = undefined) {
        if (actionList) {
            actionMenu.actionList = actionList;
        } else {
            actionMenu.actionList = Tools.createMenuEditAction(i18n, processRunner);
        }
        actionMenu.open(x, y);
    }

    mainItem: MouseArea {
        id: rootMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
        LayoutMirroring.childrenInherit: true
        // hoverEnabled: true

        ActionMenu {
            id: actionMenu
            // visualParent: rootMouseArea
            onActionClicked: function (actionId, actionArgument) {
                var closeRequested = Tools.triggerAction(plasmoid, null, -1, actionId, actionArgument);
                if (closeRequested) {
                    root.toggle();
                }
            }
        }

        onReleased: function (mouse) {
            mouse.accepted = true;
            if (mouse.button == Qt.RightButton) {
                if (!searching) {
                    root.openActionMenu(mouse.x, mouse.y);
                }
            } else {
                root.leave();
            }
        }

        WallpaperBackdrop {
            id: wallpaperBackdrop
            anchors.fill: parent
            wallpaperItem: kicker.workspaceWallpaper
            active: root.visible
        }

        PlasmaExtras.Heading {
            id: dummyHeading
            visible: false
            width: 0
            level: 5
        }

        TextMetrics {
            id: headingMetrics
            font: dummyHeading.font
        }

        TextField {
            id: searchField
            objectName: "launchpadSearch"

            visible: plasmoid.configuration.showSearch
            enabled: visible

            height: 72
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(456, root.width - 32)
            leftPadding: searchField.text.length ? 24 : 68
            rightPadding: 16

            color: "white"
            font.pixelSize: 16
            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignVCenter

            placeholderText: i18n("Найду документ или приложение")
            placeholderTextColor: "#a5aebb"

            Accessible.name: i18n("Поиск приложений")

            background: Rectangle {
                id: searchFieldBackground
                anchors.fill: parent
                radius: 24
                color: "#14ffffff"
                border.width: 1
                border.color: searchField.activeFocus ? "#90ffffff" : "#60ffffff"
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 7
                    radius: 17
                    color: "#d92b323b"
                }
            }

            OskaAvatar {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 40
                height: 40
                visible: searchField.text.length === 0
            }

            Keys.onPressed: function (event) {
                if (searching && (event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
                    event.accepted = true;
                    if (content.status === Loader.Ready && !content.item.currentMatch) {
                        content.item.selectFirst();
                    }
                    //content.item.triggerSelected();
                    return;
                }

                if (event.key == Qt.Key_Tab || event.key == Qt.Key_Down || (event.key == Qt.Key_Backtab && !systemActionsGrid.visible)) {
                    event.accepted = true;
                    content.focus = true;
                    content.item.selectFirst();
                } else if (event.key == Qt.Key_Backtab) {
                    event.accepted = true;
                    systemActionsGrid.focus = true;
                    systemActionsGrid.trySelect(0, 0);
                }
            }

            Keys.onReleased: function (event) {
                if (searching && (event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
                    event.accepted = true;
                    if (content.status === Loader.Ready) content.item.triggerSelected();
                    return;
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "red"
                opacity: 0.05
                visible: root.debugFocus && searchField.activeFocus
                z: 100
            }
        }

        Component {
            id: appsGridViewComponent
            AppsGridView {
                id: appsGridView

                visible: true
                query: searchField.text
                enabled: visible
                focus: true

                model: appsModel
            }
        }

        // Switch between apps grid or runner results based on whether searching or not
        Loader {
            id: content
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: Math.min(124, root.height * .115)
                bottom: searchField.top
                bottomMargin: 80
            }
            width: root.width
            sourceComponent: appsGridViewComponent
            active: root.visible
            focus: true
            Keys.forwardTo: [searchField]

            function keyNavUp() {
                if (searchField.visible) {
                    item.removeSelection();
                    searchField.focus = true;
                } else if (systemActionsGrid.visible) {
                    keyNavDown();
                }
            }
            function keyNavDown() {
                if (systemActionsGrid.visible) {
                    item.removeSelection();
                    systemActionsGrid.focus = true;
                    systemActionsGrid.trySelect(0, 0);
                } else if (searchField.visible) {
                    keyNavUp();
                }
            }

            onLoaded: {
                item.keyNavUp.connect(keyNavUp);
                item.keyNavDown.connect(keyNavDown);
            }

            Keys.onPressed: function (event) {
                if (event.key == Qt.Key_Backtab) {
                    event.accepted = true;
                    keyNavUp();
                } else if (event.key == Qt.Key_Tab) {
                    event.accepted = true;
                    keyNavDown();
                }
            }
        }

        ItemGridView {
            id: systemActionsGrid

            model: systemFavoritesModel

            visible: count > 0 && plasmoid.configuration.showSystemActions
            enabled: visible

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: Kirigami.Units.largeSpacing
                bottomMargin: (contentMargin / 2) - (height / 2)
            }

            iconSize: plasmoid.configuration.systemActionIconSize
            cellWidth: iconSize + (Kirigami.Units.largeSpacing * (showLabels ? 6 : 2))
            cellHeight: cellWidth
            // height: cellHeight
            // width: cellWidth * count
            numberColumns: model.count
            // maxVisibleRows: 1

            opacity: 0.9

            dragEnabled: true
            showLabels: plasmoid.configuration.showSystemActionLabels
            setIconColorBasedOnTheme: true
            forceSymbolicIcons: plasmoid.configuration.useSymbolicSystemActionIcons

            onKeyNavUp: {
                currentIndex = -1;
                content.focus = true;
                content.item.selectLast();
            }

            Keys.onPressed: function (event) {
                if (event.key == Qt.Key_Backtab || (event.key == Qt.Key_Tab && !searchField.visible)) {
                    event.accepted = true;
                    currentIndex = -1;
                    content.focus = true;
                    content.item.selectFirst();
                } else if (event.key == Qt.Key_Tab) {
                    event.accepted = true;
                    currentIndex = -1;
                    searchField.focus = true;
                }
            }
        }

        Keys.onPressed: function (event) {
            if (searchField.focus || !searchField.visible) {
                return;
            }

            if (event.key == Qt.Key_Backspace) {
                event.accepted = true;
                searchField.focus = true;
                searchField.text = searchField.text.slice(0, -1);
            } else if (event.text != "") {
                event.accepted = true;
                searchField.focus = true;
                searchField.text = searchField.text + event.text;
            }
        }
    }

    Component.onCompleted: {
        kicker.reset.connect(reset);
    }
}
