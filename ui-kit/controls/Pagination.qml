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
                objectName: "paginationPage%1".arg(index)
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
                textItem.color: text - 1 == control.currentIndex ? Theme.Palette.Text.Inverse.Primary : Theme.Palette.Text.Default.Primary
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
                control.currentIndex = Math.max(Math.min(goToField.text - 1, control.count), 0);
            }
        }
    }
    Component.onCompleted: updatePagination()
    onCurrentIndexChanged: updatePagination()
    onVisibleCountChanged: updatePagination()
    onCountChanged: updatePagination()

    function updatePagination() {
        if (control.count == 0 || control.visibleCount == 0)
            return;

        var pages = [];
        var currentIndex = Math.max(0, Math.min(control.currentIndex, control.count - 1));
        var visibleCount = Math.min(control.visibleCount, control.count);

        if (control.count <= visibleCount) {
            for (var i = 0; i < control.count; i++)
                pages.push(i + 1);
        } else if (visibleCount < 5) {
            var start = Math.max(0, Math.min(currentIndex - Math.floor(visibleCount / 2), control.count - visibleCount));
            for (var i = 0; i < visibleCount; i++)
                pages.push(start + i + 1);
        } else {
            var edgePageCount = Math.floor((visibleCount - 1) / 2);
            var lastIndex = control.count - 1;
            if (currentIndex <= edgePageCount) {
                for (var i = 0; i < visibleCount - 2; i++)
                    pages.push(i + 1);
                pages.push("...");
                pages.push(control.count);
            } else if (currentIndex >= lastIndex - edgePageCount) {
                pages.push(1);
                pages.push("...");
                for (var i = control.count - visibleCount + 3; i <= control.count; i++)
                    pages.push(i);
            } else {
                var centerCount = visibleCount - 4;
                var firstCenter = currentIndex - Math.floor((centerCount - 1) / 2);
                firstCenter = Math.max(2, Math.min(firstCenter, control.count - centerCount));
                pages.push(1);
                pages.push("...");
                for (var i = 0; i < centerCount; i++)
                    pages.push(firstCenter + i + 1);
                pages.push("...");
                pages.push(control.count);
            }
        }

        for (var i = 0; i < repeater.count; i++) {
            var button = repeater.itemAt(i);
            if (!button)
                continue;
            var page = i < pages.length ? pages[i] : "";
            button.text = page;
            button.enabled = page !== "..." && page !== "";
        }
    }
}
