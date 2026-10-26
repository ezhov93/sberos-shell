/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import org.kde.kirigami as Kirigami

// Render supplied SVG files directly; KIconLoader may substitute theme icons
// with the same basename. Tint variants are generated from the original paths.
Item {
    id: icon
    property var source
    property color color: "#484c5b"
    property bool isMask: false
    readonly property string sourceName: String(source || "")
    readonly property bool fileArtwork: /\.svg$/.test(sourceName)
    readonly property string tint: color.toString().replace("#", "")
    implicitWidth: 24
    implicitHeight: 24
    Accessible.ignored: true
    Image {
        anchors.fill: parent
        source: icon.isMask ? icon.sourceName.replace(/\.svg$/, "-" + icon.tint + ".svg") : icon.sourceName
        sourceSize: Qt.size(icon.width, icon.height)
        fillMode: Image.PreserveAspectFit
        visible: icon.fileArtwork
    }
    Kirigami.Icon {
        anchors.fill: parent
        visible: !icon.fileArtwork
        source: icon.source
        color: icon.color
    }
}
