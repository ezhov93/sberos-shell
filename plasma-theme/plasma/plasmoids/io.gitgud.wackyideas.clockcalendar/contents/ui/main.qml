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

    readonly property var locale: Qt.locale()
    readonly property bool darkMode: Kirigami.Theme.textColor.hsvValue > Kirigami.Theme.backgroundColor.hsvValue
    property date currentDate: new Date()
    property date viewedMonth: new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
    readonly property string clockLabel: titleCase(locale.toString(currentDate, "ddd, d MMM · HH:mm"))
    property alias clockControl: clockButton

    preferredRepresentation: compactRepresentation
    Plasmoid.title: qsTr("Часы и календарь")
    Plasmoid.icon: "view-calendar"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Layout.minimumWidth: 236
    Layout.preferredWidth: 236
    Layout.maximumWidth: 236
    Layout.minimumHeight: 72
    Layout.preferredHeight: 72
    Layout.maximumHeight: 72

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
        } else if (root.clockControl) {
            root.clockControl.forceActiveFocus()
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

        implicitWidth: 236
        implicitHeight: 72
        Accessible.name: Qt.locale().toString(root.currentDate, "dddd, d MMMM, HH:mm")
        Accessible.description: qsTr("Открыть календарь")
        onClicked: root.toggleCalendar()

        background: Rectangle {
            radius: 22
            color: root.darkMode ? "#e622272d" : "#e8f7fbf8"
            border.width: 1
            border.color: root.darkMode ? "#35ffffff" : "#caffffff"
        }

        contentItem: RowLayout {
            spacing: 12

            Kirigami.Icon {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                source: "view-calendar"
                color: root.darkMode ? "#e7ebee" : "#424a51"
            }

            Text {
                Layout.fillWidth: true
                text: root.clockLabel
                color: root.darkMode ? "#e7ebee" : "#424a51"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }

    fullRepresentation: CalendarPopup {
        currentDate: root.currentDate
        viewedMonth: root.viewedMonth
        darkMode: root.darkMode
        onCloseRequested: root.expanded = false
        onMonthChangeRequested: month => root.viewedMonth = month
    }
}
