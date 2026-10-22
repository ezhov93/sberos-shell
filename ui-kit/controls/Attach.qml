import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import Sber.Controls
import Sber.Core
import Sber.Theme


Item {
    id: control

    property alias nameFilters: fileDialog.nameFilters
    property alias currentFolder: fileDialog.currentFolder
    property bool selectMultiple: false
    property alias fileDialog: fileDialog

    property int lineHeight: Core.Settings.LineHeight
    property alias text: button.text
    property alias label: label
    property alias labelText: label.text
    property alias labelColor: label.color
    property alias labelFont: label.font
    property alias sublabel: sublabel
    property alias sublabelText: sublabel.text
    property alias sublabelColor: sublabel.color
    property alias sublabelFont: sublabel.font
    property alias caption: captionLabel
    property alias captionText: captionLabel.text
    property alias captionColor: captionLabel.color
    property alias captionFont: captionLabel.font
    property alias icon: icon
    property alias required: requiredIndicator.visible;
    property int requiredPlacement: Widget.Left
    property alias type: button.type
    property alias backgroundType: button.backgroundType
    opacity: enabled ? 1 : 0.4

    implicitWidth: Math.max(button.implicitWidth, titleRow.implicitWidth, captionLabel.implicitWidth)
    implicitHeight: titleRow.implicitHeight + button.anchors.topMargin + button.implicitHeight +
                    (captionLabel.text != "" ? captionLabel.height + 5 : 0)
    width: implicitWidth
    height: implicitHeight

    signal fileAdded(file: string)

    Row {
        id: titleRow
        spacing: 5

        Label {
            id: label
            verticalAlignment: Qt.AlignBottom
            lineHeight: control.lineHeight
        }
        Icon {
            id: icon
            anchors.verticalCenter: label.verticalCenter
            size: 14
        }
        Label {
            id: sublabel
            anchors.verticalCenter: label.verticalCenter
            lineHeight: control.lineHeight
            secondary: true
        }
    }
    Button {
        id: button
        anchors.top: titleRow.bottom
        anchors.topMargin: titleRow.implicitHeight == 0 ? 0 :
                           control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 6 :
                           control.lineHeight <= Theme.Sizes.LineHeight.M  ? 8 :
                           control.lineHeight <= Theme.Sizes.LineHeight.L  ? 10 :
                                                                             12
        text: qsTr("Upload file")
        onReleased: {
            fileDialog.visible = true;
        }
    }
    Label {
        id: captionLabel
        anchors.top: button.bottom
        anchors.topMargin: 4
        lineHeight: control.lineHeight
        secondary: true
        font: Theme.Fonts.BodyXs
    }

    FileDialog {
        id: fileDialog
        nameFilters: [qsTr("All files (*)")]
        fileMode: control.selectMultiple ? FileDialog.OpenFiles : FileDialog.OpenFile
        title: control.selectMultiple ? qsTr("Select files") : qsTr("Select file")
        onAccepted: {
            for (var i = 0; i < fileDialog.selectedFiles.length; i++) {
                fileAdded(fileDialog.selectedFiles[i]);
            }
        }
    }

    Indicator {
        id: requiredIndicator
        x: control.requiredPlacement == Widget.Left ?
               titleRow.implicitHeight != 0 ? -width - 4 :
                                              0 :
               titleRow.implicitHeight != 0 ? titleRow.width + 4 :
                                              button.width - requiredIndicator.width
        y: titleRow.implicitHeight != 0 ? titleRow.y + 4 :
                                          button.y
        status: Widget.Error
        visible: false
        lineHeight: Theme.Sizes.LineHeight.S
    }
}

