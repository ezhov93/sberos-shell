import QtQuick
import QtQuick.Controls
import Quickshell
import qs.desktop.modules.common
import "../../../shared/qml/i18n"

AnimatedPopupWindow {
    id: popup

    property Item anchorItem: null
    property bool barHosted: false
    property date viewedDate: new Date()
    readonly property date currentDate: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function toggle(sourceItem) {
        if (effectiveOpen && anchorItem === sourceItem) {
            hide();
            sourceItem.forceActiveFocus();
            return;
        }
        anchorItem = sourceItem;
        viewedDate = currentDate;
        show();
    }

    requestedOpen: anchorItem !== null && _requestedOpen
    property bool _requestedOpen: false
    onVisibleChanged: if (!visible && _requestedOpen)
        _requestedOpen = false
    function show() {
        _requestedOpen = true;
    }
    function hide() {
        _requestedOpen = false;
    }

    implicitWidth: 344
    implicitHeight: 382
    color: "transparent"
    grabFocus: true

    PopupAnchorBinding {
        popupAnchor: popup.anchor
        sourceItem: popup.anchorItem
    }
    anchor {
        edges: popup.barHosted ? Edges.Bottom : Edges.Top
        gravity: popup.barHosted ? Edges.Bottom : Edges.Top
        adjustment: PopupAdjustment.Slide
        margins.bottom: popup.barHosted ? -8 : 0
        margins.top: popup.barHosted ? 0 : -8
    }

    FrostedSurface {
        anchors.fill: parent
        radius: 24
    }

    FocusScope {
        id: content
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: {
            popup.hide();
            popup.anchorItem?.forceActiveFocus();
        }

        ThemeText {
            x: 16
            y: 14
            width: parent.width - 32
            text: I18n.fmt(popup.currentDate, I18n.tr("dddd, d MMMM"))
            font.pixelSize: 14
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Row {
            id: monthHeader
            anchors.top: parent.top
            anchors.topMargin: 44
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            ThemeText {
                width: 32
                height: 32
                text: "‹"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 24
                TapHandler {
                    onTapped: popup.viewedDate = new Date(popup.viewedDate.getFullYear(), popup.viewedDate.getMonth() - 1, 1)
                }
            }

            ThemeText {
                width: 174
                height: 32
                text: I18n.fmt(popup.viewedDate, I18n.tr("MMMM yyyy"))
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            ThemeText {
                width: 32
                height: 32
                text: "›"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 24
                TapHandler {
                    onTapped: popup.viewedDate = new Date(popup.viewedDate.getFullYear(), popup.viewedDate.getMonth() + 1, 1)
                }
            }
        }

        Row {
            id: weekdayLabels
            anchors.top: monthHeader.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Repeater {
                model: 7
                delegate: ThemeText {
                    required property int index
                    width: 40
                    height: 26
                    readonly property int weekday: ((Qt.locale().firstDayOfWeek - 1 + index) % 7) + 1
                    text: I18n.fmt(new Date(2024, 0, weekday), I18n.tr("ddd"))
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: AppearanceTokens.colors.surfaceVariantForeground
                    font.pixelSize: 11
                }
            }
        }

        MonthGrid {
            id: monthGrid
            anchors.top: weekdayLabels.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            width: 280
            height: 240
            month: popup.viewedDate.getMonth()
            year: popup.viewedDate.getFullYear()
            locale: Qt.locale()
            delegate: Item {
                required property var model
                implicitWidth: 40
                implicitHeight: 40

                Rectangle {
                    anchors.centerIn: parent
                    width: 32
                    height: 32
                    radius: 10
                    color: model.today && model.inMonth ? AppearanceTokens.colors.primary : "transparent"
                }

                ThemeText {
                    anchors.fill: parent
                    text: model.day
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: !model.inMonth ? AppearanceTokens.colors.surfaceVariantForeground : model.today ? AppearanceTokens.colors.primaryForeground : AppearanceTokens.colors.surfaceForeground
                    opacity: model.inMonth ? 1 : 0.52
                    font.pixelSize: 13
                }
            }
        }
    }
}
