import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Theme

TextField {
    id: control

    property var date
    property alias selectType: calendar.selectType
    property alias currentDate: calendar.currentDate
    property alias visibleMonth: calendar.visibleMonth
    property alias visibleYear: calendar.visibleYear
    property alias dateMin: calendar.dateMin
    property alias dateMax: calendar.dateMax
    property alias doubled: calendar.doubled
    property var locale: Qt.locale()

    opacity: enabled ? 1 : 0.4
    activeFocusOnTab: true

    validator: RegularExpressionValidator {
        regularExpression: /(?:\d{1,2}(?:\.|\,|\\|\-)){2}\d{4}/
    }

    onTextEdited: {
        popup.open();
        var date = CalendarFunctions.textToDate(control.text, control.locale);
        if (CalendarFunctions.isValid(date)) {
            calendar.dateFrom = date;
            control.visibleMonth = date.getMonth();
            control.visibleYear = date.getFullYear();
        }
    }
    onAccepted: {
        control.focus = false;
        popup.close();
        if (control.text != "") {
            var date = CalendarFunctions.textToDate(control.text, control.locale);
            if (date && !isNaN(date)) {
                if (CalendarFunctions.dateIsLess(date, control.dateMin)) {
                    date = control.dateMin;
                } else if (CalendarFunctions.dateIsLess(control.dateMax, date)) {
                    date = control.dateMax;
                }
                control.date = date;
            }
        }
    }
    onActiveFocusChanged: {
        if (activeFocus)
            popup.open();
        else
            popup.close();
    }

    Popup {
        id: popup
        y: control.background.y + control.background.height
        radius: control.background.radius
        width: calendar.width
        height: calendar.height
        locale: control.locale

        CalendarView {
            id: calendar
            lineHeight: control.lineHeight

            onDateChanged: {
                if (!CalendarFunctions.dateIsEqual(control.date, calendar.dateFrom)) {
                    control.date = calendar.dateFrom;
                    control.accepted();
                }
                popup.close();
            }
        }

        onVisibleChanged: {
            if (!visible) {
                control.focus = false;
            }
        }
    }

    onDateChanged: {
        if (CalendarFunctions.isValid(control.date)) {
            control.text = CalendarFunctions.dateToText(control.date, control.locale);
            if (!CalendarFunctions.dateIsEqual(control.date, calendar.dateFrom)) {
                calendar.dateFrom = control.date;
                control.visibleMonth = control.date.getMonth();
                control.visibleYear = control.date.getFullYear();
            }
        }
    }
}
