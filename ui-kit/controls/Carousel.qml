import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

Item {
    id: control
    default property alias data: row.data
    property alias visibleCount: indicator.visibleCount
    property alias currentIndex: indicator.currentIndex
    property int lineHeight: Core.Settings.LineHeight
    property int itemWidth: 400
    property int itemHeight: 300
    property int spacing: 12
    property bool indicatorVisible: true
    property bool buttonsVisible: false
    clip: true

    implicitWidth: itemWidth * 3
    implicitHeight: itemHeight + (indicatorVisible ? 4 + indicator.height : 0) + (buttonsVisible ? spacing * 2 + buttonsRow.height : 0)
    width: implicitWidth
    height: implicitHeight

    Flickable {
        id: view
        width: control.itemWidth * 2
        height: control.itemHeight
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: row.implicitWidth
        contentHeight: row.implicitHeight
        boundsBehavior: Flickable.DragAndOvershootBounds
        maximumFlickVelocity: control.itemWidth * 2
        focus: true

        Row {
            id: row
            leftPadding: control.width / 2 - control.itemWidth / 2
            rightPadding: leftPadding
            spacing: control.spacing
        }

        onContentXChanged: updatePosition()
        Behavior on contentX {
            PropertyAnimation {
                duration: 500
                easing.type: Easing.InOutQuint
            }
        }
        function updatePosition() {
            if (!view.moving)
                contentX = control.currentIndex * (control.itemWidth + control.spacing);
        }
        function updateIndex() {
            var pageStep = control.itemWidth + control.spacing;
            if (pageStep <= 0)
                return;
            control.currentIndex = Math.max(0, Math.min(control.data.length - 1, Math.round(view.contentX / pageStep)));
            updatePosition();
        }
        onMovementEnded: updateIndex()
    }

    PageIndicator {
        id: indicator
        anchors.horizontalCenter: parent.horizontalCenter
        y: view.y + view.height + control.spacing
        lineHeight: control.lineHeight
        count: control.data.length
        visibleCount: 5
        currentIndex: 0
        visible: control.indicatorVisible
    }

    Row {
        id: buttonsRow
        anchors.horizontalCenter: parent.horizontalCenter
        y: indicator.y + indicator.height + control.spacing
        spacing: control.spacing
        visible: control.buttonsVisible
        Button {
            lineHeight: control.lineHeight
            text: qsTr("Prev")
            onReleased: decrementCurrentIndex()
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: control.currentIndex + 1
            font: control.lineHeight <= Theme.Sizes.LineHeight.S ? Theme.Fonts.TextMB : Theme.Fonts.TextLB
        }
        Button {
            lineHeight: control.lineHeight
            text: qsTr("Next")
            onReleased: incrementCurrentIndex()
        }
    }

    onCurrentIndexChanged: view.updatePosition()
    Component.onCompleted: view.updatePosition()

    Keys.onLeftPressed: decrementCurrentIndex()
    Keys.onRightPressed: incrementCurrentIndex()

    function decrementCurrentIndex() {
        currentIndex = Math.max(0, currentIndex - 1);
    }
    function incrementCurrentIndex() {
        currentIndex = Math.min(data.length - 1, currentIndex + 1);
    }
}
