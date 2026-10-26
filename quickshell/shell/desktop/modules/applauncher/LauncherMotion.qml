import QtQuick

// Tile Animator jobs keep the spread effect while the stationary surface fades.
Item {
    id: motion
    required property Item target
    parent: target.parent
    property bool requestedOpen: false
    property bool mapped: false
    property bool settledOpen: false
    readonly property bool interactive: requestedOpen && settledOpen
    property real surfaceOpacity: 0
    property int pendingIcons: 0
    property bool changing: false
    property bool surfaceFinished: false

    function prepare() {
        changing = true;
        surfaceFade.stop();
        surfaceFinished = false;
        settledOpen = false;
    }

    function open() {
        prepare();
        mapped = true;
        requestedOpen = true;
        startSurfaceFade(1, 100, Easing.OutCubic);
        changing = false;
        finishIfSettled();
    }

    function close() {
        prepare();
        requestedOpen = false;
        if (mapped)
            startSurfaceFade(0, 200, Easing.OutCubic);
        else
            surfaceFinished = true;
        changing = false;
        finishIfSettled();
    }

    function startSurfaceFade(value, duration, curve) {
        surfaceFade.from = surfaceOpacity;
        surfaceFade.to = value;
        surfaceFade.duration = duration;
        surfaceFade.easing.type = curve;
        surfaceFade.start();
    }

    function iconStarted() {
        pendingIcons += 1;
    }
    function iconFinished() {
        pendingIcons = Math.max(0, pendingIcons - 1);
        finishIfSettled();
    }
    function finishIfSettled() {
        if (changing || !surfaceFinished || pendingIcons !== 0)
            return;
        settledOpen = requestedOpen;
        if (!requestedOpen)
            mapped = false;
    }

    property NumberAnimation surfaceFade: NumberAnimation {
        target: motion
        property: "surfaceOpacity"
        onFinished: {
            motion.surfaceFinished = true;
            motion.finishIfSettled();
        }
    }
}
