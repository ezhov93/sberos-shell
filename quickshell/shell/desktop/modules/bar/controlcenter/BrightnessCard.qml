import QtQuick
import qs.desktop.modules.bar
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../../shared/qml/i18n"

ControlCenterCard {
    id: slotCard6
    objectName: "control-center-brightnesscard"
    required property var service
    property real brightnessPreview: 0
    signal pageRequested(string page)
    signal brightnessPreviewRequested(real value)
    signal draggingBrightnessRequested(bool value)
    Row {
        anchors {
            left: parent.left
            top: parent.top
            topMargin: 0
        }
        spacing: 4
        ThemeText {
            text: I18n.tr("Display")
            color: ThemeService.foregroundColor
            font {
                pixelSize: 14
                weight: Font.Medium
                family: "Noto Sans CJK SC"
            }
        }
    }
    ControlCenterSlider {
        id: brightnessSlider
        objectName: "brightnessSlider"
        accessibleName: I18n.tr("Brightness")
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 48
            rightMargin: 0
            bottomMargin: 0
        }
        value: slotCard6.brightnessPreview / 100
        enabled: slotCard6.service.brightnessAvailable
        onPreviewChanged: function (v) {
            slotCard6.draggingBrightnessRequested(true);
            slotCard6.brightnessPreviewRequested(Math.round(v * 100));
        }
        onCanceled: {
            slotCard6.draggingBrightnessRequested(false);
            slotCard6.brightnessPreviewRequested(slotCard6.service.brightnessPercent);
        }
        onCommitRequested: function (v) {
            slotCard6.draggingBrightnessRequested(false);
            slotCard6.service.setBrightness(Math.round(v * 100));
        }
    }
    Canvas {
        anchors {
            left: parent.left
            leftMargin: 8
            verticalCenter: brightnessSlider.verticalCenter
        }
        width: 16
        height: 16
        readonly property color ink: AppearanceTokens.content.shellInk()
        onInkChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = ink;
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(8, 8, 2.7, 0, Math.PI * 2);
            ctx.stroke();
            const rays = [[8, 0.5, 8, 2.3], [8, 13.7, 8, 15.5], [0.5, 8, 2.3, 8], [13.7, 8, 15.5, 8], [2.7, 2.7, 4, 4], [12, 12, 13.3, 13.3], [2.7, 13.3, 4, 12], [12, 4, 13.3, 2.7]];
            for (const ray of rays) {
                ctx.beginPath();
                ctx.moveTo(ray[0], ray[1]);
                ctx.lineTo(ray[2], ray[3]);
                ctx.stroke();
            }
        }
        Connections {
            target: ThemeService
            function onIsDarkChanged() {
                parent.requestPaint();
            }
        }
    }
}
