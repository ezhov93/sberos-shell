import QtQuick
import QtQuick.Controls

import Sber.Controls as SberControls
import Sber.Theme


Item {
    id: control

    property alias isNeedSeconds: timePickerView.isNeedSeconds
    property alias isNeedDropDown: timePickerView.isNeedDropDown
    property alias time: textField.time
    property string labelText
    property var locale: Qt.locale()
    property string iconName: "ArrowRight"
    signal accepted()

    Column {
        spacing: 10
        
        SberControls.Label {
            font: Theme.Fonts.BodyM
            text: labelText
            visible: labelText !== ""
        }

        SberControls.TextField {
            id: textField

            property string time

            font: Theme.Fonts.BodyM
            iconRight.name: control.iconName
            iconRight.size: 24
            opacity: enabled ? 1 : 0.4
            activeFocusOnTab: true

            validator: RegularExpressionValidator {
                regularExpression: control.isNeedSeconds ? /^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$/
                                                                : /^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/
            }

            onTextEdited: {
                const convertedTime = CalendarFunctions.textToTime(textField.text);
                if (!CalendarFunctions.timeIsEqual(convertedTime, timePickerView.currentTime)) {
                    timePickerView.currentTime = convertedTime;
                    textField.time = convertedTime;
                    textField.accepted();
                }
            }

            onAccepted: {
                if (textField.text !== "") {
                    var convertedTime = CalendarFunctions.textToTime(textField.text);
                    if (CalendarFunctions.isValid(convertedTime)) {
                        textField.time = convertedTime;
                        control.accepted();
                    }
                }
            }
            onActiveFocusChanged: {
                if (activeFocus && control.isNeedDropDown)
                    popup.open();
                else
                    popup.close();
            }

            SberControls.Popup {
                id: popup

                y: textField.background.y + textField.background.height
                radius: textField.background.radius
                width: timePickerView.width
                height: timePickerView.height
                locale: textField.locale

                TimePickerView {
                    id: timePickerView
                    
                    lineHeight: textField.lineHeight

                    onTimeChanged: {
                        if (!CalendarFunctions.timeIsEqual(CalendarFunctions.textToTime(textField.time), timePickerView.currentTime)) {
                            textField.time = timePickerView.currentTime.toTimeString();
                            textField.accepted();
                        }
                    }
                }

                onVisibleChanged: {
                    if (!visible) {
                        textField.focus = false;
                    }
                }
            }

            onTimeChanged: {
                const convertedDate = CalendarFunctions.textToTime(textField.time);
                if (CalendarFunctions.isValid(convertedDate)) {             
                    textField.text = control.isNeedSeconds ? textField.time 
                                                           : textField.time.length > 5 ? textField.time.slice(0, -3)
                                                                                         : textField.time

                    if (!CalendarFunctions.timeIsEqual(convertedDate, timePickerView.currentTime)) {
                        timePickerView.currentTime = convertedDate;
                    }
                }
            }
        }
    }
}
