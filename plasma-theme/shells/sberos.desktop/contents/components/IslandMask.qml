/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import org.kde.ksvg as KSvg
import org.kde.plasma.plasma5support as Plasma5Support

KSvg.FrameSvgItem {
    id: maskItem
    property var rects: []
    readonly property string geometryKey: JSON.stringify({width: width, height: height, rects: rects})
    property string inFlight: ""
    property string completedGeometry: ""
    visible: false
    enabledBorders: KSvg.FrameSvg.NoBorder
    onGeometryKeyChanged: updateTimer.restart()
    function quote(value) { return "'" + String(value).replace(/'/g, "'\\''") + "'"; }
    function updateMask() {
        if (inFlight.length || width <= 0 || height <= 0 || !rects.length || geometryKey === completedGeometry) return;
        completedGeometry = geometryKey;
        const script = decodeURIComponent(Qt.resolvedUrl("../tools/panel-mask.py").toString().replace(/^file:\/\//, ""));
        inFlight = "python3 " + quote(script) + " " + quote(geometryKey);
        writer.connectSource(inFlight);
    }
    Timer { id: updateTimer; interval: 60; onTriggered: maskItem.updateMask() }
    Plasma5Support.DataSource {
        id: writer
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            maskItem.inFlight = "";
            if (data["exit code"] === 0) {
                const result = JSON.parse(data.stdout);
                maskItem.imagePath = result.path;
            } else console.warn("SberOS panel mask:", data.stderr);
            if (maskItem.completedGeometry !== maskItem.geometryKey) updateTimer.restart();
        }
    }
    Component.onCompleted: updateTimer.start()
}
