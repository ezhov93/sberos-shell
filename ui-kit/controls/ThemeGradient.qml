import QtQuick
import QtQuick.Controls

import Sber.Theme

Gradient {
    id: gradient
    property string source
    property int angle

    property QtObject stopComponent: Component {
        id: stopComponent
        GradientStop {}
    }

    onSourceChanged: updateStops()
    Component.onCompleted: updateStops()
    function updateStops() {
        if (gradient.source) {
            var gradientJson = JSON.parse(gradient.source);
            var colors = gradientJson.colors;
            var locations = gradientJson.locations;
            gradient.angle = gradientJson.angle;

            var new_points = [];
            for (var i = 0; i < locations.length; i++) {
                var point = stopComponent.createObject(gradient);
                point.position = locations[i];
                var color = String(colors[i]);
                if (color.length == 9)
                    color = color[0] + color[7] + color[8] + color.substring(1, 7)
                point.color = color;
                new_points.push(point);
            }
            gradient.stops = new_points;
        }
    }
}


