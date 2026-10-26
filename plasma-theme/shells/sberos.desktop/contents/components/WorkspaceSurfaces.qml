/* SPDX-License-Identifier: GPL-2.0-or-later */
pragma Singleton
import QtQuick
QtObject {
    id: registry
    property var desktops: ({})
    function registerDesktop(owner, screen, wallpaper) {
        if (screen < 0) return;
        const next = Object.assign({}, desktops);
        next[String(screen)] = {owner: owner, wallpaper: wallpaper};
        desktops = next;
    }
    function unregisterDesktop(owner) {
        const next = Object.assign({}, desktops);
        for (const key in next) if (next[key].owner === owner) delete next[key];
        desktops = next;
    }
}
