/***************************************************************************
 *   Copyright (C) 2015 by Eike Hein <hein@kde.org>                        *
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

import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PC3
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrolsaddons
import Qt5Compat.GraphicalEffects

import "../code/tools.js" as Tools

Item {
    id: item

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    property bool showLabel: true
    property var iconColorOverride: undefined
    property bool forceSymbolicIcons: false

    // For this widget, the only favoritable actions should be system actions
    readonly property bool isSystemAction: (model.favoriteId
                                            && GridView.view.model.favoritesModel
                                            && GridView.view.model.favoritesModel.enabled) ?? false

    readonly property int itemIndex: model.index
    readonly property url url: model.url != undefined ? model.url : ""
    property bool pressed: false

    Accessible.role: Accessible.MenuItem
    Accessible.name: model.display

    readonly property bool hasActionList: ((model.sourceModel
                                            && model.sourceModel.data(model.sourceModel.index(model.sourceRow, 0), 0x0108))
                                           || (("hasActionList" in model) && (model.hasActionList == true))
                                           || isSystemAction)

    function getActionList() {
        if (isSystemAction) {
            return Tools.createSystemActionActions(i18n, GridView.view.model.favoritesModel, model.favoriteId);
        }
        if (model.sourceModel) {
            return model.sourceModel.data(model.sourceModel.index(model.sourceRow, 0), 0x0109);
        }
        return model.actionList;
    }

    // Rectangle{
    //     id: box
    //     height: parent.height // - 10
    //     width:  parent.width  // - 10
    //     anchors.verticalCenter: parent.verticalCenter
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     color: "transparent"
    // }

    Rectangle {
        id: displayBox
        width: iconSize
        height: width
        y: (item.height / 2) - (height / 2) - (showLabel ? label.height / 2 : 0)
        anchors.horizontalCenter: parent.horizontalCenter
        // anchors.verticalCenter: parent.verticalCenter - (showLabel ? label.height / 2 : 0)
        color:"transparent"

        Kirigami.Icon {
            anchors.fill: parent
            animated: false
            source: model.decoration + (forceSymbolicIcons ? "-symbolic" : "")
            roundToIconSize: width > Kirigami.Units.iconSizes.huge ? false : true
            isMask: iconColorOverride !== undefined
            color: iconColorOverride ?? "transparent"
        }
    }

    // Rectangle{
    //     id: box
    //     height: parent.height // - 10
    //     width:  parent.width  // - 10
    //     anchors.verticalCenter: box.verticalCenter
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     color:"red"
    //     opacity: 0.4
    //     // color: "transparent"
    // }

    PC3.Label {
        id: label

        visible: showLabel

        anchors {
            top: displayBox.bottom
            topMargin: Kirigami.Units.largeSpacing * 1.5
            left: parent.left
            leftMargin: highlightItemSvg.margins.left
            right: parent.right
            rightMargin: highlightItemSvg.margins.right
        }

        horizontalAlignment: Text.AlignHCenter

        elide: Text.ElideRight
        wrapMode: Text.NoWrap

        text: model.display
        color: drawerTheme.textColor
    }

}
