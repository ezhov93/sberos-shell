import QtQuick
import QtQuick.Layouts

import Sber.Controls as SC
import Sber.Theme as ST
import Sber.Core
import Sber.Utils

Rectangle {
    id: root

    property var appWindow: null
    readonly property int resizeBorderWidth: 2
    property int controls: Settings.Close | Settings.Maximize | Settings.Minimize
    readonly property int radiusValue: getRadiusValue()
    property int buttonsFocusPolicy: appWindow ? appWindow.headerButtonsFocusPolicy : Qt.ClickFocus

    height: 41
    color: ST.Theme.Palette.Outline.Default.SolidSecondaryHover
    radius: radiusValue
    bottomLeftRadius: 0
    bottomRightRadius: 0

    Rectangle {
        id: customHeader

        readonly property int margin: 1

        anchors {
            fill: parent
            margins: margin
            bottomMargin: 0
        }
        color: Core.Settings.IsDarkTheme ? "#25262D" : "#ECEDF4"
        radius: root.radiusValue
        bottomLeftRadius: 0
        bottomRightRadius: 0

        RowLayout {
            id: row

            anchors.fill: parent
            spacing: 0

            MouseArea {
                id: headArea

                Layout.fillWidth: true
                Layout.preferredHeight: 40
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                SC.Label {
                    id: title

                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: appWindow ? appWindow.title : ""
                    width: parent.width
                    font {
                        family: "SB Sans Display"
                        weight: 600
                        pixelSize: 14
                    }
                    elide: Text.ElideRight
                    clip: true
                    color: ST.Theme.Palette.Background.Inverse.Basic
                }

                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        mouse.accepted = true;
                    } else if (mouse.button === Qt.LeftButton && mouse.accepted) {
                        root.appWindow?.startSystemMove();
                    }
                }

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        dbus.set("ShowWindowMenu", [
                            {
                                [TypesProvider.Int]: mouse.x
                            },
                            {
                                [TypesProvider.Int]: mouse.y
                            }
                        ]);
                        mouse.accepted = true;
                    }
                }

                onDoubleClicked: {
                    root.maximizeWindow();
                }
            }

            Component.onCompleted: {
                if (!root.appWindow)
                    return;

                const minBtn = buttonComponent.createObject(row, {
                    "icon.name": "WindowMinimize",
                    "visible": (root.controls & Settings.Minimize) !== 0,
                    "focusPolicy": root.buttonsFocusPolicy
                });
                minBtn.clicked.connect(function () {
                    root.appWindow.visibility = Window.Minimized;
                });
                let maxBtn = buttonComponent.createObject(row, {
                    "icon.name": "WindowMaximizeSimple",
                    "visible": (root.controls & Settings.Maximize) !== 0,
                    "focusPolicy": root.buttonsFocusPolicy
                });
                maxBtn.clicked.connect(function () {
                    root.maximizeWindow();
                });
                root.appWindow.onVisibilityChanged.connect(function () {
                    root.setWindowMaximizeIcon(root.appWindow.visibility, maxBtn);
                });
                const closeBtn = buttonComponent.createObject(row, {
                    "icon.name": "Close",
                    "visible": (root.controls & Settings.Close) !== 0,
                    "focusPolicy": root.buttonsFocusPolicy
                });
                closeBtn.clicked.connect(function () {
                    root.appWindow.close();
                });
            }
        }
    }

    DBusTransmitter {
        id: dbus

        connection: "qt_default_session_bus"
        serviceName: "org.gnome.Shell"
        objectPath: "/org/gnome/Shell"
        interfaceName: "org.gnome.Shell"
    }

    Component {
        id: buttonComponent

        SC.Button {
            Layout.preferredHeight: 40
            Layout.preferredWidth: 30
            cornersType: SC.Widget.Circle
            backgroundType: SC.Widget.Clear
            lineHeight: ST.Theme.Sizes.LineHeight.Xs
        }
    }

    Component {
        id: resizeComponent

        Rectangle {
            id: resizeEdge

            property int edge: Qt.TopEdge
            property bool resizeable: true

            anchors {
                left: edge === Qt.RightEdge ? undefined : parent.left
                right: edge === Qt.LeftEdge ? undefined : parent.right
                top: edge === Qt.BottomEdge ? undefined : parent.top
                bottom: edge === Qt.TopEdge ? undefined : parent.bottom
            }
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                cursorShape: !resizeEdge.resizeable ? Qt.ArrowCursor : (resizeEdge.edge === Qt.TopEdge || resizeEdge.edge === Qt.BottomEdge) ? Qt.SizeVerCursor : Qt.SizeHorCursor
                onPressed: root.appWindow?.startSystemResize(edge)
            }
        }
    }

    Component.onCompleted: {
        if (!root.appWindow)
            return;

        root.appWindow.height += root.height;
        root.appWindow.minimumHeight += root.height;
        root.appWindow.maximumHeight += root.height;

        const vResizeable = root.appWindow.minimumHeight !== root.appWindow.maximumHeight;
        const hResizeable = root.appWindow.minimumWidth !== root.appWindow.maximumWidth;

        resizeComponent.createObject(headArea, {
            "height": root.resizeBorderWidth,
            "resizeable": vResizeable
        });
        resizeComponent.createObject(root.appWindow, {
            "height": root.resizeBorderWidth,
            "edge": Qt.BottomEdge,
            "resizeable": vResizeable
        });
        resizeComponent.createObject(root.appWindow, {
            "width": root.resizeBorderWidth,
            "edge": Qt.LeftEdge,
            "resizeable": hResizeable
        });
        resizeComponent.createObject(root.appWindow, {
            "width": root.resizeBorderWidth,
            "edge": Qt.RightEdge,
            "resizeable": hResizeable
        });
    }

    function maximizeWindow() {
        if (!root.appWindow)
            return;

        if (root.appWindow.visibility === Window.Maximized)
            root.appWindow.visibility = Window.AutomaticVisibility;
        else
            root.appWindow.visibility = Window.Maximized;
    }

    function setWindowMaximizeIcon(wVisibility, btn) {
        if (wVisibility === Window.Maximized)
            btn.icon.name = "WindowMinimizeSimple";
        else
            btn.icon.name = "WindowMaximizeSimple";
    }

    function getRadiusValue() {
        return Core.Settings.LineHeight <= ST.Theme.Sizes.LineHeight.Xxs ? ST.Theme.Sizes.BorderRadius.Xxs : Core.Settings.LineHeight <= ST.Theme.Sizes.LineHeight.Xs ? ST.Theme.Sizes.BorderRadius.Xs : Core.Settings.LineHeight <= ST.Theme.Sizes.LineHeight.S ? ST.Theme.Sizes.BorderRadius.S : Core.Settings.LineHeight <= ST.Theme.Sizes.LineHeight.M ? ST.Theme.Sizes.BorderRadius.M : ST.Theme.Sizes.BorderRadius.L;
    }
}
