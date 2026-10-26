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

    property bool incrementDecade: false
    readonly property int startYear: Math.floor(control.visibleYear / 12. + (incrementDecade ? 1 : 0)) * 12
    readonly property int endYear: startYear + 12

    Repeater {
        model: 12

        Item {
            id: item
            Layout.fillWidth: true
            Layout.fillHeight: true
            activeFocusOnTab: true

            required property int index
            property int year: calendar.startYear + index

            property bool highlighted: enabled && (CalendarFunctions.yearIsEqual(new Date(year, 0), control.dateFrom) || CalendarFunctions.yearIsEqual(new Date(year, 0), control.dateTo))
            property bool hover: enabled && mouseArea.containsMouse
            enabled: CalendarFunctions.yearInRange(new Date(year, 0), control.dateMin, control.dateMax) || CalendarFunctions.yearIsEqual(new Date(year, 0), control.dateMin) || CalendarFunctions.yearIsEqual(new Date(year, 0), control.dateMax)

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 1
                anchors.bottomMargin: 1
                color: Theme.Palette.Background.Default.Tertiary
                visible: control.range && enabled && CalendarFunctions.dateInRange(new Date(year, 0), control.dateFrom, control.dateTo)
            }
            Rectangle {
                id: bg
                anchors.fill: parent

                opacity: enabled ? 1 : 0.4
                color: highlighted ? Theme.Palette.Surface.Default.SolidPrimary : CalendarFunctions.yearIsEqual(new Date(year, 0), control.currentDate) ? Theme.Palette.Surface.Default.SolidSecondary : "transparent"
                border.width: hover ? 1 : 0
                border.color: Theme.Palette.Outline.Default.SolidPrimary
                radius: calendar.lineHeight <= Theme.Sizes.LineHeight.Xs ? 6 : calendar.lineHeight <= Theme.Sizes.LineHeight.S ? 8 : calendar.lineHeight <= Theme.Sizes.LineHeight.M ? 10 : 12

                Label {
                    id: label
                    anchors.centerIn: parent
                    lineHeight: calendar.lineHeight
                    text: year.toString()
                    color: highlighted ? Theme.Palette.Text.Inverse.Primary : Theme.Palette.Text.Default.Primary
                }
            }
            FocusItem {
                visible: parent.activeFocus
                target: bg
                margin: 1
            }
            Keys.onPressed: event => {
                if (item.activeFocus && (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
                    control.setYear(year);
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    control.setDate(new Date(year, 0));
                }
                onClicked: {
                    control.setYear(year);
                }
            }
        }
    }
}
