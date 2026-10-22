import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

import Sber.Controls
import Sber.Core
import Sber.Theme

T.ApplicationWindow {
    id: root

    property int controls: Settings.Close | Settings.Maximize | Settings.Minimize
    property color backgroundColor: Theme.Palette.Background.Default.Primary
    property int backgroundRadius: root.getBackgroundRadius();
    property int headerButtonsFocusPolicy: Qt.ClickFocus

    visible: true
    color: "transparent"

    ColumnLayout {
        id: layout
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        width: layout.implicitWidth
        z: 1000

        Component {
            id: notification
            Notification {}
        }
        Connections {
            target: Core.Notifier
            function onNewNotify(notice) {
                var n = notification.createObject(layout);
                n.title = notice.title;
                n.text = notice.text;
                n.icon.name = notice.iconName;
                n.icon.source = notice.iconPath;
                n.closable = notice.closable;
                n.timeout = notice.timeout;
            }
        }
    }

    Component {
        id: headerComponent

        ApplicationHeader {
            id: header

            appWindow: root
        }
    }

    Component {
        id: backgroundComponent

        Rectangle {
            property int lineHeight: Core.Settings.LineHeight

            color: root.backgroundColor
            radius: root.backgroundRadius
            border {
                width: 1
                color: Theme.Palette.Outline.Default.SolidSecondaryHover
            }
        }
    }

    Component.onCompleted: {
        const isCustomHeader = (root.flags & Qt.CustomizeWindowHint) !== 0;

        if (isCustomHeader && !root.header) {
            const newHeader = headerComponent.createObject(root, {"controls": root.controls});
            if (newHeader) {
                root.header = newHeader;
            }
        }

        if (!root.background) {
            const bg = backgroundComponent.createObject(root);
            if (bg)
                root.background = bg;
        }
    }

    function getBackgroundRadius() {
        const lineHeight = Core.Settings.LineHeight;
        return lineHeight <= Theme.Sizes.LineHeight.Xxs ? Theme.Sizes.BorderRadius.Xxs :
               lineHeight <= Theme.Sizes.LineHeight.Xs  ? Theme.Sizes.BorderRadius.Xs :
               lineHeight <= Theme.Sizes.LineHeight.S   ? Theme.Sizes.BorderRadius.S :
               lineHeight <= Theme.Sizes.LineHeight.M   ? Theme.Sizes.BorderRadius.M :
               Theme.Sizes.BorderRadius.L
    }
}
