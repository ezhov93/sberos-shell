import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.volume as Vol

import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Slider {
    Layout.fillWidth: true
    Layout.fillHeight: true
    visible: sinkAvailable && root.showVolume
    useIconButton: true
    title: qsTr("Звук")
    canTogglePage: false
    quickSettingsStyle: true
    noMargins: true

    // Volume Feedback
    Vol.VolumeFeedback {
        id: feedback
    }

    // Audio source
    property var sink: Vol.PreferredDevice.sink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")
    readonly property Vol.SinkModel paSinkModel: Vol.SinkModel {
        id: paSinkModel
    }

    value: sinkAvailable ? Math.round(sink.volume / Vol.PulseAudio.NormalVolume * 100) : 0
    secondaryTitle: sinkAvailable ? Math.round(sink.volume / Vol.PulseAudio.NormalVolume * 100) + "%" : ""

    showTitle: root.volume_widget_title
    thinSlider: root.volume_widget_thin
    flat: quickSettingsStyle ? true : root.volume_widget_flat // bind to Lib.Card property

    // Changes icon based on the current volume percentage
    source: sinkAvailable ? Funcs.volIconName(sink.volume, sink.muted) : "audio-volume-muted"

    onValueChanged: {
        if(root.playVolumeFeedback && sinkAvailable) {
            feedback.play(sink.index)
        }
    }
    // Update volume
    onMoved: {
        if (sinkAvailable) {
            sink.volume = value * Vol.PulseAudio.NormalVolume / 100
        }
    }
    // Display view that shows audio devices list
    onTogglePage: {
        var pageHeight =  volumePage.contentItemHeight + volumePage.headerHeight;
        fullRep.togglePage(fullRep.defaultInitialWidth, pageHeight, volumePage);
    }

    property var oldVol: 100 * Vol.PulseAudio.NormalVolume / 100
    onClicked: {
        if (!sinkAvailable) {
            return
        }
        if(value!=0){
            oldVol = sink.volume
            sink.volume=0
        } else {
            sink.volume=oldVol
        }
    }
}
