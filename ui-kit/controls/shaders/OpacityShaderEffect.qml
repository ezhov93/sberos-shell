import QtQuick

ShaderEffect {
    property var source
    property var maskSource
    fragmentShader: "shaders/opacity_mask.frag.qsb"
}
