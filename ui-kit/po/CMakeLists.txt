cmake_minimum_required(VERSION 3.16)
find_package(Qt6 COMPONENTS LinguistTools)

set(QT_DEFAULT_MAJOR_VERSION ${QT_VERSION})
set(TS_FILES_SRC ${CMAKE_CURRENT_SOURCE_DIR}/ru.ts)
set(OUTPUT_QM_FILES ${CMAKE_BINARY_DIR}/qml/Sber/po/ru.qm)

qt6_add_translation(qm_files ${TS_FILES_SRC})

add_custom_command(
    OUTPUT ${OUTPUT_QM_FILES}
    COMMAND ${CMAKE_COMMAND} -E copy
        ${qm_files}
        ${OUTPUT_QM_FILES}
    DEPENDS ${qm_files}
    COMMENT "Copying translation file to ${OUTPUT_QM_FILES}"
)

add_custom_target(copy_translations ALL
    DEPENDS ${OUTPUT_QM_FILES}
)
