import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import "../lib" as Lib
import org.kde.kitemmodels as KItemModels

import org.kde.plasma.private.brightnesscontrolplugin

Item {
    id: brightnessControl

    Layout.fillHeight: true
    Layout.fillWidth: true

    property var mainScreen
    property bool disableBrightnessUpdate: true

    property bool canTogglePage: false

    // Get brightness control from KDE components
    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }

    Connections {
        id: displayModelConnections
        target: sbControl.displays
        property var screenBrightnessInfo: []

        function update() {
            const [labelRole, brightnessRole, maxBrightnessRole, displayNameRole] = ["label", "brightness", "maxBrightness", "displayName"].map(
                (roleName) => target.KItemModels.KRoleNames.role(roleName));

            screenBrightnessInfo = [...Array(target.rowCount()).keys()].map((i) => { // for each display index
                const modelIndex = target.index(i, 0);
                return {
                    displayName: target.data(modelIndex, displayNameRole),
                    label: target.data(modelIndex, labelRole),
                    brightness: target.data(modelIndex, brightnessRole),
                    maxBrightness: target.data(modelIndex, maxBrightnessRole),
                };
            });
            brightnessControl.mainScreen = screenBrightnessInfo[0];
            sliderLoader.active = screenBrightnessInfo.length > 0;
        }
        function onDataChanged() { update(); }
        function onModelReset() { update(); }
        function onRowsInserted() { update(); }
        function onRowsMoved() { update(); }
        function onRowsRemoved() { update(); }
    }

    visible: root.showBrightness

    Component.onCompleted: displayModelConnections.update()

    Lib.Slider {
        anchors.fill: parent
        visible: !sbControl.isBrightnessAvailable
        enabled: false
        title: qsTr("Дисплей")
        secondaryTitle: qsTr("Недоступно")
        source: Qt.resolvedUrl("../../assets/smart-panel/sun.svg")
        quickSettingsStyle: true
        flat: true
        noMargins: true
    }

    Loader {
        id: sliderLoader
        active: false
        sourceComponent: sliderComponent
        anchors.fill: parent
    }

    Component {
        id: sliderComponent
        Lib.Slider {

            readonly property int brightnessMin: (mainScreen.maxBrightness > 100 ? 1 : 0)

            // Slider properties
            title: qsTr("Дисплей")
            quickSettingsStyle: true
            noMargins: true
            source: Qt.resolvedUrl("../../assets/smart-panel/sun.svg")
            secondaryTitle: Math.round((mainScreen.brightness / mainScreen.maxBrightness)*100) + "%"

            canTogglePage: brightnessControl.canTogglePage

            showTitle: root.brightness_widget_title
            thinSlider: root.brightness_widget_thin
            flat: quickSettingsStyle ? true : root.brightness_widget_flat // bind to Lib.Card property

            from: 0
            to: mainScreen.maxBrightness
            value: mainScreen.brightness

            onMoved: {
                sbControl.setBrightness(mainScreen.displayName, Math.max(brightnessMin, Math.min(mainScreen.maxBrightness, value))) ;
            }

            onTogglePage: {
                var pageHeight = brightnessControlPage.contentItemHeight + brightnessControlPage.headerHeight;
                fullRep.togglePage(fullRep.defaultInitialWidth, pageHeight, brightnessControlPage);
            }
        }
    }
}
