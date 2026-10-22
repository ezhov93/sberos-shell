import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme


T.PageIndicator {
    id: control

    property int lineHeight: Core.Settings.LineHeight
    property int indicatorSize: lineHeight <= Theme.Sizes.S ? 8 : 12
    property color color: Theme.Palette.Surface.Default.SolidSecondary
    property color activeColor: Theme.Palette.Surface.Default.SolidPrimary
    property int visibleCount: count

    implicitWidth: control.visibleCount * control.indicatorSize + (control.visibleCount - 1) * control.spacing
    implicitHeight: control.indicatorSize
    width: implicitWidth
    height: implicitHeight
    padding: 6
    spacing: lineHeight <= Theme.Sizes.S ? 8 : 12
    opacity: enabled ? 1 : 0.4
    interactive: false

    delegate: Rectangle {
        color: "transparent"
        width: control.indicatorSize
        height: control.indicatorSize
        Rectangle {
            id: indicator
            anchors.centerIn: parent
            property int size: index === control.currentIndex ||
                               control.currentIndex === 0 && index === 1 ||
                               control.currentIndex === control.count - 1 && index === control.count - 2
                                   ? control.indicatorSize :
                               (index === 0 || index === control.count - 1)
                                   ? 6 :
                               control.lineHeight >= Theme.Sizes.LineHeight.M &&
                               (index === 1 || index === control.count - 2)
                                   ? 8 :
                                   control.indicatorSize
            width: size
            height: size
            radius: height / 2
            color: index === control.currentIndex ? control.activeColor : control.color

            Behavior on size {
                PropertyAnimation { duration: 300; easing.type: Easing.InOutQuint }
            }
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onReleased: {
                control.currentIndex = index;
            }
        }
    }

    contentItem: Flickable {
        id: contentArea
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick
        width: control.width
        height: contentHeight
        contentWidth: row.implicitWidth
        contentHeight: row.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        interactive: false
        clip: true

        Row {
            id: row
            spacing: control.spacing
            Repeater {
                model: control.count
                delegate: control.delegate
            }
        }
    }

    onCurrentIndexChanged: {
        contentArea.contentX = Math.max((Math.min(control.currentIndex - 2, control.count - control.visibleCount)) *
            (control.indicatorSize + control.spacing), 0)
    }
}
