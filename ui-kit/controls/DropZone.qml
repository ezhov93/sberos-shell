import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

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
    property alias title: titleLabel.text
    property alias caption: captionLabel.text

    opacity: enabled ? 1 : 0.4

    signal fileAdded(file: string)

    Rectangle {
        id: dropZone
        property bool acceptDrag: true

        anchors.fill: parent
        color: Theme.Palette.Background.Default.Quaternary
        radius: lineHeight <= Theme.Sizes.LineHeight.Xs ? Theme.Sizes.BorderRadius.Xs : lineHeight <= Theme.Sizes.LineHeight.S ? Theme.Sizes.BorderRadius.S : lineHeight <= Theme.Sizes.LineHeight.M ? Theme.Sizes.BorderRadius.M : Theme.Sizes.BorderRadius.L
        DashedBorder {
            anchors.fill: parent
            lineWidth: 2
            radius: dropZone.radius
            color: dropArea.containsDrag ? dropZone.acceptDrag ? Theme.Palette.Outline.Default.AccentActive : Theme.Palette.Outline.Default.NegativeActive : Theme.Palette.Outline.Default.SolidPrimary
        }

        Column {
            id: content
            anchors.centerIn: parent
            opacity: dropArea.containsDrag ? 0.6 : 1
            spacing: 12

            Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: "ArrowBarDown"
                size: control.lineHeight <= Theme.Sizes.LineHeight.Xs ? 18 : control.lineHeight <= Theme.Sizes.LineHeight.S ? 20 : control.lineHeight <= Theme.Sizes.LineHeight.M ? 22 : 24
            }

            Label {
                id: titleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                lineHeight: control.lineHeight
                bold: true
            }
            Label {
                id: captionLabel
                anchors.horizontalCenter: parent.horizontalCenter
                lineHeight: control.lineHeight
                secondary: true
                smaller: true
            }
        }

        MouseArea {
            id: clickArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                fileDialog.visible = true;
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
        }

        DropArea {
            id: dropArea
            anchors.fill: parent
            onEntered: drag => {
                if (fileDialog.nameFilters.length != 0) {
                    if (!control.selectMultiple && drag.urls.length > 1) {
                        dropZone.acceptDrag = false;
                        drag.accepted = true;
                        return;
                    }

                    const re = /(\*\.\w+|\*)/g;
                    const results = fileDialog.nameFilters.join(' ').match(re);
                    for (var i = 0; i < results.length; i++) {
                        results[i] = results[i].split('.').pop();
                    }
                    if (!results.includes('*')) {
                        for (var i = 0; i < drag.urls.length; i++) {
                            if (!results.includes(String(drag.urls[i]).split('.').pop())) {
                                dropZone.acceptDrag = false;
                                drag.accepted = true;
                                return;
                            }
                        }
                    }
                }
                dropZone.acceptDrag = true;
                drag.accepted = true;
            }
            onDropped: drop => {
                if (dropZone.acceptDrag) {
                    drop.accept(Qt.LinkAction);
                    for (var i = 0; i < drop.urls.length; i++) {
                        fileAdded(String(drop.urls[i]).replace("file://", ''));
                    }
                }
            }
        }
    }
}
