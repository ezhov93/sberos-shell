/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

FocusScope {
    id: popup

    required property date currentDate
    required property date viewedMonth
    required property bool darkMode
    signal closeRequested()
    signal monthChangeRequested(date month)

    readonly property SmartPanelTheme smartTheme: SmartPanelTheme { dark: popup.darkMode }
    property date selectedDate: currentDate
    readonly property var locale: Qt.locale()
    readonly property string currentDateLabel: titleCase(locale.toString(currentDate, "ddd, d MMMM"))
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
                dateLabel: locale.toString(day, "dddd, d MMMM yyyy"),
                value: day,
                selected: day.getFullYear() === selectedDate.getFullYear() && day.getMonth() === selectedDate.getMonth() && day.getDate() === selectedDate.getDate(),
                past: day < new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate())
            })
        }
        return values
    }

    implicitWidth: 344
    implicitHeight: 382 + Math.max(0, gridRowCount - 5) * 44
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
        radius: 24
        color: smartTheme.shell
        border.width: 1
        border.color: smartTheme.edge
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        anchors.topMargin: 12
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: popup.currentDateLabel
                color: smartTheme.foreground
                font.pixelSize: 16
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                text: qsTr("Только даты")
                color: smartTheme.muted
                font.pixelSize: 15
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 16
            color: smartTheme.inner
            border.width: 0

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 4

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

                        contentItem: Item {
                            SmartPanelIcon {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: Qt.resolvedUrl("../assets/smart-panel/left.svg")
                                isMask: true
                                color: smartTheme.foreground
                            }
                        }
                        background: Rectangle {
                            radius: 10
                            color: previousMonthButton.down ? smartTheme.pressed : previousMonthButton.hovered ? smartTheme.hover : "transparent"
                            border.width: previousMonthButton.visualFocus ? 2 : 0
                            border.color: smartTheme.focus
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("%1 %2").arg(popup.monthLabel).arg(popup.viewedMonth.getFullYear())
                        color: smartTheme.foreground
                        font.pixelSize: 16
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

                        contentItem: Item {
                            SmartPanelIcon {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: Qt.resolvedUrl("../assets/smart-panel/right.svg")
                                isMask: true
                                color: smartTheme.foreground
                            }
                        }
                        background: Rectangle {
                            radius: 10
                            color: nextMonthButton.down ? smartTheme.pressed : nextMonthButton.hovered ? smartTheme.hover : "transparent"
                            border.width: nextMonthButton.visualFocus ? 2 : 0
                            border.color: smartTheme.focus
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
                            color: smartTheme.muted
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: popup.gridRowCount * 40 + (popup.gridRowCount - 1) * 4
                    columns: 7
                    rowSpacing: 4
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
                            selected: modelData.selected
                            past: modelData.past
                            onClicked: {
                                popup.selectedDate = modelData.value;
                                if (modelData.outsideMonth) popup.monthChangeRequested(new Date(modelData.value.getFullYear(), modelData.value.getMonth(), 1));
                            }
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
