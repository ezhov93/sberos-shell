import QtQuick
import SircaShell

QtObject {
    Component.onCompleted: {
        Shell.saveConfigKey("mustNotOverwrite", true)
        Qt.quit()
    }
}
