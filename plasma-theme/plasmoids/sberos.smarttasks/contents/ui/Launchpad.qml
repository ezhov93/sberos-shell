/***************************************************************************
 *   Copyright (C) 2014-2015 by Eike Hein <hein@kde.org>                   *
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
import org.kde.ksvg as KSvg
import org.kde.plasma.private.kicker as Kicker

Item {
    id: kicker
    required property var appletInterface
    required property Item visualParent
    property Item workspaceWallpaper: null
    property bool applicationMenuOpen: false
    readonly property alias window: dashWindow
    readonly property var plasmoid: appletInterface.plasmoid
    property Item dragSource: null
    property alias systemFavoritesModel: systemModel.favoritesModel
    readonly property DrawerTheme drawerTheme: DrawerTheme {}
    signal reset()

    function toggleLauncher() { dashWindow.toggleLauncher(); }
    function resetDragSource() { dragSource = null; }
    onApplicationMenuOpenChanged: {
        if (!applicationMenuOpen && dashWindow.visible) dashWindow.visible = false;
    }

    MenuRepresentation {
        id: dashWindow
        visualParent: kicker.visualParent
    }
    Connections {
        target: dashWindow
        function onVisibleChanged() { kicker.applicationMenuOpen = dashWindow.visible; }
    }
    readonly property Kicker.AppsModel appsModel: Kicker.AppsModel {
        autoPopulate: true
        flat: true
        showTopLevelItems: true
        sorted: false
        showSeparators: false
        paginate: false
        appletInterface: kicker.appletInterface
        appNameFormat: kicker.plasmoid.configuration.appNameFormat
        Component.onCompleted: refresh()
    }
    Kicker.SystemModel {
        id: systemModel
        Component.onCompleted: {
            kicker.systemFavoritesModel.enabled = true;
            kicker.systemFavoritesModel.maxFavorites = 8;
        }
    }
    KSvg.FrameSvgItem {
        id: highlightItemSvg
        visible: false
        imagePath: "widgets/viewitem"
        prefix: "hover"
    }
    Kicker.DragHelper { id: dragHelper }
    Kicker.ProcessRunner { id: processRunner }
}
