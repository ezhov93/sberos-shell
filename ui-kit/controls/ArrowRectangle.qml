import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Shapes
import QtQuick.Templates as T

import Sber.Controls
import Sber.Theme


Item {
    id: control

    enum Edge {
        None   = 0x00000000,
        Left   = 0x00000001,
        Top    = 0x00000002,
        Right  = 0x00000004,
        Bottom = 0x00000010
    }
    enum Position {
        None   = 0x00000000,
        Start  = 0x00010000,
        End    = 0x00020000
    }

    property int arrowSize: 8
    property int arrowPosition: ArrowRectangle.Edge.None | ArrowRectangle.Position.None
    property alias lineHeight: backgroundConfig.lineHeight
    property alias radius: background.radius
    property bool inverse: false
    property alias shadow: shadowBox.visible
    property color color: inverse ? Theme.Palette.Background.Inverse.Secondary :
                                    Theme.Palette.Background.Default.Secondary

    property BackgroundConfig backgroundConfig: BackgroundConfig {
        id: backgroundConfig
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: backgroundConfig.radius
        color: control.color
        border.width: 1.5
        border.color: inverse ? Theme.Palette.Background.Inverse.Basic :
                                Theme.Palette.Background.Default.Basic
    }

    ShadowBox {
        id: shadowBox
        source: background
    }

    Shape {
        id: arrow
        z: 100
        x: control.arrowPosition & ArrowRectangle.Edge.Right     ? -arrowSize :
           control.arrowPosition & ArrowRectangle.Edge.Left      ? control.width :
           control.arrowPosition & ArrowRectangle.Position.Start ? background.radius * 1.5 :
           control.arrowPosition & ArrowRectangle.Position.End   ? control.width - background.radius * 1.5 - arrowSize :
                                                                   (control.width - arrowSize) / 2
        y: control.arrowPosition & ArrowRectangle.Edge.Bottom    ? -arrowSize * 1.5 :
           control.arrowPosition & ArrowRectangle.Edge.Top       ? control.height - arrowSize / 2:
           control.arrowPosition & ArrowRectangle.Position.Start ? background.radius :
           control.arrowPosition & ArrowRectangle.Position.End   ? control.height - background.radius - arrowSize * 2 :
                                                                   control.height / 2- arrowSize
        rotation: control.arrowPosition & ArrowRectangle.Edge.Left  ? 0 :
                  control.arrowPosition & ArrowRectangle.Edge.Top   ? 90 :
                  control.arrowPosition & ArrowRectangle.Edge.Right ? 180 :
                                                                      270

        visible: control.arrowPosition
        width: control.arrowSize
        height: control.arrowSize * 2

        ShapePath {
            fillColor: control.color
            strokeWidth: 0
            strokeColor: "transparent"

            PathArc {
                x: arrow.width
                y: arrow.height / 2
                radiusX: arrow.width
                radiusY: arrow.height
                direction: PathArc.Counterclockwise
            }
            PathArc {
                x: 0
                y: arrow.height
                radiusX: arrow.width
                radiusY: arrow.height
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: 0
                y: 0
            }
        }
    }
}
