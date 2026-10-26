import QtQuick
import QtQuick.Layouts

import Sber.Controls
import Sber.Core
import Sber.Theme

RowLayout {
    id: control

    property int lineHeight: Core.Settings.LineHeight

    spacing: -lineHeight / 4

    QtObject {
        id: internal

        property var connectedAvatars: []
    }

    onChildrenChanged: updateItems()
    onLineHeightChanged: updateItems()

    function updateItems() {
        const avatars = control.data.filter(item => item && item.inGroup !== undefined && item.hoveredChanged !== undefined);

        for (const avatar of internal.connectedAvatars) {
            if (avatars.indexOf(avatar) === -1)
                avatar.hoveredChanged.disconnect(control.updateCurrent);
        }

        for (const avatar of avatars) {
            avatar.inGroup = true;
            avatar.lineHeight = control.lineHeight;

            if (internal.connectedAvatars.indexOf(avatar) === -1)
                avatar.hoveredChanged.connect(control.updateCurrent);
        }

        internal.connectedAvatars = avatars;
        updateCurrent();
    }

    function updateCurrent() {
        for (let i = 0; i < internal.connectedAvatars.length; i++) {
            const avatar = internal.connectedAvatars[i];
            if (avatar) {
                avatar.z = avatar.hovered ? 999 : i;
            }
        }
    }
}
