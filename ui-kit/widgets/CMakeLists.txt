cmake_minimum_required(VERSION 3.16)
set(ORGANIZATION_NAME "sberos")

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_FEATURE_zstd OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)


set(PLUGIN_NAME SberWidgetsPlugin)
set(PLUGIN_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

file(GLOB HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.h)
file(GLOB QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

qt6_add_qml_module(${PLUGIN_NAME}
  URI Sber.Widgets
  VERSION ${PLUGIN_VERSION}
  OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/Sber/Widgets/
  PLUGIN_TARGET ${PLUGIN_NAME}
  SOURCES
    ${HEADERS}
  QML_FILES
    ${QML_FILES}
  DEPENDENCIES
    Sber.Controls
)
target_include_directories(${PLUGIN_NAME} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/theme>
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/theme/generated>
  $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/core/generated>
)
add_dependencies(${PLUGIN_NAME} SberControlsPlugin)
target_link_directories(${PLUGIN_NAME} PUBLIC
  $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/qml/Sber/Core>
  ${QT_INSTALL_QML}/Sber/Core/
)
target_link_libraries(${PLUGIN_NAME} PUBLIC
  libSberCorePlugin.so
)
target_link_libraries(${PLUGIN_NAME} PRIVATE
  Qt6::Core
  Qt6::Gui
  Qt6::Qml
  Qt6::Quick
)

sosc_install_plugin(${PLUGIN_NAME} ${PLUGIN_VERSION})
