import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.0

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents

import "lib" as Lib
import "components" as Components
import "pages" as Pages
import "js/funcs.js" as Funcs


FocusScope {
    id: fullRep
    focus: true

    // PROPERTIES
    Layout.preferredWidth: root.fullRepWidth
    Layout.preferredHeight: wrapper.implicitHeight
    Layout.minimumWidth: Layout.preferredWidth
    Layout.maximumWidth: Layout.preferredWidth
    Layout.minimumHeight: Layout.preferredHeight
    Layout.maximumHeight: Layout.preferredHeight
    clip: true

    property var layouts : [
        "layouts/Default.qml",
        "layouts/ControlCenter.qml",
        "layouts/Flat.qml",
    ]

    property int defaultInitialWidth: root.fullRepWidth
    property int defaultInitialHeight: wrapper.implicitHeight

    property int newWidth: 0
    property int newHeight: 0

    property var activePage: wrapper

    // System session actions page
    Pages.SystemSessionActionsPage {
        id: systemSessionActionsPage
    }

    // Night Light Page
    Pages.NightLightPage {
        id: nightLightPage
    }

    // Volume devices Page
    Pages.VolumePage {
        id: volumePage
    }

    // Battery devices Page
    Pages.BatteryPage {
        id: batteryPage
    }

    // Media player Page
    Pages.MediaPlayerPage {
        id: mediaPlayerPage
    }

    // Brightness control Page
    Pages.BrightnessControlPage {
        id: brightnessControlPage
    }

    // Bluetooth control Page
    Pages.BluetoothPage {
        id: bluetoothPage
    }

    // Network control Page
    Pages.NetworkPage {
        id: networkPage
    }

    Loader {
        id: wrapper
        source: fullRep.layouts[plasmoid.configuration.layout]
        active: true
        asynchronous: true
        anchors.fill: parent
        visible: true
        property bool shown: true
        states: [
            State {
                name: "show"; when: wrapper.shown
                PropertyChanges { target: wrapper; opacity: 1 }
                PropertyChanges { target: wrapper; visible: true }
            },

            State {
                name: "hide"; when: !wrapper.shown
                PropertyChanges { target: wrapper; opacity: 0 }
                PropertyChanges { target: wrapper; visible: false }
            }
        ]

        transitions: Transition {
            PropertyAnimation { target: wrapper; property: "opacity"; easing.type: Easing.InOutQuad; duration: 20 }
        }
    }

    function resetPage() {
        if (activePage !== wrapper) activePage.shown = false;
        activePage = wrapper;
        wrapper.shown = true;
        Layout.preferredWidth = root.fullRepWidth;
        Layout.preferredHeight = wrapper.implicitHeight;
    }
    function togglePage(width = root.fullRepWidth, height = wrapper.implicitHeight, page = wrapper) {
        if (activePage !== wrapper || page === wrapper) {
            resetPage();
            return;
        }
        wrapper.shown = false;
        activePage = page;
        page.shown = true;
        Layout.preferredWidth = width;
        Layout.preferredHeight = height;
    }
    Keys.onEscapePressed: event => {
        if (activePage !== wrapper) resetPage();
        else root.expanded = false;
        event.accepted = true;
    }
    Connections {
        target: root
        function onExpandedChanged() { if (!root.expanded) fullRep.resetPage(); }
    }
}
