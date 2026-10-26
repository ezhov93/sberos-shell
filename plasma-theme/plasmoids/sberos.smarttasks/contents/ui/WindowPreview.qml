pragma ComponentBehavior: Bound

/*
    SPDX-FileCopyrightText: 2026 SberOS Shell contributors
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick

Item {
    id: root

    property string appName
    property var windows: []
    property var smartTheme

    signal activateRequested(int index)
    signal closeRequested(int index)

    readonly property int cardWidth: 248
    readonly property int cardHeight: 176
    readonly property int spacing: 8
    readonly property int contentWidth: Math.max(cardWidth, windows.length * (cardWidth + spacing) - spacing)

    implicitWidth: Math.min(520, contentWidth + 24)
    implicitHeight: cardHeight + 54

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: root.smartTheme.shell
        border.color: root.smartTheme.separator
        border.width: 1
    }

    Text {
        x: 16
        y: 10
        width: parent.width - 32
        height: 28
        text: root.appName
        color: root.smartTheme.foreground
        font.pixelSize: 14
        font.weight: Font.DemiBold
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    Flickable {
        x: 12
        y: 42
        width: parent.width - 24
        height: root.cardHeight
        contentWidth: root.contentWidth
        contentHeight: height
        clip: true
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        Row {
            spacing: root.spacing

            Repeater {
                model: root.windows

                delegate: Item {
                    id: card
                    required property int index
                    required property var modelData
                    width: root.cardWidth
                    height: root.cardHeight

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: root.smartTheme.inner
                        clip: true

                        WindowPreviewThumbnail {
                            x: 1
                            y: 1
                            width: parent.width - 2
                            height: 140
                            windowId: String(card.modelData.windowId || "")
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 36
                            color: root.smartTheme.inner

                            Text {
                                x: 10
                                width: parent.width - 50
                                height: parent.height
                                text: String(card.modelData.title || qsTr("Окно"))
                                color: root.smartTheme.foreground
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.rightMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                width: 26
                                height: 26
                                radius: 13
                                color: closeMouse.containsMouse ? root.smartTheme.hover : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    color: root.smartTheme.foreground
                                    font.pixelSize: 18
                                }

                                MouseArea {
                                    id: closeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.closeRequested(card.index)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.bottomMargin: 36
                            onClicked: root.activateRequested(card.index)
                        }
                    }
                }
            }
        }
    }
}
