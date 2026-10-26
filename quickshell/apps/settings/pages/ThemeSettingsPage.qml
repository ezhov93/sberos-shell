import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../shared/qml/i18n"
import "../components" as Controls

ColumnLayout {
    id: themePage

    required property var colors
    property var bridge: null
    property string language: "auto"
    property string errorText: ""

    Layout.fillWidth: true
    spacing: 10

    function isValidLanguage(value) {
        return value === "auto" || value === "zh-CN" || value === "en";
    }

    function setLanguage(value) {
        if (!bridge || !isValidLanguage(value)) {
            errorText = bridge ? I18n.tr("Unknown language") : I18n.tr("The Settings bridge has not been built");
            return;
        }
        bridge.updateLanguage(value);
    }

    Connections {
        target: themePage.bridge
        enabled: themePage.bridge !== null
        function onI18nSnapshotChanged(state) {
            if (!state || state.language === undefined || state.language === "")
                return;
            themePage.language = String(state.language);
            I18n.language = themePage.language === "auto" ? I18n.systemDefault() : themePage.language;
        }
    }

    Component.onCompleted: {
        if (bridge)
            bridge.i18nSnapshot();
    }

    Text {
        text: I18n.tr("Appearance mode").toUpperCase()
        color: themePage.colors.secondaryText
        font.pixelSize: 12
        font.weight: Font.DemiBold
        Layout.leftMargin: 13
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 58
        radius: 18
        color: themePage.colors.card

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Controls.SettingIcon {
                colors: themePage.colors
                symbol: "◐"
                tint: "#5ac8fa"
            }

            Text {
                text: I18n.tr("Appearance mode")
                color: themePage.colors.primaryText
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Item {
                Layout.fillWidth: true
            }

            Controls.SettingsNavBar {
                colors: themePage.colors
                model: [
                    {
                        id: "light",
                        label: I18n.tr("Light")
                    },
                    {
                        id: "dark",
                        label: I18n.tr("Dark")
                    }
                ]
                currentIndex: themePage.colors.dark ? 1 : 0
                onSelectionChanged: function (index) {
                    if (themePage.bridge)
                        themePage.bridge.applySystemAppearance(index === 1);
                }
            }
        }
    }

    IconAppearanceSection {
        colors: themePage.colors
        bridge: themePage.bridge
    }

    Text {
        text: I18n.tr("Language").toUpperCase()
        color: themePage.colors.secondaryText
        font.pixelSize: 12
        font.weight: Font.DemiBold
        Layout.leftMargin: 13
        Layout.topMargin: 8
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 64
        radius: 18
        color: themePage.colors.card

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Controls.SettingIcon {
                colors: themePage.colors
                symbol: "文"
                tint: "#0a84ff"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: I18n.tr("Language")
                    color: themePage.colors.primaryText
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
                Text {
                    text: I18n.tr("Switch the interface language; applies live.")
                    color: themePage.colors.secondaryText
                    font.pixelSize: 11
                }
            }

            Controls.SettingsNavBar {
                colors: themePage.colors
                Layout.preferredHeight: 30
                itemWidthOverride: 72
                model: [
                    {
                        id: "auto",
                        label: I18n.tr("Follow system")
                    },
                    {
                        id: "zh-CN",
                        label: "简体中文"
                    },
                    {
                        id: "en",
                        label: "English"
                    }
                ]
                currentIndex: themePage.language === "auto" ? 0 : themePage.language === "en" ? 2 : 1
                onSelectionChanged: function (index) {
                    themePage.setLanguage(index === 0 ? "auto" : index === 2 ? "en" : "zh-CN");
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: themePage.errorText.length > 0
        text: themePage.errorText
        color: "#ff453a"
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }

    Item {
        Layout.fillHeight: true
    }
}
