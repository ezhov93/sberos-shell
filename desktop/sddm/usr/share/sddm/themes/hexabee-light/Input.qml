import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

TextField {
    placeholderTextColor: "#6c707f"
    palette.text: "#17191c"
    font.pointSize: config.fontSize
    font.family: config.font || "SF UI Text"
    width: parent.width
    background: Rectangle {
        color: "#ffffff"
        radius: 16
        border.width: parent.activeFocus ? 2 : 1
        border.color: parent.activeFocus ? "#108e26" : "#c4c7d4"
    }
}
