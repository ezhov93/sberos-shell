cmake_minimum_required(VERSION 3.16)

set(PLUGIN_OUTPUT_DIR "${CMAKE_BINARY_DIR}/qml")

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Test)

qt_add_executable(test_plugin_load
    test_plugin_load.cpp
)
set_target_properties(test_plugin_load PROPERTIES AUTOMOC ON)
target_compile_definitions(test_plugin_load PRIVATE
    TEST_PLUGIN_DIR="${PLUGIN_OUTPUT_DIR}"
)
target_link_libraries(test_plugin_load PRIVATE
    Qt6::Test
    ${CMAKE_DL_LIBS}
)
add_test(NAME test_plugin_load
    COMMAND test_plugin_load
)
set_tests_properties(test_plugin_load PROPERTIES
    LABELS "abi;smoke"
)

# The pointer/keyboard contract is exercised against the built QML plugins.
find_program(QMLTESTRUNNER_EXECUTABLE NAMES qmltestrunner HINTS /usr/lib/qt6/bin)
if(QMLTESTRUNNER_EXECUTABLE)
    file(MAKE_DIRECTORY
        "${CMAKE_CURRENT_BINARY_DIR}/slider-data"
        "${CMAKE_CURRENT_BINARY_DIR}/slider-config"
        "${CMAKE_CURRENT_BINARY_DIR}/regression-data"
        "${CMAKE_CURRENT_BINARY_DIR}/regression-config")
    add_test(NAME test_slider_input
        COMMAND "${QMLTESTRUNNER_EXECUTABLE}" -input "${CMAKE_CURRENT_SOURCE_DIR}/tst_slider.qml"
            -import "${PLUGIN_OUTPUT_DIR}")
    set_tests_properties(test_slider_input PROPERTIES
        LABELS "qml;input"
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software;XDG_DATA_HOME=${CMAKE_CURRENT_BINARY_DIR}/slider-data;XDG_CONFIG_HOME=${CMAKE_CURRENT_BINARY_DIR}/slider-config")
    add_test(NAME test_ui_kit_regressions
        COMMAND "${QMLTESTRUNNER_EXECUTABLE}" -input "${CMAKE_CURRENT_SOURCE_DIR}/tst_ui_kit_regressions.qml"
            -import "${PLUGIN_OUTPUT_DIR}")
    set_tests_properties(test_ui_kit_regressions PROPERTIES
        LABELS "qml;regression"
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software;XDG_DATA_HOME=${CMAKE_CURRENT_BINARY_DIR}/regression-data;XDG_CONFIG_HOME=${CMAKE_CURRENT_BINARY_DIR}/regression-config")
endif()
