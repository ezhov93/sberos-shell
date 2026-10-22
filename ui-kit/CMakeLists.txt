cmake_minimum_required(VERSION 3.16)
set_property(GLOBAL PROPERTY GLOBAL_DEPENDS_DEBUG_MODE 0)

set(ORGANIZATION_NAME "sberos")
project(SberComponents)


include(${CMAKE_SOURCE_DIR}/cmake/sosc_include.cmake)
sosc_set_qt_install_qml_qt6()
include(GNUInstallDirs)

set(INCLUDES_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/SberComponents)
set(CMAKE_CONFIG_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake)
set(BINARIES_INSTALL_DIR ${QT_INSTALL_QML})
set(THEME_RESOURCES_PATH "${CMAKE_CURRENT_SOURCE_DIR}/resources" CACHE PATH "Theme, font and icon resource directory")
add_definitions(-DTHEME_RESOURCES_PATH="${THEME_RESOURCES_PATH}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -gdwarf-4")

file(READ "version.txt" ver)
string(REGEX MATCH "MAJOR ([0-9]*)" _ ${ver})
set(VERSION_MAJOR ${CMAKE_MATCH_1})
add_definitions(-DVERSION_MAJOR="${VERSION_MAJOR}")
string(REGEX MATCH "MINOR ([0-9]*)" _ ${ver})
set(VERSION_MINOR ${CMAKE_MATCH_1})
add_definitions(-DVERSION_MINOR="${VERSION_MINOR}")
string(REGEX MATCH "PATCH ([0-9]*)" _ ${ver})
set(VERSION_PATCH ${CMAKE_MATCH_1})
add_definitions(-DVERSION_PATCH="${VERSION_PATCH}")

add_subdirectory(core)
add_subdirectory(controls)
add_subdirectory(theme)
add_subdirectory(utils)
add_subdirectory(widgets)
add_subdirectory(po)

option(BUILD_EXAMPLES "Build the components gallery" ON)
if(BUILD_EXAMPLES)
    add_subdirectory(examples/gallery)
endif()

option(BUILD_WITH_CTEST "Enable CTest integration" ON)
if(BUILD_WITH_CTEST)
    enable_testing()
    add_subdirectory(tests)
endif()

file(GLOB_RECURSE HEADERS_LIST RELATIVE ${CMAKE_SOURCE_DIR}
  core/*.h controls/*.h theme/*.h utils/*.h widgets/*.h)
install(
  FILES
    ${HEADERS_LIST}
  DESTINATION
    ${INCLUDES_INSTALL_DIR}
)
install(CODE "execute_process(COMMAND /bin/chmod -R 755 ${INCLUDES_INSTALL_DIR})")
install(
  DIRECTORY
    ${CMAKE_BINARY_DIR}/qml/
  DESTINATION
    ${BINARIES_INSTALL_DIR}
)
install(CODE "execute_process(COMMAND /bin/chmod -R 755 ${BINARIES_INSTALL_DIR}/Sber)")


install(DIRECTORY resources/theme resources/icons
    DESTINATION ${CMAKE_INSTALL_DATADIR}/SberComponents)
