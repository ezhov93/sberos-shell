cmake_minimum_required(VERSION 3.16)
include(CMakePackageConfigHelpers)


set(CMAKE_INSTALL_DEFAULT_DIRECTORY_PERMISSIONS
  OWNER_EXECUTE OWNER_WRITE OWNER_READ
  GROUP_EXECUTE GROUP_READ
  WORLD_EXECUTE WORLD_READ
)


macro(sosc_set_qt_install_qml_qt6)
  execute_process(
    COMMAND qmake6 -query QT_INSTALL_PREFIX
    OUTPUT_VARIABLE QT_INSTALL_PREFIX
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  execute_process(
    COMMAND qmake6 -query QT_INSTALL_QML
    OUTPUT_VARIABLE QT_INSTALL_QML
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
endmacro()


function(sosc_link_plugins TARGET_NAME PLUGINS_PATH INCLUDES_PATH)
  add_library(SberUtilsPlugin MODULE IMPORTED)
  set_target_properties(SberUtilsPlugin PROPERTIES
    IMPORTED_LOCATION
      ${PLUGINS_PATH}Sber/Utils/libSberUtilsPlugin.so
    INTERFACE_INCLUDE_DIRECTORIES
      ${INCLUDES_PATH}
  )
  add_library(SberCorePlugin MODULE IMPORTED)
  set_target_properties(SberCorePlugin PROPERTIES
    IMPORTED_LOCATION
      ${PLUGINS_PATH}Sber/Core/libSberCorePlugin.so
    INTERFACE_INCLUDE_DIRECTORIES
      ${INCLUDES_PATH}
  )
  add_library(SberThemePlugin MODULE IMPORTED)
  set_target_properties(SberThemePlugin PROPERTIES
    IMPORTED_LOCATION
      ${PLUGINS_PATH}Sber/Theme/libSberThemePlugin.so
    INTERFACE_INCLUDE_DIRECTORIES
      ${INCLUDES_PATH}
  )
  add_library(SberControlsPlugin MODULE IMPORTED)
  set_target_properties(SberControlsPlugin PROPERTIES
    IMPORTED_LOCATION
      ${PLUGINS_PATH}Sber/Controls/libSberControlsPlugin.so
    INTERFACE_INCLUDE_DIRECTORIES
      ${INCLUDES_PATH}
  )
  add_library(SberWidgetsPlugin MODULE IMPORTED)
  set_target_properties(SberWidgetsPlugin PROPERTIES
    IMPORTED_LOCATION
      ${PLUGINS_PATH}Sber/Widgets/libSberWidgetsPlugin.so
    INTERFACE_INCLUDE_DIRECTORIES
      ${INCLUDES_PATH}
  )
  target_link_libraries(${TARGET_NAME} PUBLIC SberUtilsPlugin SberCorePlugin SberThemePlugin SberControlsPlugin SberWidgetsPlugin)
endfunction()


function(sosc_set_plugins_include_dirs SBER_COMPONENTS_DIR)
  file(GLOB_RECURSE H_FILES ${SBER_COMPONENTS_DIR}/core/*.h
                            ${SBER_COMPONENTS_DIR}/theme/*.h
                            ${SBER_COMPONENTS_DIR}/controls/*.h
                            ${SBER_COMPONENTS_DIR}/widgets/*.h
                            ${SBER_COMPONENTS_DIR}/utils/*.h)

  set(PLUGINS_INCLUDE_DIRS "")
  foreach(FILE ${H_FILES})
      get_filename_component(DIR ${FILE} PATH)
      set(PLUGINS_INCLUDE_DIRS ${PLUGINS_INCLUDE_DIRS} ${DIR}/)
  endforeach()
  list(REMOVE_DUPLICATES PLUGINS_INCLUDE_DIRS)
  set(PLUGINS_INCLUDE_DIRS ${PLUGINS_INCLUDE_DIRS} CACHE INTERNAL "PLUGINS_INCLUDE_DIRS")

  message("-- Plugins include dirs: ${PLUGINS_INCLUDE_DIRS}")
endfunction()


# Optional third argument: QML directory of a custom build tree.
function(socs_link_plugins_from_sources TARGET_NAME SBER_COMPONENTS_DIR)
  set(QML_MODULES_DIR "${SBER_COMPONENTS_DIR}/_build/qml")
  if(ARGC GREATER 2)
    set(QML_MODULES_DIR "${ARGV2}")
  endif()
  sosc_link_plugins(${TARGET_NAME} ${QML_MODULES_DIR}/ ${PLUGINS_INCLUDE_DIRS})
  list(APPEND QML_IMPORT_PATH ${QML_MODULES_DIR})
  set(QML_IMPORT_PATH ${QML_IMPORT_PATH} PARENT_SCOPE)
endfunction()


function(sosc_install_plugin TARGET_NAME TARGET_VERSION)
  configure_package_config_file(
        ${TARGET_NAME}.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}Config.cmake
      INSTALL_DESTINATION
        ${CMAKE_CONFIG_INSTALL_DIR}/${TARGET_NAME}
  )
  write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake
      VERSION
        ${TARGET_VERSION}
      COMPATIBILITY
        SameMajorVersion
  )
  install(
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}ConfigVersion.cmake
      DESTINATION
        ${CMAKE_CONFIG_INSTALL_DIR}/${TARGET_NAME}
      COMPONENT Devel
  )
endfunction()
