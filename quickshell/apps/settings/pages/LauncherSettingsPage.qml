import QtQuick
import QtQuick.Layouts
import "../../../shared/qml/i18n"
import Sber.Controls as Sber
import Sber.Theme
import "../components" as Controls

ColumnLayout {
    id: launcherPage
    required property var colors

    Layout.fillWidth: true
    spacing: 7
    property var bridge: null
    property string displayMode: "fullscreen"
    readonly property var displayModes: ["fullscreen"]
    property int displayModeIndex: 0
    property string iconSize: "medium"
    property string density: "compact"
    property string fontWeight: "normal"
    readonly property var iconSizes: ["small", "medium", "large"]
    readonly property var densities: ["compact", "balanced", "spacious"]
    property int iconSizeIndex: 1
    property int densityIndex: 0
    readonly property var fontWeights: ["normal", "medium", "bold"]
    property int fontWeightIndex: 0
    property string errorText: ""

    ListModel {
        id: iconSizeOptions
    }
    ListModel {
        id: densityOptions
    }
    ListModel {
        id: fontWeightOptions
    }

    function populateOptions(model, options) {
        for (let i = 0; i < options.length; ++i)
            model.append(options[i]);
    }

    function applySnapshot(snapshot) {
        if (!snapshot)
            return;
        if (snapshot.displayMode !== undefined) {
            displayMode = snapshot.displayMode;
            const idx = displayModes.indexOf(displayMode);
            displayModeIndex = idx >= 0 ? idx : 0;
        }
        const profiles = snapshot.layoutProfiles;
        const profile = profiles && profiles[displayMode] ? profiles[displayMode] : null;
        if (!profile)
            return;
        iconSize = iconSizes.indexOf(profile.iconSize) >= 0 ? profile.iconSize : "medium";
        density = densities.indexOf(profile.density) >= 0 ? profile.density : "balanced";
        fontWeight = fontWeights.indexOf(profile.fontWeight) >= 0 ? profile.fontWeight : "normal";
        iconSizeIndex = iconSizes.indexOf(iconSize);
        densityIndex = densities.indexOf(density);
        fontWeightIndex = fontWeights.indexOf(fontWeight);
    }

    function reloadFromBridge() {
        if (!bridge)
            return;
        bridge.launcherSnapshot();
    }

    // The picker rows keep the optimistic local update they had; the
    // authoritative snapshot arrives on launcherSnapshotChanged below.
    function saveFontWeight(index) {
        fontWeightIndex = index;
        fontWeight = fontWeights[index] || "normal";
        if (bridge)
            bridge.updateLauncherProfileFontWeight(displayMode, fontWeight);
    }

    function saveIconSize(index) {
        iconSizeIndex = index;
        iconSize = iconSizes[index] || "medium";
        if (bridge)
            bridge.updateLauncherProfileIconSize(displayMode, iconSize);
    }

    function saveDensity(index) {
        densityIndex = index;
        density = densities[index] || "balanced";
        if (bridge)
            bridge.updateLauncherProfileDensity(displayMode, density);
    }

    function resetCurrentProfile() {
        if (!bridge)
            return;
        bridge.resetLauncherLayoutProfile(displayMode);
    }

    Connections {
        target: launcherPage.bridge
        enabled: launcherPage.bridge !== null
        function onLauncherSnapshotChanged(snap) {
            launcherPage.applySnapshot(snap);
            if (launcherPage.bridge.lastError)
                launcherPage.errorText = I18n.tr(launcherPage.bridge.lastError);
        }
    }

    Component.onCompleted: {
        populateOptions(iconSizeOptions, [
            {
                text: I18n.tr("Small"),
                value: "small"
            },
            {
                text: I18n.tr("Medium"),
                value: "medium"
            },
            {
                text: I18n.tr("Large"),
                value: "large"
            }
        ]);
        populateOptions(densityOptions, [
            {
                text: I18n.tr("Compact"),
                value: "compact"
            },
            {
                text: I18n.tr("Standard"),
                value: "balanced"
            },
            {
                text: I18n.tr("Comfortable"),
                value: "spacious"
            }
        ]);
        populateOptions(fontWeightOptions, [
            {
                text: I18n.tr("General"),
                value: "normal"
            },
            {
                text: I18n.tr("Medium black"),
                value: "medium"
            },
            {
                text: I18n.tr("Bold"),
                value: "bold"
            }
        ]);
        reloadFromBridge();
    }

    Sber.Label {
        text: I18n.tr("Grid, icons and text").toUpperCase()
        secondary: true
        bold: true
        smaller: true
        Layout.leftMargin: 13
        Layout.topMargin: 14
    }

    Rectangle {
        Layout.fillWidth: true
        color: Theme.Palette.Background.Default.Secondary
        radius: Theme.Sizes.BorderRadius.S
        implicitHeight: 221

        Column {
            anchors.fill: parent

            Item {
                width: parent.width
                height: 54
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Controls.SettingIcon {
                        colors: launcherPage.colors
                        symbol: "◉"
                        tint: "#ff9500"
                    }
                    Sber.Label {
                        text: I18n.tr("Icon Size")
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Sber.ComboBox {
                        model: iconSizeOptions
                        textRole: "text"
                        valueRole: "value"
                        lineHeight: Theme.Sizes.LineHeight.Xs
                        currentIndex: launcherPage.iconSizeIndex
                        onActivated: function (index) {
                            launcherPage.saveIconSize(index);
                        }
                    }
                }
            }

            Sber.Divider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 53
                height: 1
                color: Theme.Palette.Outline.Default.SolidSecondary
            }

            Item {
                width: parent.width
                height: 54
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Controls.SettingIcon {
                        colors: launcherPage.colors
                        symbol: "↔"
                        tint: "#5ac8fa"
                    }
                    Sber.Label {
                        text: I18n.tr("Grid density")
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Sber.ComboBox {
                        model: densityOptions
                        textRole: "text"
                        valueRole: "value"
                        lineHeight: Theme.Sizes.LineHeight.Xs
                        currentIndex: launcherPage.densityIndex
                        onActivated: function (index) {
                            launcherPage.saveDensity(index);
                        }
                    }
                }
            }

            Sber.Divider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 53
                height: 1
                color: Theme.Palette.Outline.Default.SolidSecondary
            }

            Item {
                width: parent.width
                height: 54
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Controls.SettingIcon {
                        colors: launcherPage.colors
                        symbol: "B"
                        tint: "#ff9500"
                    }
                    Sber.Label {
                        text: I18n.tr("Font weight")
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Sber.ComboBox {
                        model: fontWeightOptions
                        textRole: "text"
                        valueRole: "value"
                        lineHeight: Theme.Sizes.LineHeight.Xs
                        currentIndex: launcherPage.fontWeightIndex
                        onActivated: function (index) {
                            launcherPage.saveFontWeight(index);
                        }
                    }
                }
            }

            Sber.Divider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 53
                height: 1
                color: Theme.Palette.Outline.Default.SolidSecondary
            }

            Item {
                width: parent.width
                height: 54
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    Controls.SettingIcon {
                        colors: launcherPage.colors
                        symbol: "↺"
                        tint: "#8e8e93"
                    }
                    Sber.Label {
                        text: I18n.tr("Restore recommended layout")
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Sber.Label {
                        text: I18n.tr("Current shape only")
                        secondary: true
                        smaller: true
                    }
                    Sber.Button {
                        text: I18n.tr("Restore")
                        type: Sber.Widget.Secondary
                        backgroundType: Sber.Widget.Outline
                        lineHeight: Theme.Sizes.LineHeight.Xs
                        onClicked: launcherPage.resetCurrentProfile()
                    }
                }
            }
        }
    }

    Sber.Label {
        Layout.fillWidth: true
        Layout.leftMargin: 13
        Layout.rightMargin: 13
        visible: launcherPage.errorText.length > 0
        text: launcherPage.errorText
        color: Theme.Palette.Surface.Default.Negative
        wrapMode: Text.Wrap
    }
}
