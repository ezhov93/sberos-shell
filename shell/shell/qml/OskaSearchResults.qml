import QtQuick
import org.kde.kirigami as Kirigami
import Sber.Theme
import "Glass"

Item {
    id: resultsView
    property string query: ""
    property int currentIndex: 0
    property real listMargin: 8
    property real iconLeftInset: 10
    property real textLeftInset: 46
    property real textRightInset: implicitWidth - listMargin - 12
    readonly property var results: modelLoader.item
    readonly property int maxHeight: 390
    readonly property real desiredHeight: resultsView.query === "" ? 76 : list.count > 0 ? Math.min(maxHeight, list.contentHeight + 20) : 76
    property real animatedHeight: desiredHeight
    implicitWidth: 448
    implicitHeight: animatedHeight
    signal activated

    Behavior on animatedHeight {
        Spring {}
    }

    Loader {
        id: modelLoader
        source: "SearchResults.qml"
        onLoaded: item.queryString = Qt.binding(() => resultsView.query)
        onStatusChanged: if (status === Loader.Error)
            console.warn("Oska search: KRunner results unavailable (org.kde.milou)")
    }

    function moveSelection(delta) {
        if (list.count < 1)
            return;
        currentIndex = Math.max(0, Math.min(list.count - 1, currentIndex + delta));
        list.positionViewAtIndex(currentIndex, ListView.Contain);
    }

    function runCurrent() {
        if (!results || list.count < 1)
            return;
        const index = Math.max(0, Math.min(currentIndex, list.count - 1));
        if (results.run(results.index(index, 0)))
            activated();
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.leftMargin: resultsView.listMargin
        anchors.rightMargin: resultsView.listMargin
        anchors.topMargin: resultsView.listMargin
        anchors.bottomMargin: resultsView.listMargin
        model: resultsView.results
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 0
        keyNavigationEnabled: false
        section.property: "category"
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            required property string section
            width: list.width
            height: 26
            Text {
                x: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                text: {
                    const key = String(section).toLocaleLowerCase();
                    if (key.includes("app") || key.includes("прилож"))
                        return qsTr("Приложения");
                    if (key.includes("file") || key.includes("document") || key.includes("place") || key.includes("файл") || key.includes("документ") || key.includes("мест"))
                        return qsTr("Документы");
                    return section;
                }
                color: Theme.Palette.Text.Default.Secondary
                font: Theme.Fonts.BodyS
            }
        }
        delegate: Item {
            id: row
            required property int index
            required property var model
            width: list.width
            height: 46
            readonly property bool selected: index === resultsView.currentIndex
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: Theme.Sizes.BorderRadius.M
                color: row.selected ? Theme.Palette.Background.Default.Secondary : "transparent"
                border.width: row.selected ? 1 : 0
                border.color: Theme.Palette.Outline.Default.SolidPrimary
            }
            Kirigami.Icon {
                id: icon
                x: resultsView.iconLeftInset
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                height: 26
                source: row.model.decoration
                roundToIconSize: false
            }
            Column {
                x: resultsView.textLeftInset
                width: Math.max(0, hint.x - x - 4)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text {
                    width: parent.width
                    text: row.model.display ?? ""
                    color: Theme.Palette.Text.Default.Primary
                    font: Theme.Fonts.BodyM
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }
                Text {
                    width: parent.width
                    text: row.model.subtext ?? ""
                    visible: text !== ""
                    color: Theme.Palette.Text.Default.Secondary
                    font: Theme.Fonts.BodyS
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                    textFormat: Text.PlainText
                }
            }
            Text {
                id: hint
                x: resultsView.textRightInset - implicitWidth
                anchors.verticalCenter: parent.verticalCenter
                text: "↵"
                color: Theme.Palette.Text.Default.Secondary
                font: Theme.Fonts.BodyM
                opacity: row.selected ? 0.9 : 0
            }
            TapHandler {
                onTapped: {
                    resultsView.currentIndex = row.index;
                    resultsView.runCurrent();
                }
            }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        visible: resultsView.query !== "" && list.count === 0 && (!resultsView.results || !resultsView.results.querying)
        text: qsTr("Ничего не найдено")
        color: Theme.Palette.Text.Default.Secondary
        font: Theme.Fonts.BodyM
    }
}
