import QtQuick
import QtQuick.Effects
import qs.desktop.modules.bar
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../../shared/qml/i18n"

ControlCenterCard {
    id: root
    required property var service
    objectName: "control-center-powermodecard"

    readonly property string profileLabel: {
        if (service.activeProfile === "performance") return I18n.tr("Performance");
        if (service.activeProfile === "power-saver") return I18n.tr("Power saver");
        if (service.activeProfile === "balanced") return I18n.tr("Balanced");
        return service.loading ? I18n.tr("Loading…") : I18n.tr("Unavailable");
    }

    ControlCenterSelection {
        pointer: pointer
        cornerRadius: root.cardRadius
        selected: root.service.activeProfile === "performance"
    }
    Rectangle {
        x: 12
        width: 32
        height: 32
        radius: 16
        anchors.verticalCenter: parent.verticalCenter
        color: root.service.activeProfile === "performance" ? AppearanceTokens.colors.primary : AppearanceTokens.colors.surfaceContainerHigh
    }
    Image {
        anchors {
            left: parent.left
            leftMargin: 19
            verticalCenter: parent.verticalCenter
        }
        width: 18
        height: 18
        source: BundledIcons.source("power")
        sourceSize.width: 48
        sourceSize.height: 48
        fillMode: Image.PreserveAspectFit
        smooth: true
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.service.activeProfile === "performance" ? "#ffffff" : ThemeService.foregroundColor
        }
    }
    Column {
        anchors {
            left: parent.left
            leftMargin: 56
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        spacing: 1
        ThemeText {
            width: parent.width
            text: I18n.tr("Performance mode")
            elide: Text.ElideRight
            color: AppearanceTokens.colors.surfaceForeground
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
        ThemeText {
            width: parent.width
            text: root.service.changing ? I18n.tr("Changing…") : root.profileLabel
            elide: Text.ElideRight
            color: AppearanceTokens.colors.surfaceVariantForeground
            font.pixelSize: 11
        }
    }
    Accessible.role: Accessible.Button
    Accessible.name: I18n.tr("Performance mode") + ", " + root.profileLabel
    Accessible.description: root.service.error
    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.service.profiles.includes(root.service.activeProfile === "performance" ? "balanced" : "performance") && !root.service.loading && !root.service.changing
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            const targetProfile = root.service.activeProfile === "performance" ? "balanced" : "performance";
            if (root.service.profiles.includes(targetProfile))
                root.service.setProfile(targetProfile);
        }
    }
    Component.onCompleted: root.service.refresh()
}
