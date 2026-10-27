/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtQuick.Effects

Item {
    id: avatar
    implicitWidth: 40
    implicitHeight: 40
    Accessible.ignored: true
    Image {
        id: artwork
        anchors.fill: parent
        source: Qt.resolvedUrl("../assets/oska-avatar.svg")
        sourceSize: Qt.size(avatar.width, avatar.height)
        visible: false
    }
    Rectangle {
        id: crop
        anchors.fill: parent
        radius: width / 2
        color: "white"
        visible: false
        layer.enabled: true
        layer.smooth: true
    }
    MultiEffect {
        anchors.fill: parent
        source: artwork
        maskEnabled: true
        maskSource: crop
    }
}
