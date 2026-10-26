import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.TabBar {
    id: control

    property int lineHeight: Core.Settings.LineHeight
    property bool arrowsVisible: true
    property int arrowSize: 24

    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    spacing: 14
    padding: lineHeight <= Theme.Sizes.LineHeight.Xs ? 10 : lineHeight == Theme.Sizes.LineHeight.S ? 14 : lineHeight == Theme.Sizes.LineHeight.M ? 18 : 22
    leftPadding: decrementIcon.visible ? decrementIcon.width : 0
    rightPadding: leftPadding
    topPadding: padding
    bottomPadding: padding
    property bool stretch: false
    clip: true

    IconButton {
        id: decrementIcon
        parent: control
        anchors.top: parent.top
        anchors.left: parent.left
        width: control.arrowSize
        height: control.height

        visible: false
        backgroundType: Widget.Clear
        type: Widget.Default
        icon.name: "ChevronLeft"
        iconItem.size: control.arrowSize - 8

        onPressed: {
            control.decrementCurrentIndex();
        }
    }

    contentItem: ListView {
        id: tabView
        parent: control
        model: control.contentModel
        currentIndex: control.currentIndex
        implicitHeight: contentHeight

        spacing: control.spacing * 2
        orientation: ListView.Horizontal
        flickableDirection: Flickable.AutoFlickIfNeeded
        preferredHighlightBegin: control.leftPadding
        snapMode: ListView.SnapToItem
        clip: true

        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlightFollowsCurrentItem: true
        highlightRangeMode: ListView.ApplyRange

        highlight: Item {
            id: hl
            Rectangle {
                parent: control
                x: hl.x - tabView.contentX + control.leftPadding + (control.stretch ? -control.spacing : 0)
                y: control.position === T.TabBar.Footer ? 0 : control.height - height
                z: 3
                height: 2
                width: hl.width + (control.stretch ? control.spacing * 2 : 0)
                radius: 1
                color: Theme.Palette.Outline.Default.SolidPrimary
                opacity: enabled ? 1 : 0.4
            }
        }

        function updateContentSize() {
            var minimalWidth = 0;
            var maxItemWidth = (tabView.width - control.spacing * 2 * (tabView.count - 1)) / (tabView.count);
            for (var i = 0; i < tabView.count; i++) {
                var it = itemAtIndex(i);
                if (it) {
                    if (stretch) {
                        it.width = Math.max(maxItemWidth, it.implicitWidth);
                    } else {
                        it.width = it.implicitWidth;
                    }
                    minimalWidth += it.implicitWidth;
                }
            }
            decrementIcon.visible = control.arrowsVisible && (control.width < minimalWidth + control.spacing * 2 * tabView.count);
            tabView.positionViewAtIndex(tabView.currentIndex, ListView.Contain);
        }
        onWidthChanged: {
            updateContentSize();
        }
        onHeightChanged: {
            updateContentSize();
        }
        Component.onCompleted: {
            updateContentSize();
        }
    }

    background: Rectangle {
        x: control.leftPadding
        y: control.position === T.TabBar.Footer ? 0 : parent.height - height
        width: control.width - control.leftPadding * 2
        height: 1
        color: Theme.Palette.Surface.Default.TransparentSecondary
    }

    IconButton {
        id: incrementIcon
        parent: control
        anchors.top: parent.top
        anchors.right: parent.right
        width: control.arrowSize
        height: control.height

        visible: decrementIcon.visible
        backgroundType: Widget.Clear
        type: Widget.Default
        icon.name: "ChevronRight"
        iconItem.size: control.arrowSize - 8

        onPressed: {
            control.incrementCurrentIndex();
        }
    }
}
