import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../components" as Components

Item {
    id: wrapper

    implicitWidth: 488 * root.scale
    implicitHeight: 540 * root.scale
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true

    readonly property color panelColor: root.smartTheme.shell
    readonly property color innerColor: root.smartTheme.inner
    readonly property color panelEdge: root.smartTheme.edge

    Rectangle {
        anchors.fill: parent
        radius: 24 * root.scale
        color: wrapper.panelColor
        border.width: 1
        border.color: wrapper.panelEdge
    }

    Item {
        width: 0
        height: 0

        Components.NetworkBtn {
            id: wifiAction
            visible: false
        }
        Components.BluetoothBtn {
            id: bluetoothAction
            visible: false
        }
        Components.ColorSchemeSwitcher {
            id: colorSchemeAction
            visible: false
        }
        Components.NightLight {
            id: nightLightAction
            visible: false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15 * root.scale
        anchors.leftMargin: 16 * root.scale
        anchors.rightMargin: 16 * root.scale
        anchors.topMargin: 16 * root.scale
        anchors.bottomMargin: 20 * root.scale
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56 * root.scale
            spacing: 0

            Item {
                Layout.preferredWidth: 104 * root.scale
                Layout.preferredHeight: 56 * root.scale
                visible: batteryWidget.visible

                Rectangle {
                    anchors.fill: parent
                    radius: 16 * root.scale
                    color: wrapper.innerColor
                    border.width: 1
                    border.color: wrapper.panelEdge
                }

                Components.Battery {
                    id: batteryWidget
                    anchors.fill: parent
                    flat: true
                    noMargins: true
                }
            }

            Item { Layout.fillWidth: true }

            Item {
                Layout.preferredWidth: 56 * root.scale
                Layout.preferredHeight: 56 * root.scale

                Rectangle {
                    anchors.fill: parent
                    radius: 16 * root.scale
                    color: wrapper.innerColor
                    border.width: 1
                    border.color: wrapper.panelEdge
                }

                Components.ScreenshotBtn {
                    anchors.fill: parent
                    mini: true
                    visible: true
                    flat: true
                    noMargins: true
                    title: ""
                }
            }
        }

        Item { Layout.preferredHeight: 24 * root.scale }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16 * root.scale

            Components.Volume {
                Layout.fillWidth: true
                Layout.preferredHeight: 68 * root.scale
                title: qsTr("Звук")
            }

            Components.BrightnessSlider {
                Layout.fillWidth: true
                Layout.preferredHeight: 68 * root.scale
            }
        }

        Item { Layout.preferredHeight: 24 * root.scale }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            columnSpacing: 8 * root.scale
            rowSpacing: 8 * root.scale

            Components.QuickSettingsTile {
                title: qsTr("Wi‑Fi")
                subtitle: !wifiAction.wifiCheckVisible ? qsTr("Недоступно") : !wifiAction.wifiCheckChecked ? qsTr("Выкл.") : wifiAction.network.networkStatus.activeConnections ? qsTr("Подключено") : qsTr("Не подключено")
                iconName: Qt.resolvedUrl("../../assets/smart-panel/wifi.svg")
                active: wifiAction.wifiCheckChecked
                available: wifiAction.wifiCheckVisible
                hasSubpage: true
                onActivated: wifiAction.clicked()
            }

            Components.QuickSettingsTile {
                title: qsTr("VPN")
                subtitle: qsTr("Недоступно")
                iconName: Qt.resolvedUrl("../../assets/smart-panel/vpn.svg")
                available: false
                actionable: false
                hasSubpage: true
            }

            Components.QuickSettingsTile {
                title: qsTr("Bluetooth")
                available: bluetoothAction.btManager.adapters.length > 0
                subtitle: bluetoothAction.btManager.bluetoothOperational
                    ? bluetoothAction.btManager.connectedDevices.length > 0 ? bluetoothAction.title : qsTr("Не подключено")
                    : qsTr("Выкл.")
                iconName: Qt.resolvedUrl("../../assets/smart-panel/bluetooth.svg")
                active: bluetoothAction.btManager.bluetoothOperational
                hasSubpage: true
                onActivated: bluetoothAction.clicked()
            }

            Components.QuickSettingsTile {
                title: qsTr("Режим питания")
                subtitle: batteryWidget.activeProfileLabel
                iconName: Qt.resolvedUrl("../../assets/smart-panel/battery.svg")
                available: batteryWidget.profileAvailable
                hasSubpage: true
                onActivated: fullRep.togglePage(344 * root.scale, 400 * root.scale, batteryPage)
            }

            Components.QuickSettingsTile {
                title: qsTr("Уведомления")
                subtitle: root.notificationsForcedOff ? qsTr("Управляется приложением")
                    : root.notificationsEnabled ? qsTr("Вкл.") : qsTr("Выкл.")
                iconName: Qt.resolvedUrl(root.notificationsEnabled
                    ? "../../assets/smart-panel/bell.svg" : "../../assets/smart-panel/bellOff.svg")
                active: root.notificationsEnabled
                available: !root.notificationsForcedOff
                onActivated: root.toggleNotifications()
            }

            Components.QuickSettingsTile {
                title: qsTr("Ночной свет")
                subtitle: nightLightAction.control && nightLightAction.control.available
                    ? nightLightAction.control.running ? qsTr("Вкл.") : qsTr("Выкл.")
                    : qsTr("Недоступно")
                iconName: Qt.resolvedUrl("../../assets/smart-panel/night.svg")
                active: Boolean(nightLightAction.control && nightLightAction.control.available && nightLightAction.control.running)
                available: Boolean(nightLightAction.control && nightLightAction.control.available)
                hasSubpage: true
                onActivated: nightLightAction.clicked()
            }

            Components.QuickSettingsTile {
                title: qsTr("Авиарежим")
                subtitle: wifiAction.airplaneCheckVisible
                    ? wifiAction.airplaneCheckchecked ? qsTr("Вкл.") : qsTr("Выкл.")
                    : qsTr("Недоступно")
                iconName: Qt.resolvedUrl("../../assets/smart-panel/plane.svg")
                active: wifiAction.airplaneCheckchecked
                available: wifiAction.airplaneCheckVisible
                onActivated: wifiAction.network.handler.enableAirplaneMode(!wifiAction.airplaneCheckchecked)
            }

            Components.QuickSettingsTile {
                title: qsTr("Тёмный стиль")
                subtitle: root.isDarkTheme ? qsTr("Вкл.") : qsTr("Выкл.")
                iconName: Qt.resolvedUrl("../../assets/smart-panel/moon.svg")
                active: root.isDarkTheme
                onActivated: colorSchemeAction.clicked()
            }
        }
    }
}
