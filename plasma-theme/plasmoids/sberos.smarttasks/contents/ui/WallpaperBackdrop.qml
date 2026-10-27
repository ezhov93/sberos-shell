/* SPDX-License-Identifier: GPL-2.0-or-later */
import QtQuick
import QtQuick.Effects

Item {
    id: backdrop
    property Item wallpaperItem: null
    property bool active: false
    property var wallpaperGrab: null
    property url capturedSource: ""
    readonly property Item imageView: wallpaperItem
        ? wallpaperItem.children.find(child => child.modelImage !== undefined) ?? null : null
    readonly property url imageSource: imageView?.modelImage ?? ""
    readonly property bool useSnapshot: !imageSource.toString().length || imageSource.toString().indexOf("image://") === 0
    property bool captureRunning: false
    property bool capturePending: false
    property int captureGeneration: 0
    property var prepared: null
    function finishPreparation() {
        preparationTimer.stop();
        const callback = prepared;
        prepared = null;
        if (callback) callback();
    }
    function prepare(callback) {
        if (!useSnapshot || !wallpaperItem) { callback(); return; }
        prepared = callback;
        preparationTimer.start();
        captureWallpaper();
    }
    Timer { id: preparationTimer; interval: 250; onTriggered: backdrop.finishPreparation() }
    clip: true

    function captureWallpaper() {
        if (captureRunning) {
            capturePending = true;
            return;
        }
        if (!wallpaperItem || !useSnapshot) return;
        const source = wallpaperItem;
        const generation = captureGeneration;
        capturePending = false;
        captureRunning = true;
        const started = source.grabToImage(result => {
            backdrop.captureRunning = false;
            const captureIsCurrent = backdrop.wallpaperItem === source
                && backdrop.captureGeneration === generation;
            if (captureIsCurrent) {
                backdrop.wallpaperGrab = result;
                backdrop.capturedSource = result.url;
            }
            const shouldCaptureAgain = backdrop.capturePending || !captureIsCurrent;
            backdrop.capturePending = false;
            if (shouldCaptureAgain && backdrop.active) {
                Qt.callLater(backdrop.captureWallpaper);
                return;
            }
            backdrop.finishPreparation();
        });
        if (!started) { captureRunning = false; finishPreparation(); }
    }
    onActiveChanged: if (active && !capturedSource.toString().length) Qt.callLater(captureWallpaper)
    onImageSourceChanged: {
        captureGeneration++;
        if (active) refreshTimer.restart();
    }
    Timer { id: refreshTimer; interval: 120; onTriggered: backdrop.captureWallpaper() }
    Connections { target: backdrop.imageView; ignoreUnknownSignals: true; function onCurrentItemChanged() { if (backdrop.active) refreshTimer.restart(); } }
    onWallpaperItemChanged: {
        captureGeneration++;
        wallpaperGrab = null;
        capturedSource = "";
        if (active) Qt.callLater(captureWallpaper);
    }
    Timer {
        interval: 1000
        repeat: true
        running: backdrop.active && backdrop.useSnapshot && !backdrop.imageView
        triggeredOnStart: true
        onTriggered: backdrop.captureWallpaper()
    }
    Rectangle {
        anchors.fill: parent
        color: backdrop.wallpaperItem?.configuration?.Color ?? "#20292b"
    }
    Image {
        id: artwork
        anchors.fill: parent
        source: backdrop.active ? (backdrop.useSnapshot ? backdrop.capturedSource : backdrop.imageSource) : ""
        sourceSize: Qt.size(width, height)
        fillMode: backdrop.imageView?.fillMode ?? Image.PreserveAspectCrop
        asynchronous: true
        retainWhileLoading: true
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        source: artwork
        blurEnabled: true
        blurMax: 32
        blur: .8
        saturation: -.4
        autoPaddingEnabled: false
    }
    Rectangle { anchors.fill: parent; color: "#73000000" }
}
