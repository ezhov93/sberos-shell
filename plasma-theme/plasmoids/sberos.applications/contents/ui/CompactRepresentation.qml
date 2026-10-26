/***************************************************************************
 *   Copyright (C) 2013-2014 by Eike Hein <hein@kde.org>                   *
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
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import org.kde.plasma.private.kicker as Kicker

Item {
    id: root

    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    readonly property var screenGeometry: plasmoid.screenGeometry
    readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
        || plasmoid.location == PlasmaCore.Types.RightEdge
        || plasmoid.location == PlasmaCore.Types.BottomEdge
        || plasmoid.location == PlasmaCore.Types.LeftEdge)
    readonly property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (plasmoid.configuration.useCustomButtonImage
        && plasmoid.configuration.customButtonImage.length != 0)

    readonly property Component dashWindowComponent: Qt.createComponent(Qt.resolvedUrl("./MenuRepresentation.qml"), root)
    readonly property Kicker.DashboardWindow dashWindow: dashWindowComponent && dashWindowComponent.status === Component.Ready
        ? dashWindowComponent.createObject(root, { visualParent: root }) : null

    Connections {
        target: root.dashWindow
        function onVisibleChanged() { kicker.applicationMenuOpen = root.dashWindow.visible; }
    }
    Connections {
        target: kicker
        function onApplicationMenuOpenChanged() {
            if (!kicker.applicationMenuOpen && root.dashWindow?.visible) root.dashWindow.visible = false;
        }
    }

    Plasmoid.status: dashWindow && dashWindow.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(root.width, root.height * 2 / 3)
        height: width
        radius: 10
        color: mouseArea.pressed ? smartTheme.pressed : mouseArea.containsMouse || mouseArea.activeFocus || root.dashWindow?.visible ? smartTheme.hover : "transparent"
        border.width: mouseArea.activeFocus ? 2 : 0
        border.color: smartTheme.focus
    }

    Kirigami.Icon {
        id: buttonIcon

        anchors.centerIn: parent
        width: Math.min(root.width, root.height) * 2 / 3
        height: width

        readonly property double aspectRatio: (vertical ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight)

        source: useCustomButtonImage ? plasmoid.configuration.customButtonImage : Qt.resolvedUrl("../assets/launchpad.svg")

        active: mouseArea.containsMouse

        smooth: true

        // A custom icon could also be rectangular. However, if a square, custom, icon is given, assume it
        // to be an icon and round it to the nearest icon size again to avoid scaling artefacts.
        roundToIconSize: !useCustomButtonImage || aspectRatio === 1

    }

    MouseArea
    {
        id: mouseArea

        anchors.fill: parent

        activeFocusOnTab: true
        hoverEnabled: !root.dashWindow || !root.dashWindow.visible

        Keys.onPressed: function (event) {
            switch (event.key) {
                case Qt.Key_Space:
                case Qt.Key_Enter:
                case Qt.Key_Return:
                case Qt.Key_Select:
                    Plasmoid.activated();
                    break;
            }
        }
        Accessible.name: Plasmoid.title
        Accessible.description: toolTipSubText
        Accessible.role: Accessible.Button

        onClicked: {
            dashWindow.toggleLauncher()
        }
    }

    Component.onCompleted: {
        // dashWindow = Qt.createQmlObject("MenuRepresentation {}", root);
        plasmoid.activated.connect(function() {
            //<>dashWindow.visible = !dashWindow.visible;
            dashWindow.toggleLauncher()
        });
    }
}
