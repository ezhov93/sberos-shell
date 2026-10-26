pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kwindowsystem
import org.kde.pipewire as PipeWire
import org.kde.taskmanager as TaskManager

Item {
    id: root

    property string windowId: ""
    readonly property bool isWayland: KWindowSystem.isPlatformWayland
    readonly property bool isX11: KWindowSystem.isPlatformX11

    Loader {
        id: waylandLoader
        anchors.fill: parent
        active: root.isWayland && root.windowId.length > 0
        sourceComponent: PipeWire.PipeWireSourceItem {
            id: waylandThumbnail
            anchors.fill: parent
            nodeId: waylandThumbnail.supportsObjectSerial ? 0 : request.nodeId
            readonly property bool supportsObjectSerial: "objectSerial" in waylandThumbnail
                && "objectSerial" in request

            Binding {
                target: waylandThumbnail
                property: "objectSerial"
                value: waylandThumbnail.supportsObjectSerial ? request.objectSerial : 0
                when: waylandThumbnail.supportsObjectSerial
                restoreMode: Binding.RestoreBindingOrValue
            }

            TaskManager.ScreencastingRequest {
                id: request
                uuid: root.windowId
            }
        }
    }

    Loader {
        id: x11Loader
        anchors.fill: parent
        active: root.isX11 && Number(root.windowId) > 0
        source: root.isX11 ? "WindowPreviewX11Thumbnail.qml" : ""

        Binding {
            target: x11Loader.item
            property: "winId"
            value: Number(root.windowId)
            when: x11Loader.status === Loader.Ready
            restoreMode: Binding.RestoreBindingOrValue
        }
    }
}
