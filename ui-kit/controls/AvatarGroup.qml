import QtQuick
import QtQuick.Layouts

import Sber.Controls
import Sber.Core
import Sber.Theme


RowLayout {
    id: control
    property int lineHeight: Core.Settings.LineHeight
    spacing: -lineHeight / 4

    onChildrenChanged: updateItems();
    onLineHeightChanged: updateItems();
    function updateItems() {
        for (var i = 0; i < control.data.length; i++) {
            var avatar = control.data[i];
            if (avatar) {
                avatar.inGroup = true;
                avatar.lineHeight = control.lineHeight;
                avatar.hoveredChanged.connect(updateCurrent);
            }
        }
        updateCurrent();
    }

    function updateCurrent() {
        for (var i = 0; i < control.data.length; i++) {
            var avatar = control.data[i];
            if (avatar) {
                avatar.z = avatar.hovered ? 999 : i;
            }
        }
    }
}
