import QtQuick

import Sber.Controls
import Sber.Core
import Sber.Theme


Item {
    id: chipGroup
    property list<Chip> chips: []

    property int lineHeight: Core.Settings.LineHeight
    property bool closable: true
    property bool circle: false
    property int type: Widget.Default
    property int spacing: 2
    property bool oneLine: false

    signal closed(string idx)

    function add(text: string, idx = "", icon = "") {
        var chip = chipComponent.createObject(chipGroup);
        chip.parent = chipGroup;
        chip.lineHeight = lineHeight;
        chip.type = type;
        chip.circle = circle;
        chip.closable = closable;
        chip.text = text;
        chip.idx = idx;
        chip.icon.source = icon;
        chip.closed.connect(remove);
        chips.push(chip);
        internal.updateChipsPosition();
    }

    function remove(idx: string) {
        var removed = false;
        for (var i = 0; i < chips.length;) {
            if (chips[i].idx == idx) {
                chips[i].destroy();
                internal.removeItem(i);
                removed = true;
            } else
                ++i;
        }
        internal.updateChipsPosition();
        if (removed)
            closed(idx);
    }
    function removeByText(text: string) {
        var arr = [];
        for (var i = 0; i < chips.length;) {
            if (chips[i].text == text) {
                arr.push(chips[i].idx);
                chips[i].destroy();
                internal.removeItem(i);
            } else
                ++i;
        }
        internal.updateChipsPosition();
        for (var i = 0; i < arr.length; i++)
            closed(arr[i]);
    }

    function getCurrentChipsText() {
        var arr = [];
        for (var i = 0; i < chips.length; ++i)
            arr.push(chips[i].text);
        return arr;
    }
    function getCurrentChipsIds() {
        var arr = [];
        for (var i = 0; i < chips.length; ++i)
            arr.push(chips[i].idx);
        return arr;
    }

    Component {
        id: chipComponent
        Chip {}
    }

    QtObject {
        id: internal

        function updateChipsPosition() {
            if (chips.length) {
                var maxX = 0;
                var curX = 0;
                var curY = 0;
                for (var i = 0; i < chips.length; i++) {
                    if (!chipGroup.oneLine && curX + chips[i].implicitWidth > chipGroup.width) {
                        maxX = Math.max(maxX, curX + chips[i].implicitWidth);
                        curX = 0;
                        curY += chips[i].implicitHeight + spacing;
                    }
                    chips[i].x = curX;
                    chips[i].y = curY;
                    curX += chips[i].implicitWidth + chipGroup.spacing;
                }
                chipGroup.implicitWidth = Math.max(maxX, curX);
                chipGroup.implicitHeight = curY + chips[0].implicitHeight;
            } else {
                chipGroup.implicitWidth = 0;
                chipGroup.implicitHeight = 0;
            }
        }

        function removeItem(index: int) {
            for (var i = index; i < chips.length - 1; i++)
                chips[i] = chips[i + 1];
            chips.length--;
        }

        function updateProperties() {
            for (var i = 0; i < chips.length; i++) {
                chips[i].parent = chipGroup;
                chips[i].lineHeight = lineHeight;
                chips[i].type = type;
                chips[i].circle = circle;
                chips[i].closable = closable;
            }
        }
        function updateBindings() {
            for (var i = 0; i < chips.length; i++)
                chips[i].closed.connect(remove);
        }
    }

    Component.onCompleted: {
        internal.updateProperties();
        internal.updateBindings();
        internal.updateChipsPosition();
    }

    onWidthChanged: {
        internal.updateChipsPosition();
    }

    onLineHeightChanged: {
        internal.updateProperties();
        internal.updateChipsPosition();
    }
    onClosableChanged: {
        internal.updateProperties();
        internal.updateChipsPosition();
    }
    onTypeChanged: internal.updateProperties();
    onCircleChanged: internal.updateProperties();
}
