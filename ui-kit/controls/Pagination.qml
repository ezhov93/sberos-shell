import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme


T.Control {
    id: control

    property int lineHeight: Core.Settings.LineHeight
    property int count: 0
    property int visibleCount: 0
    property int currentIndex: 0
    property int type: Widget.Default
    property bool goToVisible: false
    spacing: 12

    implicitWidth: buttonsRow.implicitWidth
    implicitHeight: buttonsRow.implicitHeight

    contentItem: RowLayout {
        id: buttonsRow
        anchors.fill: parent
        spacing: 0

        IconButton {
            type: control.type
            backgroundType: Widget.Outline
            lineHeight: control.lineHeight
            icon.name: "DoubleDisclosureLeft"
            visible: control.currentIndex > 0
            background.visible: hovered || pressed
            onReleased: {
                control.currentIndex = 0;
            }
        }
        IconButton {
            type: control.type
            backgroundType: Widget.Outline
            Layout.leftMargin: control.spacing
            Layout.rightMargin: control.spacing
            lineHeight: control.lineHeight
            icon.name: "DisclosureLeftOutline"
            visible: control.currentIndex > 0
            background.visible: hovered || pressed
            onReleased: {
                control.currentIndex -= 1;
            }
        }

        Repeater {
            id: repeater
            model: Math.min(control.visibleCount, control.count)
            Button {
                id: button
                lineHeight: control.lineHeight
                background: Rectangle {
                    id: bg
                    anchors.fill: parent
                    radius: button.backgroundConfig.radius
                    color: text - 1 == control.currentIndex ? button.colorizer.currentColor : "transparent"
                    border.width: button.enabled && button.hovered ? 1.5 : 0
                    border.color: button.colorizer.currentColor
                    opacity: control.enabled ? 1 : 0.4
                }
                textItem.color: text - 1 == control.currentIndex ? Theme.Palette.Text.Inverse.Primary :
                                                                   Theme.Palette.Text.Default.Primary
                onReleased: {
                    control.currentIndex = text - 1;
                }
            }
        }

        IconButton {
            type: control.type
            backgroundType: Widget.Outline
            Layout.leftMargin: control.spacing
            Layout.rightMargin: control.spacing
            lineHeight: control.lineHeight
            icon.name: "DisclosureRightOutline"
            visible: control.currentIndex < control.count - 1
            background.visible: hovered || pressed
            onReleased: {
                control.currentIndex += 1;
            }
        }
        IconButton {
            type: control.type
            backgroundType: Widget.Outline
            lineHeight: control.lineHeight
            icon.name: "DoubleDisclosureRight"
            visible: control.currentIndex < control.count - 1
            background.visible: hovered || pressed
            onReleased: {
                control.currentIndex = control.count - 1;
            }
        }

        Label {
            Layout.leftMargin: control.spacing
            lineHeight: control.lineHeight
            text: qsTr("Go to")
            visible: control.goToVisible
        }
        NumberInput {
            id: goToField
            Layout.leftMargin: control.spacing
            lineHeight: control.lineHeight
            implicitWidth: 50
            placeholderText: "#"
            from: 1
            to: control.count
            visible: control.goToVisible
            onAccepted: {
                control.currentIndex = Math.max(Math.min(goToField.text - 1, control.count), 0)
            }
        }
    }
    Component.onCompleted: updatePagination();
    onCurrentIndexChanged: updatePagination();
    onVisibleCountChanged: updatePagination();
    onCountChanged: updatePagination();

    function updatePagination() {
        if (control.count == 0 || control.visibleCount == 0 || repeater.count < control.visibleCount)
            return;

        var leftCount = 0;
        var centralCount = 0;
        var rightCount = 0;

        var middle = Math.floor(control.visibleCount / 2)
        if (control.currentIndex < middle) {
            leftCount = Math.max(middle, control.currentIndex + 2);
            centralCount = 0;
            rightCount = control.visibleCount - 1 - leftCount;
        } else if (control.currentIndex > control.count - middle) {
            rightCount = Math.max(middle, control.count - control.currentIndex + 2);
            centralCount = 0;
            leftCount = control.visibleCount - 1 - rightCount;
        } else {
            leftCount = Math.floor((control.visibleCount - 2) / 3);
            rightCount = leftCount;
            centralCount = control.visibleCount - 2 - leftCount - rightCount;
        }

        var pos = 0;
        for (var i = 0; i < leftCount && pos + i < control.count; i++) {
            repeater.itemAt(pos + i).text = i + 1;
            repeater.itemAt(pos + i).enabled = true;
        }
        pos += leftCount;
        if (pos >= control.count)
            return;

        repeater.itemAt(pos).text = '...';
        repeater.itemAt(pos).enabled = false;
        pos += 1;
        if (pos >= control.count)
            return;

        for (var i = 0; i < centralCount && pos + i < control.count; i++) {
            repeater.itemAt(pos + i).text = control.currentIndex - Math.floor(centralCount / 2) + i + 1;
            repeater.itemAt(pos + i).enabled = true;
        }
        pos += centralCount;
        if (pos >= control.count)
            return;

        if (centralCount > 0) {
            repeater.itemAt(leftCount + centralCount + 1).text = '...';
            repeater.itemAt(leftCount + centralCount + 1).enabled = false;
            pos += 1;
            if (pos >= control.count)
                return;
        }

        for (var i = 0; i < rightCount && pos + i < control.count; i++) {
            repeater.itemAt(pos + i).text = control.count - rightCount + i + 1;
            repeater.itemAt(pos + i).enabled = true;
        }
    }
}
