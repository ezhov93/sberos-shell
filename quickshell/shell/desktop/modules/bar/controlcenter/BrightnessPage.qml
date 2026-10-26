import QtQuick
import qs.desktop.modules.bar
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../../shared/qml/i18n"

Item {
    id: brightnessSubmenuView
    objectName: "control-center-brightnesspage"
    required property var service
    signal settingsRequested(string module)
    ListView {
        id: brightnessDisplayList
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 14
            rightMargin: 14
            bottomMargin: 38
        }
        spacing: 4
        clip: true
        model: brightnessSubmenuView.service.brightnessDisplays

        delegate: Item {
            id: displayBrightnessRow
            required property var modelData
            required property int index
            width: brightnessDisplayList.width
            height: 82
            property real preview: Number(modelData.percent || 0)

            ThemeText {
                anchors {
                    left: parent.left
                    right: displayBrightnessPercent.left
                    top: parent.top
                    rightMargin: 8
                }
                text: modelData.label || modelData.id || I18n.tr("Display")
                elide: Text.ElideRight
                color: AppearanceTokens.content.shellInk()
                font {
                    pixelSize: 11
                    weight: Font.DemiBold
                    family: "Noto Sans CJK SC"
                }
            }
            ThemeText {
                id: displayBrightnessPercent
                anchors {
                    right: parent.right
                    top: parent.top
                }
                text: Math.round(displayBrightnessRow.preview) + "%"
                color: AppearanceTokens.content.shellInk()
                font {
                    pixelSize: 10
                    family: "Noto Sans CJK SC"
                }
            }
            ThemeText {
                anchors {
                    left: parent.left
                    top: parent.top
                    topMargin: 20
                }
                text: modelData.isInternal ? I18n.tr("Built-in display") : I18n.tr("External display")
                color: AppearanceTokens.content.shellInk()
                font {
                    pixelSize: 9
                    family: "Noto Sans CJK SC"
                }
            }
            ControlCenterSlider {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: 3
                }
                value: displayBrightnessRow.preview / 100
                enabled: !brightnessSubmenuView.service.brightnessChangeInProgress
                onPreviewChanged: function (v) {
                    displayBrightnessRow.preview = Math.round(v * 100);
                }
                onCanceled: displayBrightnessRow.preview = Qt.binding(function () {
                    return Number(displayBrightnessRow.modelData.percent || 0);
                })
                onCommitRequested: function (v) {
                    brightnessSubmenuView.service.setDisplayBrightness(displayBrightnessRow.modelData.id, Math.round(v * 100));
                }
            }
        }
    }

    ThemeText {
        anchors.centerIn: parent
        visible: brightnessSubmenuView.service.brightnessDisplays.length === 0
        text: I18n.tr("No brightness-adjustable displays found")
        color: AppearanceTokens.content.shellInk()
        font {
            pixelSize: 11
            family: "Noto Sans CJK SC"
        }
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 38
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 12
                rightMargin: 12
            }
            height: 1
            color: AppearanceTokens.colors.surfaceContainerHigh
        }
        ThemeText {
            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            text: I18n.tr("Display settings…")
            color: AppearanceTokens.content.shellInk()
            font {
                pixelSize: 11
                weight: Font.DemiBold
                family: "Noto Sans CJK SC"
            }
        }
        ThemeText {
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            text: "›"
            color: AppearanceTokens.content.shellInk()
            font {
                pixelSize: 13
                weight: Font.Bold
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: brightnessSubmenuView.settingsRequested("kcm_kscreen")
        }
    }
}
