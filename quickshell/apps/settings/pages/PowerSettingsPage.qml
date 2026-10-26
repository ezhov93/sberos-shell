import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts
import Sber.Controls as Sber
import Sber.Theme
import "../../../shared/qml/i18n"

ColumnLayout {
    id: page
    objectName: "powerSettingsPage"
    required property var colors
    property var backend: null
    readonly property var snapshot: backend ? backend.state : ({})
    readonly property var modes: [
        {
            key: "power-saver",
            title: I18n.tr("Power Saver"),
            detail: I18n.tr("Reduce energy use and extend battery life")
        },
        {
            key: "balanced",
            title: I18n.tr("Balanced"),
            detail: I18n.tr("Balance responsiveness and energy use")
        },
        {
            key: "performance",
            title: I18n.tr("Performance"),
            detail: I18n.tr("Prioritize performance with higher energy use")
        }
    ]
    spacing: 12

    QtControls.ButtonGroup {
        id: powerModeGroup
    }

    Component.onCompleted: {
        if (backend)
            backend.refresh();
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive && page.backend)
                page.backend.refresh();
        }
    }

    Sber.Label {
        text: I18n.tr("Power mode")
        bold: true
        Layout.fillWidth: true
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: page.modes

            delegate: ColumnLayout {
                id: modeRow
                required property var modelData
                required property int index

                readonly property bool supported: (page.snapshot.profiles || []).includes(modelData.key)
                readonly property bool selected: page.snapshot.activeProfile === modelData.key
                objectName: "powerMode-" + modelData.key
                Layout.fillWidth: true
                enabled: supported && !page.snapshot.busy
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 72
                    color: Theme.Palette.Background.Default.Secondary
                    radius: Theme.Sizes.BorderRadius.Xs

                    MouseArea {
                        anchors.fill: parent
                        z: 0
                        enabled: modeRow.enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: page.backend.setProfile(modeRow.modelData.key)
                    }

                    Sber.RadioButton {
                        z: 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        text: modeRow.modelData.title
                        captionText: modeRow.modelData.detail
                        checked: modeRow.selected
                        enabled: modeRow.enabled
                        QtControls.ButtonGroup.group: powerModeGroup
                        onToggled: {
                            if (checked)
                                page.backend.setProfile(modeRow.modelData.key);
                        }
                    }
                }

                Sber.Divider {
                    visible: modeRow.index < page.modes.length - 1
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.Palette.Outline.Default.SolidSecondary
                }
            }
        }
    }

    Sber.Label {
        Layout.fillWidth: true
        text: page.snapshot.busy ? I18n.tr(page.snapshot.pendingProfile ? "Changing power mode…" : "Loading power modes…") : page.snapshot.error ? I18n.tr(page.snapshot.error) : I18n.tr("Only power modes supported by this computer can be selected.")
        wrapMode: Text.Wrap
        secondary: true
        smaller: true
    }

    Sber.Label {
        visible: !!page.snapshot.degraded
        Layout.fillWidth: true
        text: I18n.tr("Performance is limited: %1").arg(page.snapshot.degraded || "")
        wrapMode: Text.Wrap
        secondary: true
        smaller: true
    }
}
