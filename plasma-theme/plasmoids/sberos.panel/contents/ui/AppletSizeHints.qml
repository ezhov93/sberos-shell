/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts

QtObject {
    required property Item applet
    required property bool horizontal
    required property real thickness

    readonly property real implicitLength: horizontal ? applet.implicitWidth : applet.implicitHeight
    readonly property real requestedMinimum: horizontal ? applet.Layout.minimumWidth : applet.Layout.minimumHeight
    readonly property real requestedPreferred: horizontal ? applet.Layout.preferredWidth : applet.Layout.preferredHeight
    readonly property real requestedMaximum: horizontal ? applet.Layout.maximumWidth : applet.Layout.maximumHeight
    readonly property bool fill: horizontal ? applet.Layout.fillWidth : applet.Layout.fillHeight
    readonly property real minimum: Math.max(0, requestedMinimum)
    readonly property real preferred: Math.max(minimum, Math.min(maximum,
        requestedPreferred >= 0 ? requestedPreferred : (implicitLength > 0 ? implicitLength : thickness)))
    readonly property real maximum: requestedMaximum >= 0 ? Math.max(minimum, requestedMaximum) : Infinity
}
