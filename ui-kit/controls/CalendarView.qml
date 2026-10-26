import QtQuick
import QtQuick.Controls

import Sber.Controls
import Sber.Core
import Sber.Theme

Rectangle {
    id: root

    enum SelectType {
        Date,
        Month,
        Year
    }
    property int selectType: CalendarView.SelectType.Date
    state: selectType

    property alias lineHeight: backgroundConfig.lineHeight
    property int spacing: lineHeight <= Theme.Sizes.LineHeight.Xs ? 6 : 8
    color: Theme.Palette.Background.Default.Secondary
    radius: backgroundConfig.radius

    property var locale: Qt.locale()
    property var dateFrom
    property var dateTo
    property var dateMin: new Date(currentDate.getFullYear() - 100, currentDate.getMonth(), currentDate.getDate())
    property var dateMax: new Date(currentDate.getFullYear() + 100, currentDate.getMonth(), currentDate.getDate())
    property var currentDate: new Date()
    property int visibleYear: currentDate.getFullYear()
    property int visibleMonth: currentDate.getMonth()
    property bool inSelect: false
    property int padding: 16

    signal dateChanged(var dateFrom, var dateTo)

    property bool doubled: false
    property bool range: false
    property bool headerVisible: true

    clip: true

    implicitWidth: (doubled ? contentLeft.width * 2 + divider.width + padding * 2 : contentLeft.width) + padding * 2
    width: implicitWidth
    implicitHeight: (headerVisible ? header.height + padding * 1.5 : 0) + contentLeft.height
    height: implicitHeight

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
        lineHeight: Core.Settings.LineHeight
    }

    property int cellWidth: lineHeight <= Theme.Sizes.LineHeight.Xs ? 40 : lineHeight <= Theme.Sizes.LineHeight.S ? 40 : lineHeight <= Theme.Sizes.LineHeight.M ? 48 : 56
    property int cellHeight: lineHeight <= Theme.Sizes.LineHeight.Xs ? 30 : lineHeight <= Theme.Sizes.LineHeight.S ? 32 : lineHeight <= Theme.Sizes.LineHeight.M ? 40 : 48

    property Component dateViewLeft: DateView {
        id: dateViewLeft
        control: root
    }
    property Component monthViewLeft: MonthView {
        control: root
        anchors.fill: parent
        lineHeight: root.lineHeight
    }
    property Component yearViewLeft: YearView {
        control: root
        anchors.fill: parent
        lineHeight: root.backgroundConfig.lineHeight
    }
    property Component dateViewRight: DateView {
        control: root
        incrementMonth: true
    }
    property Component monthViewRight: MonthView {
        control: root
        anchors.fill: parent
        lineHeight: root.lineHeight
        incrementYear: true
    }
    property Component yearViewRight: YearView {
        control: root
        anchors.fill: parent
        lineHeight: root.lineHeight
        incrementDecade: true
    }

    Item {
        id: header
        x: root.padding
        y: root.padding / 2
        width: parent.width - root.padding * 2
        height: root.cellWidth
        visible: headerVisible

        Button {
            id: decrementButton
            x: doubled ? 0 : parent.width - width * 2
            width: parent.height
            height: parent.height
            backgroundType: Widget.Clear
            iconItem.name: "ChevronLeft"
            enabled: root.visibleYear > currentDate.getFullYear() - 100
            onClicked: {
                header.decrement();
            }
        }

        Button {
            id: headerButtonLeft
            x: doubled ? contentLeft.x + (contentLeft.width - width - iconItem.size) / 2 : root.padding
            horizontalPadding: 0
            height: parent.height
            backgroundType: Widget.Clear

            textItem.font: Theme.Fonts.BodyLB
            textItem.spacing: 0
            textItem.iconOnRight: true
            iconItem.name: "DisclosureDownFill"
            iconItem.size: 24
            onClicked: {
                root.nextState();
            }
        }
        Button {
            id: headerButtonRight
            x: contentRight.x + (contentRight.width - width - iconItem.size) / 2
            horizontalPadding: 0
            height: parent.height
            backgroundType: Widget.Clear
            visible: root.doubled

            textItem.font: Theme.Fonts.BodyLB
            textItem.spacing: 0
            textItem.iconOnRight: true
            iconItem.name: "DisclosureDownFill"
            iconItem.size: 24
            onClicked: {
                root.nextState();
            }
        }
        Button {
            id: incrementButton
            x: parent.width - width
            width: parent.height
            height: parent.height
            backgroundType: Widget.Clear
            iconItem.name: "ChevronRight"
            enabled: root.visibleYear < currentDate.getFullYear() + 100
            onClicked: {
                header.increment();
            }
        }

        function getLabelText(isRight) {
            if (root.state == CalendarView.SelectType.Date) {
                var dates = isRight ? contentRight.item : contentLeft.item;
                return CalendarFunctions.getMonthName(dates.month, root.locale) + " " + dates.year;
            } else if (root.state == CalendarView.SelectType.Month) {
                var months = isRight ? contentRight.item : contentLeft.item;
                return months.year;
            }
            var years = isRight ? contentRight.item : contentLeft.item;
            return years.startYear + "-" + years.endYear;
        }

        function increment() {
            if (root.state == CalendarView.SelectType.Date) {
                var newMonth = root.visibleMonth + 1;
                if (newMonth > 11) {
                    newMonth = 0;
                    root.visibleYear++;
                }
                root.visibleMonth = newMonth;
            } else if (root.state == CalendarView.SelectType.Month) {
                root.visibleYear++;
            } else {
                root.visibleYear += 12;
            }
            headerButtonLeft.text = header.getLabelText(false);
        }

        function decrement() {
            if (root.state == CalendarView.SelectType.Date) {
                var newMonth = root.visibleMonth - 1;
                if (newMonth < 0) {
                    newMonth = 11;
                    root.visibleYear--;
                }
                root.visibleMonth = newMonth;
            } else if (root.state == CalendarView.SelectType.Month) {
                root.visibleYear--;
            } else {
                root.visibleYear -= 12;
            }
            headerButtonLeft.text = header.getLabelText(false);
        }
    }

    function loadView() {
        switch (Number(root.state)) {
        case CalendarView.SelectType.Month:
            contentLeft.sourceComponent = monthViewLeft;
            contentRight.sourceComponent = monthViewRight;
            break;
        case CalendarView.SelectType.Year:
            contentLeft.sourceComponent = yearViewLeft;
            contentRight.sourceComponent = yearViewRight;
            break;
        default:
            contentLeft.sourceComponent = dateViewLeft;
            contentRight.sourceComponent = dateViewRight;
            break;
        }

        headerButtonLeft.text = header.getLabelText(false);
        headerButtonRight.text = header.getLabelText(true);
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            Qt.callLater(root.loadView);
        });
    }

    onStateChanged: {
        if (contentLeft.item)
            loadView();
    }

    Loader {
        id: contentLeft
        x: root.padding
        y: root.headerVisible ? header.y + header.height : root.padding
        width: root.cellWidth * 7
        height: root.cellHeight * 7
    }

    Divider {
        id: divider
        x: contentLeft.x + contentLeft.width + root.padding
        vertical: true
        visible: root.doubled
    }

    Loader {
        id: contentRight
        x: divider.x + divider.width + root.padding
        y: contentLeft.y
        visible: root.doubled
        width: root.cellWidth * 7
        height: root.cellHeight * 7
    }

    function setDate(date, finish = false) {
        if (root.range) {
            if (root.inSelect) {
                if (finish)
                    root.inSelect = false;
                root.dateTo = date;
            } else if (finish) {
                if (!root.dateFrom) {
                    root.dateFrom = date;
                } else {
                    if (root.dateTo) {
                        root.dateFrom = date;
                        root.dateTo = undefined;
                    } else {
                        root.dateTo = date;
                    }
                }
                root.inSelect = true;
            }
            if (finish && CalendarFunctions.isValid(root.dateFrom) && CalendarFunctions.isValid(root.dateTo)) {
                if (root.dateFrom > root.dateTo) {
                    var t = root.dateFrom;
                    root.dateFrom = root.dateTo;
                    root.dateTo = t;
                }
                dateChanged(root.dateFrom, root.dateTo);
            }
        } else if (finish) {
            root.dateFrom = date;
            dateChanged(root.dateFrom, root.dateFrom);
        }
    }

    function setMonth(year, month) {
        if (root.selectType == CalendarView.SelectType.Month) {
            setDate(new Date(year, month), true);
        } else {
            root.visibleMonth = month;
            root.visibleYear = year;
        }
        root.prevState();
    }

    function setYear(year) {
        if (root.selectType == CalendarView.SelectType.Year) {
            setDate(new Date(year, 0), true);
        } else {
            root.visibleYear = year;
        }
        root.prevState();
    }

    function prevState() {
        root.state = Math.max(root.state - 1, root.selectType);
    }
    function nextState() {
        root.state = Math.min(root.state + 1, CalendarView.SelectType.Year);
    }
}
