/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

FocusScope {
    id: popup

    required property date currentDate
    required property date viewedMonth
    required property bool darkMode
    signal closeRequested()
    signal monthChangeRequested(date month)

    readonly property var locale: Qt.locale()
    readonly property string currentDateLabel: titleCase(locale.toString(currentDate, "dddd, d MMMM"))
    readonly property string monthLabel: titleCase(locale.standaloneMonthName(viewedMonth.getMonth(), Locale.LongFormat))
    readonly property int firstWeekday: locale.firstDayOfWeek
    readonly property int leadingDays: (new Date(viewedMonth.getFullYear(), viewedMonth.getMonth(), 1).getDay()
                                        - firstWeekday + 7) % 7
    readonly property int monthDayCount: new Date(viewedMonth.getFullYear(), viewedMonth.getMonth() + 1, 0).getDate()
    readonly property int gridDayCount: Math.ceil((leadingDays + monthDayCount) / 7) * 7
    readonly property int gridRowCount: gridDayCount / 7
    readonly property var weekdayLabels: {
        const labels = []
        for (let column = 0; column < 7; ++column) {
            const day = (firstWeekday + column) % 7
            labels.push(locale.standaloneDayName(day, Locale.ShortFormat).replace(/\.$/, "").slice(0, 2).toLocaleUpperCase())
        }
        return labels
    }
    readonly property var days: {
        const values = []
        const start = new Date(viewedMonth.getFullYear(), viewedMonth.getMonth(), 1 - leadingDays)
        for (let index = 0; index < gridDayCount; ++index) {
            const day = new Date(start.getFullYear(), start.getMonth(), start.getDate() + index)
            values.push({
                dayNumber: day.getDate(),
                outsideMonth: day.getMonth() !== viewedMonth.getMonth(),
                today: day.getMonth() === viewedMonth.getMonth()
                       && day.getFullYear() === currentDate.getFullYear()
                       && day.getMonth() === currentDate.getMonth()
                       && day.getDate() === currentDate.getDate(),
                dateLabel: locale.toString(day, "dddd, d MMMM yyyy")
            })
        }
        return values
    }

    implicitWidth: 344
    implicitHeight: 382
    width: implicitWidth
    height: implicitHeight
    focus: true

    function titleCase(value) {
        return value.length ? value.charAt(0).toLocaleUpperCase() + value.slice(1) : value
    }

    function moveMonth(offset) {
        popup.monthChangeRequested(new Date(viewedMonth.getFullYear(), viewedMonth.getMonth() + offset, 1))
    }

    Keys.onEscapePressed: event => {
        event.accepted = true
        popup.closeRequested()
    }

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: popup.darkMode ? "#e822272d" : "#e8edf3ee"
        border.width: 1
        border.color: popup.darkMode ? "#35ffffff" : "#aaffffff"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: popup.currentDateLabel
                color: popup.darkMode ? "#f0f2f4" : "#30343a"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                text: qsTr("Встреч пока нет")
                color: popup.darkMode ? "#a9b0b7" : "#737b82"
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: popup.darkMode ? "#ed252b31" : "#f7ffffff"
            border.width: 1
            border.color: popup.darkMode ? "#1affffff" : "#70ffffff"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    spacing: 4

                    Button {
                        id: previousMonthButton
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        text: "‹"
                        Accessible.name: qsTr("Предыдущий месяц")
                        onClicked: popup.moveMonth(-1)

                        contentItem: Text {
                            text: previousMonthButton.text
                            color: popup.darkMode ? "#d9dfe4" : "#525960"
                            font.pixelSize: 28
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 10
                            color: previousMonthButton.hovered
                                   ? (popup.darkMode ? "#30ffffff" : "#16000000")
                                   : "transparent"
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("%1 %2 ▾").arg(popup.monthLabel).arg(popup.viewedMonth.getFullYear())
                        color: popup.darkMode ? "#d9dfe4" : "#525960"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Button {
                        id: nextMonthButton
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        text: "›"
                        Accessible.name: qsTr("Следующий месяц")
                        onClicked: popup.moveMonth(1)

                        contentItem: Text {
                            text: nextMonthButton.text
                            color: popup.darkMode ? "#d9dfe4" : "#525960"
                            font.pixelSize: 28
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            radius: 10
                            color: nextMonthButton.hovered
                                   ? (popup.darkMode ? "#30ffffff" : "#16000000")
                                   : "transparent"
                        }
                    }
                }

                Row {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    Repeater {
                        model: popup.weekdayLabels
                        delegate: Text {
                            required property string modelData
                            width: 40
                            height: 24
                            text: modelData
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: popup.darkMode ? "#9ba4ad" : "#929ba4"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: popup.gridRowCount * 40
                    columns: 7
                    rowSpacing: 0
                    columnSpacing: 0

                    Repeater {
                        model: popup.days
                        delegate: CalendarDayButton {
                            required property var modelData
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            dayNumber: modelData.dayNumber
                            outsideMonth: modelData.outsideMonth
                            today: modelData.today
                            dateLabel: modelData.dateLabel
                            darkMode: popup.darkMode
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
