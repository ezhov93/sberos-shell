/* SPDX-License-Identifier: GPL-2.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: mask
    required property var sizes
    property var childRect: []
    readonly property string geometryKey: JSON.stringify({sizes: sizes, child: childRect})
    property url source: ""
    property string completed: ""
    property string inFlight: ""
    readonly property bool ready: source.toString().length > 0 && completed === geometryKey
    visible: false

    function quote(value) { return "'" + String(value).replace(/'/g, "'\\''") + "'"; }
    function generate() {
        if (inFlight.length || completed === geometryKey || sizes.some(value => value <= 0)) return;
        const script = decodeURIComponent(Qt.resolvedUrl("../code/reveal-mask.py").toString().replace(/^file:\/\//, ""));
        inFlight = geometryKey;
        writer.connectSource("python3 " + quote(script) + " " + quote(inFlight));
    }
    onGeometryKeyChanged: update.restart()
    Component.onCompleted: update.start()
    Timer { id: update; interval: 0; onTriggered: mask.generate() }
    Plasma5Support.DataSource {
        id: writer
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName);
            const requested = mask.inFlight;
            mask.inFlight = "";
            if (data["exit code"] === 0) {
                mask.source = "file://" + JSON.parse(data.stdout).path;
                mask.completed = requested;
            } else console.warn("SberOS applications mask:", data.stderr);
            if (requested !== mask.geometryKey) update.restart();
        }
    }
}
