/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    readonly property var locale: Qt.locale()
    readonly property bool darkMode: Kirigami.Theme.textColor.hsvValue > Kirigami.Theme.backgroundColor.hsvValue
    property date currentDate: new Date()
    property date viewedMonth: new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
    readonly property string clockLabel: titleCase(locale.toString(currentDate, "ddd, d MMM · HH:mm"))

    preferredRepresentation: compactRepresentation
    Plasmoid.title: qsTr("Часы и календарь")
    Plasmoid.icon: "view-calendar"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real panelExtent: Math.max(1, vertical ? width : height)
    readonly property real labelSize: panelExtent * 2 / 9
    readonly property real labelWidth: Math.ceil(clockMetrics.width + panelExtent / 3)
    Layout.minimumWidth: vertical ? 0 : Math.min(labelWidth, panelExtent * 2)
    Layout.preferredWidth: vertical ? 72 : labelWidth
    Layout.maximumWidth: vertical ? Infinity : labelWidth
    Layout.minimumHeight: vertical ? panelExtent : 0
    Layout.preferredHeight: vertical ? panelExtent : 72
    Layout.maximumHeight: vertical ? panelExtent : Infinity

    TextMetrics {
        id: clockMetrics
        font.family: Kirigami.Theme.defaultFont.family
        font.pixelSize: root.labelSize
        text: root.clockLabel
    }

    function toggleCalendar() {
        if (!root.expanded) {
            viewedMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
        }
        root.expanded = !root.expanded
    }

    function titleCase(value) {
        return value.length ? value.charAt(0).toLocaleUpperCase() + value.slice(1) : value
    }

    onExpandedChanged: {
        if (expanded) {
            viewedMonth = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
        }
    }

    Timer {
        interval: 15000
        repeat: true
        running: true
        onTriggered: root.currentDate = new Date()
    }

    compactRepresentation: Button {
        id: clockButton

        implicitWidth: root.labelWidth
        implicitHeight: 72
        Accessible.name: Qt.locale().toString(root.currentDate, "dddd, d MMMM, HH:mm")
        Accessible.description: qsTr("Открыть календарь")
        onClicked: root.toggleCalendar()

        padding: 0
        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: root.panelExtent * 8 / 72
                anchors.bottomMargin: root.panelExtent * 8 / 72
                anchors.rightMargin: root.panelExtent * 8 / 72
                radius: 10
                color: clockButton.down ? smartTheme.pressed : clockButton.hovered || root.expanded ? smartTheme.hover : "transparent"
                border.width: clockButton.visualFocus ? 2 : 0
                border.color: smartTheme.focus
            }
        }

        contentItem: RowLayout {
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.clockLabel
                color: smartTheme.foreground
                font.pixelSize: root.labelSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    fullRepresentation: CalendarPopup {
        id: calendarPopup
        SmartPopupPlacement {
            content: calendarPopup
            anchorItem: root.compactRepresentationItem ?? root
            screenGeometry: Plasmoid.containment.screenGeometry
            alignment: "right"
        }
        currentDate: root.currentDate
        viewedMonth: root.viewedMonth
        darkMode: root.darkMode
        onCloseRequested: root.expanded = false
        onMonthChangeRequested: month => root.viewedMonth = month
    }
}
