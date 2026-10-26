import QtQuick
import Quickshell.Widgets
import org.kde.baloo as Baloo
import "../../../shared/qml/i18n"
import qs.desktop.modules.common
import qs.desktop.modules.dock
import "../../../Kos/Ui"

// App and document search rendered inside the expanding Oska dock island.
Item {
    id: root

    width: 456
    height: 653
    property bool active: false
    property string query: ""

    signal queryEdited(string value)
    signal closeRequested

    readonly property var appResults: {
        AppPresentationService.catalogRevision;
        AppPresentationService.revision;
        const needle = query.trim().toLowerCase();
        const matches = [];
        const catalogue = AppPresentationService.catalog();
        for (let i = 0; i < catalogue.length; i++) {
            const presentation = catalogue[i];
            if ((presentation.displayName + " " + presentation.desktopId).toLowerCase().includes(needle)) {
                matches.push({
                    kind: "app",
                    title: presentation.displayName,
                    subtitle: presentation.desktopId,
                    icon: presentation.iconSource,
                    desktopId: presentation.desktopId
                });
            }
        }
        return matches;
    }
    readonly property var appPreviewResults: appResults.slice(0, 4)

    function activateApp(app) {
        if (!app)
            return;
        AppActionService.launch(app);
        closeRequested();
    }

    function activateFirstResult() {
        if (appPreviewResults.length > 0) {
            activateApp(appPreviewResults[0]);
            return;
        }
        const firstDocument = documentList.itemAtIndex(0);
        firstDocument?.activate();
    }

    component ResultIcon: Item {
        property string iconSource: ""

        IconImage {
            anchors.fill: parent
            source: parent.iconSource
            smooth: true
            asynchronous: false
        }
    }

    Baloo.Query {
        id: documentQuery
        searchString: root.active ? root.query.trim() : ""
        limit: 6
    }

    Baloo.QueryResultsModel {
        id: documentResultsModel
        query: documentQuery
    }

    Timer {
        id: focusTimer
        interval: 0
        onTriggered: searchInput.forceActiveFocus(Qt.PopupFocusReason)
    }

    Timer {
        id: documentSearchTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (root.active && root.query.trim().length >= 2)
                documentResultsModel.populateModel()
        }
    }

    onActiveChanged: {
        if (active) {
            focusTimer.restart();
            documentSearchTimer.restart();
        } else {
            focusTimer.stop();
            documentSearchTimer.stop();
        }
    }
    onQueryChanged: if (active)
        documentSearchTimer.restart()

    OpaqueSurface {
        x: 7
        y: 7
        width: root.width - 14
        height: 573
        radius: 20
    }

    ThemeText {
        x: 23
        y: 19
        text: I18n.tr("Apps")
        font.pixelSize: 16
        font.weight: Font.DemiBold
    }

    GridView {
        id: appGrid
        x: 23
        y: 47
        width: root.width - 46
        height: 96
        cellWidth: width / 4
        cellHeight: 96
        clip: true
        model: root.active ? root.appPreviewResults : null

        delegate: Item {
            id: appResult
            required property var modelData
            required property int index
            width: appGrid.cellWidth
            height: appGrid.cellHeight
            Accessible.role: Accessible.Button
            Accessible.name: modelData.title

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 11
                visible: appMouse.containsMouse
                color: AppearanceTokens.state.hover
            }

            ResultIcon {
                width: 64
                height: 64
                anchors.horizontalCenter: parent.horizontalCenter
                y: 9
                iconSource: appResult.modelData.icon
            }

            ThemeText {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 72
                    leftMargin: 7
                    rightMargin: 7
                }
                text: appResult.modelData.title
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            MouseArea {
                id: appMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activateApp(appResult.modelData)
            }
        }
    }

    ThemeText {
        anchors.centerIn: appGrid
        text: I18n.tr("No apps found")
        color: AppearanceTokens.colors.surfaceVariantForeground
        visible: root.active && root.appPreviewResults.length === 0
    }

    Rectangle {
        x: 23
        y: 151
        width: root.width - 46
        height: 1
        color: AppearanceTokens.colors.outlineVariant
        opacity: 0.7
    }

    ThemeText {
        x: 23
        y: 161
        text: I18n.tr("Documents")
        font.pixelSize: 16
        font.weight: Font.DemiBold
    }

    ListView {
        id: documentList
        x: 23
        y: 190
        width: root.width - 46
        height: 390
        clip: true
        model: root.active && root.query.trim().length >= 2 ? documentResultsModel : null

        delegate: Item {
            id: documentResult
            required property var url
            width: documentList.width
            height: 54
            activeFocusOnTab: true
            Accessible.role: Accessible.Button
            readonly property string localPath: String(url?.toLocalFile?.() ?? url ?? "")
            readonly property string fileName: localPath.split("/").filter(Boolean).slice(-1)[0] ?? ""
            readonly property string folderName: localPath.split("/").filter(Boolean).slice(-2, -1)[0] ?? ""
            readonly property string fileIcon: {
                const ext = fileName.split(".").pop().toLowerCase();
                if (ext === "pdf") return "application-pdf";
                if (["doc", "docx", "odt", "rtf"].includes(ext)) return "x-office-document";
                if (["xls", "xlsx", "ods", "csv"].includes(ext)) return "x-office-spreadsheet";
                if (["ppt", "pptx", "odp"].includes(ext)) return "x-office-presentation";
                if (["png", "jpg", "jpeg", "webp", "svg"].includes(ext)) return "image-x-generic";
                return "text-x-generic";
            }

            function activate() {
                Qt.openUrlExternally(url);
                root.closeRequested();
            }

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: documentMouse.containsMouse ? AppearanceTokens.state.hover : "transparent"
            }

            ResultIcon {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                iconSource: SystemIconResolver.sourceFromCandidates(documentResult.fileIcon, "text-x-generic")
            }

            Column {
                anchors {
                    left: parent.left
                    leftMargin: 32
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 4

                ThemeText {
                    width: parent.width
                    text: documentResult.fileName
                    elide: Text.ElideRight
                    font.pixelSize: 16
                }

                ThemeText {
                    width: parent.width
                    text: documentResult.folderName
                    color: AppearanceTokens.content.shellInk(0.62)
                    elide: Text.ElideRight
                    font.pixelSize: 12
                }
            }

            MouseArea {
                id: documentMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: documentResult.activate()
            }
            Keys.onReturnPressed: documentResult.activate()
            Keys.onEnterPressed: documentResult.activate()
        }

        KosKineticScroll {
            flickable: documentList
        }
    }

    ThemeText {
        x: 23
        y: 198
        width: root.width - 46
        height: 54
        visible: root.active && root.query.trim().length >= 2 && documentList.count === 0
        text: I18n.tr("No matching documents")
        color: AppearanceTokens.content.shellInk(0.52)
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
    }

    OpaqueSurface {
        x: 7
        y: 588
        width: root.width - 14
        height: 56
        radius: 17
    }

    Image {
        x: 16
        y: 596
        width: 40
        height: 40
        source: Qt.resolvedUrl("../../assets/oska-avatar.svg")
        fillMode: Image.PreserveAspectFit
        Accessible.ignored: true
    }

    TextInput {
        id: searchInput
        objectName: "quicksearch-island-input"
        x: 68
        y: 592
        width: root.width - 91
        height: 48
        color: ThemeService.foregroundColor
        font.family: "Noto Sans CJK SC"
        font.pixelSize: 15
        clip: true
        selectByMouse: true
        text: root.query
        activeFocusOnTab: true
        Accessible.name: I18n.tr("Search installed apps and documents")
        onTextEdited: root.queryEdited(text)
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.closeRequested();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.activateFirstResult();
                event.accepted = true;
            }
        }

        ThemeText {
            anchors.fill: parent
            visible: !searchInput.text && !searchInput.inputMethodComposing
            text: I18n.tr("Найду документ или приложение")
            color: AppearanceTokens.content.shellInk(0.54)
            font: searchInput.font
            verticalAlignment: Text.AlignVCenter
            Accessible.ignored: true
        }
    }
}
