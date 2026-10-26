/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls.Basic

Button {
    id: dayButton

    required property int dayNumber
    required property bool outsideMonth
    property bool selected: false
    property bool past: false
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme { dark: dayButton.darkMode }
    required property bool today
    required property string dateLabel
    required property bool darkMode

    implicitWidth: 40
    implicitHeight: 40
    padding: 0
    Accessible.name: dateLabel
    Accessible.role: Accessible.Button

    background: Rectangle {
        radius: 12
        color: dayButton.today
               ? (dayButton.darkMode ? "#e8eaf0" : "#33353e")
               : dayButton.hovered
                 ? smartTheme.hover
                 : "transparent"
        border.width: dayButton.visualFocus || (dayButton.selected && !dayButton.today) ? 2 : 0
        border.color: smartTheme.focus
    }

    contentItem: Text {
        text: dayButton.dayNumber
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        color: dayButton.today
               ? (dayButton.darkMode ? "#31343c" : "#ffffff")
               : dayButton.outsideMonth || dayButton.past
                 ? (dayButton.darkMode ? smartTheme.muted : "#c8ccd5")
                 : smartTheme.foreground
    }
}
