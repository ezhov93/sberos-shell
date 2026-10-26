import QtQuick
import QtQuick.Layouts

import Sber.Controls
import Sber.Core
import Sber.Theme

RowLayout {
    id: control
    property int lineHeight: Core.Settings.LineHeight
    property int currentIndex: 0
    property bool bullet: false
    property bool clickable: true
    property bool linesVisible: true

    spacing: lineHeight

    onChildrenChanged: updateItems()
    onLineHeightChanged: updateItems()
    function updateItems() {
        for (var i = 0; i < control.data.length; i++) {
            var step = control.data[i];
            step.lineHeight = control.lineHeight;
            step.index = i;
            step.rightStep = i + 1 < control.data.length ? control.data[i + 1] : undefined;
        }
    }

    function next() {
        currentIndex = Math.min(currentIndex + 1, control.data.length - 1);
    }
    function prev() {
        currentIndex = Math.max(currentIndex - 1, 0);
    }
}
