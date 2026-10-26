import QtQuick
import Sber.Controls as Sber
import Sber.Core as SberCore
import SircaShell

Item {
    id: cal
    property bool open: false
    implicitWidth: 324
    implicitHeight: col.implicitHeight + 12
    readonly property var loc: Qt.locale()
    property date now: new Date()
    property date selected: new Date()

    Timer {
        interval: 10000
        repeat: true
        running: cal.open
        triggeredOnStart: true
        onTriggered: cal.now = new Date()
    }

    onOpenChanged: {
        if (open) {
            const today = new Date();
            now = today;
            selected = today;
            calendarView.visibleYear = today.getFullYear();
            calendarView.visibleMonth = today.getMonth();
            calendarView.dateFrom = today;
        }
    }

    CalendarModel {
        id: events
        dirs: Config.get("calendarDirs", events.defaultDirs())
    }

    readonly property var dayEvents: {
        events.revision;
        return events.occurrences(cal.selected, cal.selected);
    }
    readonly property int minuteTick: Math.floor(now.getTime() / 60000)
    readonly property var nextEvent: {
        events.revision;
        minuteTick;
        const today = new Date();
        const list = events.occurrences(today, new Date(today.getTime() + 30 * 86400000));
        for (const occurrence of list) {
            if (occurrence.end > today)
                return occurrence;
        }
        return null;
    }

    function sameDay(left, right) {
        return left.getFullYear() === right.getFullYear() && left.getMonth() === right.getMonth() && left.getDate() === right.getDate();
    }

    function timeAt(date) {
        return date.toLocaleTimeString(loc, Locale.ShortFormat).replace(/\s?[AP]M$/i, match => match.trim().toLowerCase());
    }

    function timeOf(event) {
        return event.allDay ? qsTr("all day") : timeAt(event.start);
    }

    function whenOf(event) {
        const today = new Date();
        if (event.start <= today)
            return qsTr("Now · until %1").arg(event.allDay ? qsTr("tomorrow") : timeAt(event.end));

        const minutes = Math.round((event.start - today) / 60000);
        if (!event.allDay && minutes < 90)
            return qsTr("in %1 min").arg(minutes);

        const days = Math.round((new Date(event.firstDay + "T00:00:00") - new Date(today.getFullYear(), today.getMonth(), today.getDate())) / 86400000);
        const time = event.allDay ? "" : " " + timeOf(event);
        if (days === 0)
            return timeOf(event);
        if (days === 1)
            return qsTr("Tomorrow") + time;
        if (days < 7)
            return loc.dayName(event.start.getDay(), Locale.ShortFormat) + time;
        return event.start.toLocaleDateString(loc, "d MMM") + time;
    }

    Column {
        id: col
        x: 6
        y: 6
        width: parent.width - 12
        spacing: 10

        Column {
            width: parent.width
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Config.ink
                font.pixelSize: 16
                font.weight: Font.Medium
                text: cal.now.toLocaleDateString(cal.loc, "dddd, d MMMM")
            }

            Item {
                width: parent.width
                height: cal.nextEvent ? 30 : 0
                visible: !!cal.nextEvent
                clip: true

                Rectangle {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 3
                    height: 24
                    width: Math.min(parent.width - 12, nextRow.implicitWidth + 22)
                    radius: 12
                    color: Config.fg(0.07)
                    border.width: 1
                    border.color: Config.fg(0.08)

                    Row {
                        id: nextRow
                        anchors.centerIn: parent
                        spacing: 7

                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            anchors.verticalCenter: parent.verticalCenter
                            color: cal.nextEvent && cal.nextEvent.color !== "" ? cal.nextEvent.color : Config.accent
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            color: Config.ink
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, 190)
                            text: cal.nextEvent ? cal.nextEvent.summary : ""
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            color: Config.inkDim
                            font.pixelSize: 12
                            font.features: {
                                "tnum": 1
                            }
                            text: cal.nextEvent ? cal.whenOf(cal.nextEvent) : ""
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width - 12
            x: 6
            height: 1
            color: Config.fg(0.08)
        }

        Sber.CalendarView {
            id: calendarView
            anchors.horizontalCenter: parent.horizontalCenter
            locale: cal.loc
            currentDate: cal.now
            lineHeight: SberCore.Core.Settings.LineHeight
            range: false
            onDateChanged: (dateFrom, dateTo) => cal.selected = dateFrom
        }

        Rectangle {
            width: parent.width - 12
            x: 6
            height: 1
            color: Config.fg(0.08)
            visible: events.eventCount > 0
        }

        Item {
            width: parent.width
            height: 22
            visible: events.eventCount > 0

            Text {
                x: 8
                anchors.verticalCenter: parent.verticalCenter
                color: Config.ink
                font.pixelSize: 13
                text: cal.selected.toLocaleDateString(cal.loc, "dddd, d MMMM")
            }
        }

        Column {
            width: parent.width
            spacing: 2
            visible: events.eventCount > 0

            Text {
                visible: cal.dayEvents.length === 0
                x: 8
                height: 22
                verticalAlignment: Text.AlignVCenter
                color: Config.inkDim
                opacity: 0.7
                font.pixelSize: 12
                text: qsTr("No events")
            }

            Repeater {
                model: cal.dayEvents.slice(0, 5)

                Item {
                    id: eventRow
                    required property var modelData
                    width: parent.width
                    height: 24

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Config.fg(eventHover.hovered ? 0.07 : 0)
                        Behavior on color {
                            ColorAnimation {
                                duration: Config.quick
                            }
                        }
                    }

                    Rectangle {
                        x: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 7
                        height: 7
                        radius: 3.5
                        color: eventRow.modelData.color !== "" ? eventRow.modelData.color : Config.accent
                    }

                    Text {
                        id: eventTime
                        x: 22
                        width: 58
                        anchors.verticalCenter: parent.verticalCenter
                        color: Config.inkDim
                        font.pixelSize: 12
                        font.features: {
                            "tnum": 1
                        }
                        text: cal.timeOf(eventRow.modelData)
                    }

                    Text {
                        x: 84
                        width: parent.width - 92
                        anchors.verticalCenter: parent.verticalCenter
                        color: Config.ink
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        text: eventRow.modelData.summary + (eventRow.modelData.location !== "" ? "  <font color=\"" + Config.hex(Config.inkDim) + "\">" + eventRow.modelData.location.replace(/&/g, "&amp;").replace(/</g, "&lt;") + "</font>" : "")
                        textFormat: Text.StyledText
                    }

                    HoverHandler {
                        id: eventHover
                    }
                }
            }

            Text {
                visible: cal.dayEvents.length > 5
                x: 22
                height: 20
                verticalAlignment: Text.AlignVCenter
                color: Config.inkDim
                font.pixelSize: 12
                text: qsTr("+ %1 more").arg(cal.dayEvents.length - 5)
            }
        }
    }
}
