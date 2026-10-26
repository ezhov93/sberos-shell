import QtQuick
import qs.desktop.modules.bar
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../../shared/qml/i18n"

ControlCenterCard {
    id: slotCard7
    objectName: "control-center-soundcard"
    required property var service
    property real volumePreview: 0
    signal pageRequested(string page)
    signal volumePreviewRequested(real value)
    signal draggingVolumeRequested(bool value)
    ThemeText {
        anchors {
            left: parent.left
            top: parent.top
            topMargin: 0
        }
        text: I18n.tr("Sound")
        color: ThemeService.foregroundColor
        font {
            pixelSize: 14
            weight: Font.Medium
            family: "Noto Sans CJK SC"
        }
    }
    Canvas {
        id: volumeGlyph
        anchors {
            left: parent.left
            leftMargin: 8
            verticalCenter: volumeSlider.verticalCenter
        }
        width: 16
        height: 16
        renderTarget: Canvas.Image

        readonly property int volumeLevel: Math.round(slotCard7.volumePreview)
        readonly property bool isMuted: slotCard7.service.audioMuted
        readonly property color ink: AppearanceTokens.content.shellInk()

        onVolumeLevelChanged: requestPaint()
        onIsMutedChanged: requestPaint()
        onInkChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const fg = ink;
            const bodyColor = isMuted ? Qt.rgba(fg.r, fg.g, fg.b, 0.50) : fg;

            ctx.fillStyle = bodyColor;
            ctx.strokeStyle = fg;
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";

            ctx.fillRect(1.0, 5.5, 3.2, 5.0);

            ctx.beginPath();
            ctx.moveTo(4.2, 5.5);
            ctx.lineTo(7.5, 2.5);
            ctx.lineTo(7.5, 13.5);
            ctx.lineTo(4.2, 10.5);
            ctx.closePath();
            ctx.fill();

            if (isMuted) {
                ctx.globalCompositeOperation = "destination-out";
                ctx.lineWidth = 2.6;
                ctx.beginPath();
                ctx.moveTo(0.8, 2.0);
                ctx.lineTo(8.8, 14.0);
                ctx.stroke();

                ctx.globalCompositeOperation = "source-over";
                ctx.lineWidth = 1.5;
                ctx.strokeStyle = fg;
                ctx.beginPath();
                ctx.moveTo(0.8, 2.0);
                ctx.lineTo(8.8, 14.0);
                ctx.stroke();
            } else {
                const arcs = volumeLevel > 66 ? 3 : (volumeLevel > 33 ? 2 : (volumeLevel > 0 ? 1 : 0));
                const cx = 6.0, cy = 8.0;
                if (arcs >= 1) {
                    ctx.beginPath();
                    ctx.arc(cx, cy, 4.2, -0.65, 0.65);
                    ctx.stroke();
                }
                if (arcs >= 2) {
                    ctx.beginPath();
                    ctx.arc(cx, cy, 7.0, -0.70, 0.70);
                    ctx.stroke();
                }
                if (arcs >= 3) {
                    ctx.beginPath();
                    ctx.arc(cx, cy, 9.8, -0.72, 0.72);
                    ctx.stroke();
                }
            }
        }

        Connections {
            target: slotCard7.service
            function onAudioMutedChanged() {
                volumeGlyph.requestPaint();
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: slotCard7.service.setMuted(!slotCard7.service.audioMuted)
        }
    }
    ControlCenterSlider {
        id: volumeSlider
        objectName: "volumeSlider"
        accessibleName: I18n.tr("Volume")
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 48
            rightMargin: 0
            bottomMargin: 0
        }
        value: slotCard7.volumePreview / 100
        onPreviewChanged: function (v) {
            slotCard7.draggingVolumeRequested(true);
            slotCard7.volumePreviewRequested(Math.round(v * 100));
        }
        onCanceled: {
            slotCard7.draggingVolumeRequested(false);
            slotCard7.volumePreviewRequested(slotCard7.service.volumePercent);
        }
        onCommitRequested: function (v) {
            slotCard7.draggingVolumeRequested(false);
            slotCard7.service.setVolume(Math.round(v * 100));
        }
    }
}
