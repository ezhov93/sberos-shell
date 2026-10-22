import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Core
import Sber.Theme


Item {
    id: calendar
    implicitWidth: Math.max(weekTitles.width, monthGrid.width)
    width: implicitWidth
    implicitHeight: weekTitles.height + monthGrid.height
    height: implicitHeight
    activeFocusOnTab: false

    property QtObject control
    property bool incrementMonth: false
    readonly property int month: monthGrid.month
    readonly property int year: monthGrid.year

    DayOfWeekRow {
        id: weekTitles
        anchors.top: parent.top
        width: control.cellWidth * 7
        height: control.cellHeight
        spacing: 0
        activeFocusOnTab: false

        delegate: Label {
            width: control.cellWidth
            height: control.cellHeight
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            lineHeight: control.lineHeight
            text: CalendarFunctions.upperFirst(model.shortName)
        }
    }

    MonthGrid {
        id: monthGrid
        anchors.top: weekTitles.bottom
        width: control.cellWidth * 7
        height: control.cellHeight * 6
        spacing: 0
        padding: 0
        property int increment: calendar.incrementMonth ? 1 : 0
        month: (control.visibleMonth + increment) % 12
        year: control.visibleYear + Math.floor((control.visibleMonth + increment) / 12.)
        activeFocusOnTab: false

        delegate: Item {
            id: item
            width: control.cellWidth
            height: control.cellHeight
            activeFocusOnTab: true

            property bool highlighted: enabled &&
                (CalendarFunctions.dateIsEqual(model.date, control.dateFrom) ||
                 CalendarFunctions.dateIsEqual(model.date, control.dateTo))
            property bool hover: enabled && mouseArea.containsMouse
            enabled: model.month === monthGrid.month &&
                (CalendarFunctions.dateInRange(model.date, control.dateMin, control.dateMax) ||
                 CalendarFunctions.dateIsEqual(model.date, control.dateFrom) ||
                 CalendarFunctions.dateIsEqual(model.date, control.dateTo))
            opacity: enabled ? 1 : 0.4

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                color: Theme.Palette.Background.Default.Tertiary
                visible: control.range && enabled && CalendarFunctions.dateInRange(
                             model.date, control.dateFrom, control.dateTo)
            }
            Rectangle {
                id: bg
                anchors.fill: parent
                color: highlighted                                                    ? Theme.Palette.Surface.Default.SolidPrimary :
                       CalendarFunctions.dateIsEqual(model.date, control.currentDate) ? Theme.Palette.Surface.Default.SolidSecondary :
                                                                                        "transparent"
                border.width: hover ? 1 : 0
                border.color: Theme.Palette.Outline.Default.SolidPrimary
                radius: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 6 :
                        control.lineHeight <= Theme.Sizes.LineHeight.S  ? 8 :
                        control.lineHeight <= Theme.Sizes.LineHeight.M  ? 10 :
                                                                           12

                Label {
                    anchors.centerIn: parent
                    lineHeight: control.lineHeight
                    text: model.day
                    color: highlighted ? Theme.Palette.Text.Inverse.Primary :
                                         Theme.Palette.Text.Default.Primary
                }
            }
            FocusItem {
                visible: parent.activeFocus
                target: bg
                margin: 1
            }
            Keys.onPressed: (event) => {
                if (item.activeFocus && (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
                    control.setDate(model.date, true);
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { control.setDate(model.date); }
                onClicked: { control.setDate(model.date, true); }
            }
        }
    }
}
