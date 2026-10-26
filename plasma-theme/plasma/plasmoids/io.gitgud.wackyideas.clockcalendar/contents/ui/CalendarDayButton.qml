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
               ? (dayButton.darkMode ? "#f5f6f7" : "#30343a")
               : dayButton.hovered
                 ? (dayButton.darkMode ? "#30ffffff" : "#18000000")
                 : "transparent"
    }

    contentItem: Text {
        text: dayButton.dayNumber
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 15
        color: dayButton.today
               ? (dayButton.darkMode ? "#252a30" : "#ffffff")
               : dayButton.outsideMonth
                 ? (dayButton.darkMode ? "#56616c" : "#b6bec7")
                 : (dayButton.darkMode ? "#edf0f2" : "#30343a")
    }
}
