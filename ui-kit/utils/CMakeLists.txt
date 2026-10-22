cmake_minimum_required(VERSION 3.16)
set(ORGANIZATION_NAME "sberos")

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml DBus Quick)
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED glib-2.0)

set(PLUGIN_NAME SberUtilsPlugin)
set(PLUGIN_VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

file(GLOB SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cpp)
file(GLOB HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.h)

qt6_add_qml_module(${PLUGIN_NAME}
  URI Sber.Utils
  VERSION ${PLUGIN_VERSION}
  OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml/Sber/Utils/
  PLUGIN_TARGET ${PLUGIN_NAME}
  SOURCES
    ${SOURCES}
    ${HEADERS}
)

target_include_directories(${PLUGIN_NAME} PRIVATE ${GLIB_INCLUDE_DIRS})
target_link_libraries(${PLUGIN_NAME} PRIVATE
  Qt6::Core
  Qt6::Gui
  Qt6::Qml
  Qt6::DBus
  Qt6::Quick
  ${GLIB_LIBRARIES}
)

sosc_install_plugin(${PLUGIN_NAME} ${PLUGIN_VERSION})
