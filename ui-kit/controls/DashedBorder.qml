import QtQuick
import QtQuick.Shapes

import Sber.Controls
import Sber.Theme

Shape {
    id: dashedBorder
    property alias lineWidth: path.strokeWidth
    property alias color: path.strokeColor
    property int radius: 0
    property alias dashPattern: path.dashPattern

    ShapePath {
        id: path
        fillColor: "transparent"
        strokeStyle: ShapePath.DashLine
        strokeColor: Theme.Palette.Outline.Default.SolidSecondary
        dashPattern: [1, 3]
        capStyle: ShapePath.RoundCap

        startX: dashedBorder.radius
        startY: 0

        PathLine {
            x: dashedBorder.width - dashedBorder.radius
            y: 0
        }
        PathArc {
            x: dashedBorder.width
            y: dashedBorder.radius
            radiusX: dashedBorder.radius
            radiusY: dashedBorder.radius
        }

        PathLine {
            x: dashedBorder.width
            y: dashedBorder.height - dashedBorder.radius
        }
        PathArc {
            x: dashedBorder.width - dashedBorder.radius
            y: dashedBorder.height
            radiusX: dashedBorder.radius
            radiusY: dashedBorder.radius
        }

        PathLine {
            x: dashedBorder.radius
            y: dashedBorder.height
        }
        PathArc {
            x: 0
            y: dashedBorder.height - dashedBorder.radius
            radiusX: dashedBorder.radius
            radiusY: dashedBorder.radius
        }

        PathLine {
            x: 0
            y: dashedBorder.radius
        }
        PathArc {
            x: dashedBorder.radius
            y: 0
            radiusX: dashedBorder.radius
            radiusY: dashedBorder.radius
        }
    }
}
