import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Sber.Controls
import Sber.Core
import Sber.Theme


GridLayout {
    id: calendar
    columns: 3
    rowSpacing: 0
    columnSpacing: 0
    activeFocusOnTab: false

    property QtObject control
    property int lineHeight: Core.Settings.LineHeight

    property bool incrementYear: false
    readonly property int year: control.visibleYear + (incrementYear ? 1 : 0)

    Repeater {
        model: 12

        Item {
            id: item
            Layout.fillWidth: true
            Layout.fillHeight: true
            activeFocusOnTab: true

            required property int index

            property bool highlighted: enabled &&
                (CalendarFunctions.monthIsEqual(new Date(year, index), control.dateFrom) ||
                 CalendarFunctions.monthIsEqual(new Date(year, index), control.dateTo))
            property bool hover: enabled && mouseArea.containsMouse
            enabled: CalendarFunctions.monthInRange(new Date(year, index), control.dateMin, control.dateMax) ||
                     CalendarFunctions.monthIsEqual(new Date(year, index), control.dateFrom) ||
                     CalendarFunctions.monthIsEqual(new Date(year, index), control.dateTo)

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                color: Theme.Palette.Background.Default.Tertiary
                visible: control.range && enabled && CalendarFunctions.monthInRange(
                             new Date(year, index), control.dateFrom, control.dateTo)
            }
            Rectangle {
                id: bg
                anchors.fill: parent

                opacity: enabled ? 1 : 0.4
                color: highlighted                                                                ? Theme.Palette.Surface.Default.SolidPrimary :
                       CalendarFunctions.monthIsEqual(new Date(year, index), control.currentDate) ? Theme.Palette.Surface.Default.SolidSecondary :
                                                                                                    "transparent"
                border.width: hover ? 1 : 0
                border.color: Theme.Palette.Outline.Default.SolidPrimary
                radius: calendar.lineHeight <= Theme.Sizes.LineHeight.Xs ? 6 :
                        calendar.lineHeight <= Theme.Sizes.LineHeight.S  ? 8 :
                        calendar.lineHeight <= Theme.Sizes.LineHeight.M  ? 10 :
                                                                           12

                Label {
                    anchors.centerIn: parent
                    lineHeight: calendar.lineHeight
                    text: CalendarFunctions.getMonthName(index, control.locale)
                    color: highlighted ?
                               Theme.Palette.Text.Inverse.Primary :
                               Theme.Palette.Text.Default.Primary
                }
                FocusItem {
                    target: parent
                }
            }
            FocusItem {
                visible: parent.activeFocus
                target: bg
                margin: 1
            }
            Keys.onPressed: (event) => {
                if (item.activeFocus && (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
                    control.setMonth(calendar.year, index);
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: { control.setDate(new Date(year, index)); }
                onClicked: { control.setMonth(calendar.year, index); }
            }
        }
    }
}
