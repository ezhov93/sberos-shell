import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Sber.Controls
import Sber.Theme


TextField {
    id: control

    property var model
    property string textRole: "text"
    property string valueRole: "value"
    property string captionRole: "caption"
    property bool tight: false
    property int currentIndex: -1

    opacity: enabled ? 1 : 0.4

    onTextEdited: {
        currentIndex = -1;
        popup.toggle(true);
    }
    onAccepted: {
        control.focus = false;
        popup.close();
        currentIndex = loader.item.currentIndex;
        var cur = loader.item.itemAtIndex(loader.item.currentIndex);
        if (cur)
            control.text = cur.text;
    }
    onActiveFocusChanged: {
        if (activeFocus && model.rowCount() > 0)
            popup.toggle(!(text == "" || text.match("^[0-9 ]+$")));
        else if (!loader.focus)
            popup.close();
    }
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
            popup.toggle(true);
            loader.item.Keys.pressed(event);
        }
    }

    Icon {
        id: indicator
        x: control.width - width - (control.iconRight.visible ?
               control.rightPadding :
               control.backgroundConfig.horizontalPadding / 2)
        y: control.background.y + (control.background.height - height) / 2
        size: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 16 : 24
        color: control.hovered ? Theme.Palette.Text.Default.Primary : Theme.Palette.Text.Default.Secondary
        name: popup.opened ? "ChevronUp" : "ChevronDown"

        MouseArea {
            parent: control
            y: control.background.y
            height: control.background.height
            anchors.right: parent.right
            width: control.width - indicator.x
            onClicked: popup.toggle()
        }
    }

    property Component loadComponent: ListView {
        id: listView
        currentIndex: -1
        implicitHeight: contentHeight
        clip: true
        keyNavigationEnabled: true
        keyNavigationWraps: true
        ScrollBar.vertical: ScrollBar {
            width: 4
        }

        model: control.model
        delegate: MenuItem {
            id: listItem
            lineHeight: control.lineHeight
            text: control.textRole ?
                      (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) :
                      modelData
            property var value: control.valueRole ?
                                    (Array.isArray(control.model) ?
                                         modelData[control.valueRole] ? modelData[control.valueRole] : "" :
                                         model[control.valueRole] ? model[control.valueRole] : "") :
                                    ""
            captionText: control.captionRole ? model[control.captionRole] : ""
            tight: control.tight
            indicator.visible: true
            highlighted: index === control.currentIndex

            property bool active: true
            visible: active
            height: visible ? implicitHeight : 0

            onTriggered: {
                listView.currentIndex = index;
                control.accepted();
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                event.accepted = true;

                var incr = event.key === Qt.Key_Up ? -1 : 1;
                for (var i = 1; i < model.rowCount(); i++) {
                    var cur = listView.currentIndex + incr * i;
                    if (cur === -1)
                        cur = model.rowCount() - 1;
                    if (cur >= model.rowCount())
                        cur = 0;
                    var item = itemAtIndex(cur);
                    if (item && item.active) {
                        listView.currentIndex = cur;
                        break;
                    }
                }
            }
        }
    }

    Popup {
        id: popup
        y: control.background.y + control.background.height
        width: control.width
        radius: control.background.radius
        focus: control.activeFocus ? false : true

        contentItem: Loader {
            id: loader
            anchors.fill: parent
            anchors.margins: parent.padding
            focus: true
        }

        property real timestamp: 0

        function hasVisibleItems() {
            var count = 0;
            for (var i = 0; i < model.rowCount(); i++) {
                var item = loader.item.itemAtIndex(i);
                if (item) {
                    item.active = control.text == "" || item.text.indexOf(control.text) === 0
                    if (item.active)
                        count++;
                }
            }
            return count != 0;
        }

        function toggle(open = !popup.opened) {
            if (!open || open && loader.sourceComponent == loadComponent && !hasVisibleItems()) {
                popup.close();
            } else if (open && !popup.opened) {
                if(loader.sourceComponent != loadComponent)
                    loader.sourceComponent = loadComponent;
                popup.open();
            }
        }

    }
}
