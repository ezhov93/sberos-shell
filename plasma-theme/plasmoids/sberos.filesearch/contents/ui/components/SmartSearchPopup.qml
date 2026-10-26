/* SPDX-License-Identifier: GPL-3.0-or-later */
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.milou as Milou
import ".."

FocusScope {
    id: popup
    required property var logic
    property string searchQuery: ""
    signal dismissed()
    readonly property SmartPanelTheme smartTheme: SmartPanelTheme {}
    property var matches: []
    readonly property var entries: popup.searchQuery.trim().length ? (results.queryString === popup.searchQuery.trim() ? matches : []) : logic.searchHistory.map(item => ({
        display: item.display, decoration: item.decoration, url: item.filePath || "", sourceIndex: -1,
        application: Boolean(item.isApplication) || String(item.filePath || "").endsWith(".desktop")
    })).filter(item => item.url.length > 0)
    readonly property var applications: entries.filter(item => item.application).slice(0, 4)
    readonly property var documents: entries.filter(item => !item.application)
    implicitWidth: 456
    implicitHeight: 589
    Layout.minimumWidth: 456
    Layout.maximumWidth: 456
    Layout.preferredWidth: 456
    Layout.minimumHeight: 589
    Layout.maximumHeight: 589
    Layout.preferredHeight: 589
    focus: false

    onSearchQueryChanged: {
        popup.matches = [];
        if (searchQuery.trim().length) debounce.restart();
        else { debounce.stop(); results.clear(); }
    }

    function activate(entry) {
        if (entry.sourceIndex >= 0) {
            results.run(results.index(entry.sourceIndex, 0));
        } else if (entry.application) {
            logic.launchApp(entry.url);
        } else {
            Qt.openUrlExternally(entry.url);
        }
        logic.addToHistory(entry.display, entry.decoration, entry.application ? "Applications" : "Documents", entry.url || entry.display, entry.url, null, searchQuery);
        popup.dismissed();
    }
    function activateFirst() {
        const first = popup.applications[0] || popup.documents[0];
        if (first) popup.activate(first);
    }
    function refresh() {
        const values = [];
        for (let i = 0; i < raw.count; i++) {
            const row = raw.objectAt(i);
            if (!row) continue;
            const url = String(row.url || "");
            const application = url.endsWith(".desktop") || /application|приложени/i.test(row.category);
            if (application || url.startsWith("file:") || url.startsWith("/"))
                values.push({display: row.label, decoration: row.icon, url: url, sourceIndex: i, application: application});
        }
        popup.matches = values;
    }
    Milou.ResultsModel {
        id: results
        limit: 40
    }
    Timer {
        id: debounce
        interval: 100
        onTriggered: results.queryString = popup.searchQuery.trim()
    }
    Timer {
        id: refreshTimer
        interval: 30
        onTriggered: popup.refresh()
    }
    Connections {
        target: results
        function onDataChanged() { refreshTimer.restart(); }
        function onRowsInserted() { refreshTimer.restart(); }
        function onRowsRemoved() { refreshTimer.restart(); }
        function onModelReset() { refreshTimer.restart(); }
    }
    Instantiator {
        id: raw
        model: results
        delegate: QtObject {
            required property var model
            readonly property string label: model.display || ""
            readonly property var icon: model.decoration || ""
            readonly property string category: model.category || ""
            readonly property string url: String(model.url || (model.urls && model.urls.length ? model.urls[0] : ""))
        }
        onObjectAdded: refreshTimer.restart()
        onObjectRemoved: refreshTimer.restart()
    }

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: smartTheme.shell
        border.width: 1
        border.color: smartTheme.edge
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 20
        color: smartTheme.inner
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        ScrollView {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            leftPadding: 16
            rightPadding: 16
            topPadding: 12
            bottomPadding: 12
            clip: true
            ColumnLayout {
                width: scroll.availableWidth
                spacing: 12
                Text {
                    visible: popup.applications.length > 0
                    text: qsTr("Приложения")
                    color: popup.smartTheme.foreground
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: popup.applications.length > 0
                    spacing: 8
                    Repeater {
                        model: popup.applications
                        delegate: Button {
                            id: app
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredWidth: 96
                            Layout.preferredHeight: 96
                            padding: 4
                            Accessible.name: modelData.display
                            onClicked: popup.activate(modelData)
                            background: Rectangle {
                                radius: 12
                                color: app.down ? popup.smartTheme.pressed : app.hovered ? popup.smartTheme.hover : "transparent"
                                border.width: app.visualFocus ? 2 : 0
                                border.color: popup.smartTheme.focus
                            }
                            contentItem: ColumnLayout {
                                spacing: 8
                                Kirigami.Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 48
                                    source: app.modelData.decoration
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: app.modelData.display
                                    color: popup.smartTheme.foreground
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
                Text {
                    visible: popup.documents.length > 0
                    text: popup.searchQuery.length ? qsTr("Документы") : qsTr("Недавние документы")
                    color: popup.smartTheme.foreground
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
                Repeater {
                    model: popup.documents
                    delegate: Button {
                        id: document
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        padding: 8
                        Accessible.name: modelData.display
                        onClicked: popup.activate(modelData)
                        background: Rectangle {
                            radius: 10
                            color: document.down ? popup.smartTheme.pressed : document.hovered ? popup.smartTheme.hover : "transparent"
                            border.width: document.visualFocus ? 2 : 0
                            border.color: popup.smartTheme.focus
                        }
                        contentItem: RowLayout {
                            spacing: 12
                            SmartPanelIcon {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                source: {
                                    const url = document.modelData.url.toLowerCase();
                                    const name = /\.pdf$/.test(url) ? "filePdf" : /\.docx?$/.test(url) ? "fileWord"
                                        : /\.xlsx?$/.test(url) ? "fileExcel" : /\.pptx?$/.test(url) ? "filePowerpoint"
                                        : /\.(png|jpe?g|webp|svg)$/.test(url) ? "fileImage" : "file";
                                    return Qt.resolvedUrl("../../assets/smart-panel/" + name + ".svg");
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: document.modelData.display
                                color: popup.smartTheme.foreground
                                font.pixelSize: 16
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    visible: popup.entries.length === 0
                    text: results.querying ? qsTr("Поиск…") : popup.searchQuery.length ? qsTr("Ничего не найдено") : qsTr("Начните вводить название документа или приложения")
                    color: popup.smartTheme.muted
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
