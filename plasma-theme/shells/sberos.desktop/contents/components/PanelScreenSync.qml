/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import org.kde.plasma.workspace.dbus as DBus

Timer {
    id: sync

    required property int screen

    // Let Plasma restore saved panel views before checking for missing panels.
    interval: 500
    running: screen >= 0
    onScreenChanged: {
        if (screen >= 0) restart();
    }
    onTriggered: {
        DBus.SessionBus.asyncCall({
            service: "org.kde.plasmashell",
            path: "/PlasmaShell",
            iface: "org.kde.PlasmaShell",
            member: "evaluateScript",
            arguments: ["loadTemplate('io.gitgud.wackyideas.taskbar');"]
        }, () => {}, error => console.warn("Cannot create Smart Panels:", error.message));
    }

    property Connections screenChanges: Connections {
        target: Qt.application
        function onScreensChanged() {
            if (sync.screen >= 0) sync.restart();
        }
    }
}
