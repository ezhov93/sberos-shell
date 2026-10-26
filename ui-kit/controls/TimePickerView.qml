import QtQuick
import QtQuick.Controls

import Sber.Core
import Sber.Theme

Rectangle {
    id: root
    property var currentTime: new Date()
    property alias lineHeight: backgroundConfig.lineHeight
    property var locale: Qt.locale()
    property bool isNeedSeconds: false
    property bool isNeedDropDown: true

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        lineHeight: Core.Settings.LineHeight
    }

    readonly property int padding: 16
    readonly property int cellWidth: 112
    readonly property int cellHeight: 214
    readonly property int delimiterWidth: 24

    signal timeChanged

    clip: true
    color: Theme.Palette.Background.Default.Basic
    radius: backgroundConfig.radius

    implicitWidth: root.isNeedSeconds ? cellWidth * 3 + delimiterWidth * 2 + padding * 2 : cellWidth * 2 + delimiterWidth + padding * 2
    width: implicitWidth
    implicitHeight: cellHeight
    height: implicitHeight

    Item {
        id: viewWrapper

        anchors.fill: parent
        anchors.margins: root.padding
        TimePart {
            id: hourCell

            isNeedDropDown: root.isNeedDropDown
            x: 0
            y: 0

            width: root.cellWidth
            height: parent.height
            lineHeight: root.lineHeight
            maxValue: 24
            onTimePartDataChanged: function (value) {
                if (CalendarFunctions.isHourValid(value)) {
                    root.currentTime.setHours(value);
                    timeData = value;
                    root.timeChanged();
                }
            }
        }
        TimeDelimiter {
            id: minuteDelimiter

            x: hourCell.width
            y: 0
            width: delimiterWidth
            height: parent.height
        }
        TimePart {
            id: minuteCell

            isNeedDropDown: root.isNeedDropDown
            x: minuteDelimiter.x + minuteDelimiter.width
            y: 0
            width: root.cellWidth
            height: parent.height
            onTimePartDataChanged: function (value) {
                if (CalendarFunctions.isMinuteValid(value)) {
                    root.currentTime.setMinutes(value);
                    timeData = value;
                    root.timeChanged();
                }
            }
        }
        TimeDelimiter {
            id: secondDelimiter

            x: minuteCell.x + minuteCell.width
            y: 0
            width: delimiterWidth
            height: parent.height
            visible: isNeedSeconds
        }
        TimePart {
            id: secondCell

            isNeedDropDown: root.isNeedDropDown
            x: secondDelimiter.x + secondDelimiter.width
            y: 0
            lineHeight: root.lineHeight
            width: root.cellWidth
            height: parent.height
            visible: isNeedSeconds
            onTimePartDataChanged: function (value) {
                if (CalendarFunctions.isSecondsValid(value)) {
                    root.currentTime.setSeconds(value);
                    timeData = value;
                    root.timeChanged();
                }
            }
        }
    }
    onCurrentTimeChanged: {
        hourCell.timeData = currentTime.getHours();
        minuteCell.timeData = currentTime.getMinutes();
        secondCell.timeData = currentTime.getSeconds();
    }
}
