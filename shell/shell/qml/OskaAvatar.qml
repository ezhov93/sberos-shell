import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    Image {
        id: portrait
        anchors.fill: parent
        source: "qrc:/qt/qml/SircaShell/qml/oska-avatar-round.png"
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        onStatusChanged: if (status === Image.Error)
            console.warn("Oska avatar failed to load:", source, errorString)
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: "#d9dce3"
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.6
        height: width
        source: "user-symbolic"
        isMask: true
        color: "white"
        visible: portrait.status !== Image.Ready
        roundToIconSize: false
    }
}
