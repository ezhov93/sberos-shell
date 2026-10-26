add_subdirectory(src)

set(plasmoids
    io.gitgud.wackyideas.panel
    io.gitgud.wackyideas.sbermenu
    io.gitgud.wackyideas.smarttasks
    io.gitgud.wackyideas.clockcalendar
    io.gitgud.wackyideas.desktopcontainment
    p-connor.plasma-drawer
    KdeControlStation
    com.mcc45tr.filesearch
)

foreach(plasmoid IN LISTS plasmoids)
    plasma_install_package(${plasmoid} ${plasmoid})
endforeach()

