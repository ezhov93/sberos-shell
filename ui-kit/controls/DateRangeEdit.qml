import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Theme

Control {
    id: control

    property alias lineHeight: inputFrom.lineHeight
    property alias label: inputFrom.label
    property alias labelText: inputFrom.labelText
    property alias labelColor: inputFrom.labelColor
    property alias labelFont: inputFrom.labelFont
    property alias caption: inputFrom.caption
    property alias captionText: inputFrom.captionText
    property alias captionColor: inputFrom.captionColor
    property alias captionFont: inputFrom.captionFont
    property alias placeholderTextFrom: inputFrom.placeholderText
    property alias placeholderTextColorFrom: inputFrom.placeholderTextColor
    property alias placeholderTextTo: inputTo.placeholderText
    property alias placeholderTextColorTo: inputTo.placeholderTextColor
    property alias iconFromLeft: inputFrom.iconLeft
    property alias iconFromRight: inputFrom.iconRight
    property alias iconToLeft: inputTo.iconLeft
    property alias iconToRight: inputTo.iconRight
    property alias required: inputFrom.required
    property alias requiredPlacement: inputFrom.requiredPlacement
    property alias status: backgroundConfig.status
    property int delimiter: Widget.Arrow

    property alias textFrom: inputFrom.text
    property alias textTo: inputTo.text
    property var dateFrom
    property var dateTo
    property alias selectType: calendar.selectType
    property alias currentDate: calendar.currentDate
    property alias visibleMonth: calendar.visibleMonth
    property alias visibleYear: calendar.visibleYear
    property alias dateMin: calendar.dateMin
    property alias dateMax: calendar.dateMax
    property alias doubled: calendar.doubled

    implicitWidth: Math.max(150, inputFrom.implicitWidth, inputTo.implicitWidth) * 2 + (icon.visible ? icon.implicitWidth + spacing * 2 : 0)
    implicitHeight: inputFrom.implicitHeight
    spacing: 6

    signal accepted

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        backgroundType: Widget.Outline
    }
    property Colorizer colorizer: Colorizer {
        id: colorizer
        defaultColor: backgroundConfig.defaultColor
        hovered: control.enabled && control.hovered
        hoverColor: backgroundConfig.hoverColor
        activated: inputFrom.activeFocus || inputTo.activeFocus
        activeColor: backgroundConfig.activeColor
    }

    background: Rectangle {
        id: bg
        y: inputFrom.background.y
        height: inputFrom.background.height
        radius: inputFrom.backgroundConfig.radius
        color: Theme.Palette.Background.Default.Basic
        opacity: enabled ? 1 : 0.4
        border.width: colorizer.borderWidth
        border.color: colorizer.currentColor
        z: 0
    }
    FocusItem {
        visible: inputFrom.focus && (inputFrom.focusReason == Qt.TabFocus || inputFrom.focusReason == Qt.BacktabFocusReason) || inputTo.focus && (inputTo.focusReason == Qt.TabFocus || inputTo.focusReason == Qt.BacktabFocusReason)
    }

    TextField {
        id: inputFrom
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: icon.left
        anchors.rightMargin: icon.visible ? control.spacing : 0
        anchors.bottom: parent.bottom
        background.visible: false
        z: 100

        Component.onCompleted: focusItem.destroy()

        validator: RegularExpressionValidator {
            regularExpression: /(?:\d{1,2}(?:\.|\,|\\|\-)){2}\d{4}/
        }

        onTextEdited: {
            popup.open();
            var date = CalendarFunctions.textToDate(inputFrom.text, control.locale);
            if (CalendarFunctions.isValid(date)) {
                calendar.dateFrom = date;
                control.visibleMonth = date.getMonth();
                control.visibleYear = date.getFullYear();
            }
        }
        onAccepted: {
            control.focus = false;
            popup.close();
            if (inputFrom.text != "") {
                var date = CalendarFunctions.textToDate(inputFrom.text, control.locale);
                if (date && !isNaN(date)) {
                    if (CalendarFunctions.dateIsLess(date, control.dateMin)) {
                        date = control.dateMin;
                    } else if (CalendarFunctions.dateIsLess(control.dateMax, date)) {
                        date = control.dateMax;
                    }
                    if (CalendarFunctions.dateIsLess(control.dateTo, date)) {
                        control.dateFrom = control.dateTo;
                        control.dateTo = date;
                    } else {
                        control.dateFrom = date;
                    }
                }
            }
            control.accepted();
        }
        onActiveFocusChanged: {
            if (activeFocus)
                popup.open();
            else
                popup.close();
        }
    }
    Icon {
        id: icon
        anchors.centerIn: bg
        name: control.delimiter == Widget.Arrow ? "ArrowRight" : control.delimiter == Widget.Minus ? "Minus" : ""
        size: 24
        visible: control.delimiter != Widget.NoDelimiter
        opacity: enabled ? 1 : 0.4
        z: 100
    }
    TextField {
        id: inputTo
        y: inputFrom.background.y
        anchors.left: icon.right
        anchors.leftMargin: icon.visible ? control.spacing : 0
        anchors.right: parent.right
        lineHeight: control.lineHeight
        background.visible: false
        z: 100

        Component.onCompleted: focusItem.destroy()

        validator: RegularExpressionValidator {
            regularExpression: /(?:\d{1,2}(?:\.|\,|\\|\-)){2}\d{4}/
        }

        onTextEdited: {
            popup.open();
            var date = CalendarFunctions.textToDate(inputTo.text, control.locale);
            if (CalendarFunctions.isValid(date)) {
                calendar.dateTo = date;
                control.visibleMonth = date.getMonth();
                control.visibleYear = date.getFullYear();
            }
        }
        onAccepted: {
            control.focus = false;
            popup.close();
            if (inputTo.text) {
                var date = CalendarFunctions.textToDate(inputTo.text, control.locale);
                if (date && !isNaN(date)) {
                    if (CalendarFunctions.dateIsLess(date, control.dateMin)) {
                        date = control.dateMin;
                    } else if (CalendarFunctions.dateIsLess(control.dateMax, date)) {
                        date = control.dateMax;
                    }
                    if (CalendarFunctions.dateIsLess(date, control.dateFrom)) {
                        control.dateTo = control.dateFrom;
                        control.dateFrom = date;
                    } else {
                        control.dateTo = date;
                    }
                }
            }
            control.accepted();
        }
        onActiveFocusChanged: {
            if (activeFocus)
                popup.open();
            else
                popup.close();
        }
    }

    Popup {
        id: popup
        y: inputFrom.background.y + inputFrom.background.height
        radius: inputFrom.background.radius
        width: calendar.width
        height: calendar.height

        CalendarView {
            id: calendar
            lineHeight: control.lineHeight
            range: true
            locale: control.locale

            onDateChanged: {
                var needAccept = false;
                if (!CalendarFunctions.dateIsEqual(control.dateFrom, calendar.dateFrom)) {
                    control.dateFrom = calendar.dateFrom;
                    needAccept = true;
                }
                if (!CalendarFunctions.dateIsEqual(control.dateTo, calendar.dateTo)) {
                    control.dateTo = calendar.dateTo;
                    needAccept = true;
                }
                if (needAccept)
                    control.accepted();
                popup.close();
            }
        }

        onVisibleChanged: {
            if (!visible) {
                inputFrom.focus = false;
                inputTo.focus = false;
            }
        }
    }

    onDateFromChanged: {
        if (CalendarFunctions.isValid(control.dateFrom)) {
            inputFrom.text = CalendarFunctions.dateToText(control.dateFrom, control.locale);
            if (!CalendarFunctions.dateIsEqual(control.dateFrom, calendar.dateFrom)) {
                calendar.dateFrom = control.dateFrom;
                control.visibleMonth = control.dateFrom.getMonth();
                control.visibleYear = control.dateFrom.getFullYear();
            }
        }
    }
    onDateToChanged: {
        if (CalendarFunctions.isValid(control.dateTo)) {
            inputTo.text = CalendarFunctions.dateToText(control.dateTo, control.locale);
            if (!CalendarFunctions.dateIsEqual(control.dateTo, calendar.dateTo)) {
                calendar.dateTo = control.dateTo;
                control.visibleMonth = control.dateTo.getMonth();
                control.visibleYear = control.dateTo.getFullYear();
            }
        }
    }
}
