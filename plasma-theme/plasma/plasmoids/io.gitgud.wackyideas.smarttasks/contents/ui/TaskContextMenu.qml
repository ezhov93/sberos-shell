pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

FocusScope {
    id: root

    property string appName
    property var actions: []
    property int selectedActionIndex: 0
    signal triggered(string action)
    signal dismissed

    implicitWidth: 248
    implicitHeight: 56 + actions.reduce((height, item) => height + (item.separator ? 9 : 40), 0)
    focus: true
    Component.onCompleted: root.forceActiveFocus()

    Keys.onEscapePressed: event => {
        root.dismissed()
        event.accepted = true
    }
    Keys.onUpPressed: event => {
        root.moveSelection(-1)
        event.accepted = true
    }
    Keys.onDownPressed: event => {
        root.moveSelection(1)
        event.accepted = true
    }
    Keys.onReturnPressed: event => {
        root.triggerSelectedAction()
        event.accepted = true
    }
    Keys.onEnterPressed: event => {
        root.triggerSelectedAction()
        event.accepted = true
    }

    function isAction(index) {
        return index >= 0 && index < actions.length && !Boolean(actions[index].separator)
    }

    function moveSelection(direction) {
        if (actions.length === 0)
            return

        let index = selectedActionIndex
        for (let step = 0; step < actions.length; ++step) {
            index = (index + direction + actions.length) % actions.length
            if (isAction(index)) {
                selectedActionIndex = index
                return
            }
        }
    }

    function triggerSelectedAction() {
        if (isAction(selectedActionIndex))
            root.triggered(actions[selectedActionIndex].action)
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.14)

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 0

            Text {
                width: parent.width
                height: 40
                leftPadding: 10
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: Kirigami.Theme.textColor
                font.pixelSize: 14
                font.weight: Font.DemiBold
                text: root.appName
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
            }

            Repeater {
                model: root.actions
                delegate: Item {
                    id: actionDelegate
                    required property int index
                    required property var modelData
                    width: parent.width
                    height: modelData.separator ? 9 : 40

                    Rectangle {
                        visible: Boolean(actionDelegate.modelData.separator)
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 1
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
                    }

                    Rectangle {
                        visible: !Boolean(actionDelegate.modelData.separator)
                        anchors.fill: parent
                        radius: 9
                        color: rowMouse.containsMouse || root.selectedActionIndex === index
                               ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.09)
                               : "transparent"

                        Text {
                            anchors.fill: parent
                            leftPadding: 10
                            rightPadding: 10
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 14
                            text: String(actionDelegate.modelData.label || "")
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            enabled: !Boolean(actionDelegate.modelData.separator)
                            hoverEnabled: true
                            onEntered: {
                                if (!Boolean(actionDelegate.modelData.separator))
                                    root.selectedActionIndex = index
                            }
                            onClicked: root.triggered(actionDelegate.modelData.action)
                        }
                    }
                }
            }
        }
    }
}
