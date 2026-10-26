import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme

T.BusyIndicator {
    id: control
    visible: true

    property alias loadingPercent: canvas.loadingPercent
    property alias indicatorWidth: canvas.lineWidth
    property color color: Theme.Palette.Text.Default.Primary

    property int lineHeight: 16
    width: lineHeight
    height: lineHeight

    contentItem: Rectangle {
        id: bg
        width: control.lineHeight
        height: control.lineHeight
        anchors.centerIn: parent
        color: "transparent"

        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true

            property int loadingPercent: 0
            property int lineWidth: 1
            property color color: control.color
            property real angle: loadingPercent / 100 * 2 * Math.PI
            property real angleOffset: -Math.PI / 2

            onLoadingPercentChanged: {
                rotation = 0;
                requestPaint();
            }
            onColorChanged: requestPaint()
            onAngleChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.save();
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                ctx.lineWidth = control.indicatorWidth;
                var radius = control.lineHeight / 2.0;
                var borderRadius = radius - control.indicatorWidth / 2.0;
                var roundDelta = Math.asin(control.indicatorWidth / 4.0 / radius) * 2.0;

                if (control.loadingPercent != 0) {
                    ctx.beginPath();
                    ctx.strokeStyle = Theme.Palette.Surface.Default.SolidSecondary;
                    ctx.arc(radius, radius, radius - control.indicatorWidth / 2.0, 0, 2 * Math.PI);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.strokeStyle = control.color;
                    ctx.lineCap = "round";
                    ctx.arc(radius, radius, borderRadius, angleOffset, angleOffset + angle);
                    ctx.stroke();
                } else {
                    ctx.beginPath();
                    var grad = ctx.createConicalGradient(radius, radius, -angleOffset);
                    grad.addColorStop(0, control.color);
                    grad.addColorStop(1, "transparent");
                    ctx.strokeStyle = grad;
                    ctx.lineCap = "round";
                    ctx.arc(radius, radius, borderRadius, angleOffset + roundDelta, angleOffset + 2 * Math.PI - roundDelta);
                    ctx.stroke();
                }
                ctx.restore();
            }

            NumberAnimation on rotation {
                from: 0
                to: 360
                running: control.visible && control.loadingPercent == 0
                loops: Animation.Infinite
                duration: 900
            }
            Behavior on loadingPercent {
                PropertyAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuint
                }
            }
        }
    }
}
