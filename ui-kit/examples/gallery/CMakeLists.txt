find_package(Qt6 REQUIRED COMPONENTS Widgets Quick Qml)

qt_add_executable(sber-components-gallery main.cpp)
qt_add_resources(sber-components-gallery gallery
    PREFIX "/gallery"
    FILES Main.qml ComponentDetail.qml
)
target_compile_definitions(sber-components-gallery PRIVATE
    SBER_QML_IMPORT_PATH="${CMAKE_BINARY_DIR}/qml"
    SBER_THEME_RESOURCES_PATH="${THEME_RESOURCES_PATH}"
)
target_link_libraries(sber-components-gallery PRIVATE Qt6::Widgets Qt6::Quick Qt6::Qml)
add_dependencies(sber-components-gallery
    SberCorePlugin SberThemePlugin SberControlsPlugin SberUtilsPlugin SberWidgetsPlugin
)
