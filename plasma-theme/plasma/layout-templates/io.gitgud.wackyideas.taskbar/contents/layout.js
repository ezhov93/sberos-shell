var panel = new Panel("io.gitgud.wackyideas.panel");
var panelScreen = panel.screen
if (panelScreen < 0 && screenCount > 0) {
    // A new panel has no screen association yet; use the primary screen for initial sizing.
    panelScreen = 0
}

// SberOS keeps the unified panel on the lower screen edge.

// For an Icons-Only Task Manager on the bottom, *3 is too much, *2 is too little
// Round down to next highest even number since the Panel size widget only displays
// even numbers
panel.location = "bottom"
panel.height = 72
// Keep one shared panel and strut; the panel containment paints the mock's islands.
panel.floating = false

// Restrict horizontal panel to a maximum size of a 21:9 monitor
const maximumAspectRatio = 21/9;
if (panel.formFactor === "horizontal") {
    const geo = screenGeometry(panelScreen);
    const maximumWidth = Math.ceil(geo.height * maximumAspectRatio);

    if (geo.width > maximumWidth) {
        panel.alignment = "center";
        panel.minimumLength = maximumWidth;
        panel.maximumLength = maximumWidth;
    }
}

panel.addWidget("io.gitgud.wackyideas.sbermenu")
var appLauncher = panel.addWidget("p-connor.plasma-drawer")
appLauncher.currentConfigGroup = ["General"]
appLauncher.writeConfig("icon", "view-app-grid-symbolic")
appLauncher.writeConfig("appIconSize", 120)
appLauncher.writeConfig("maxNumberColumns", 8)
appLauncher.writeConfig("backgroundType", 1)
appLauncher.writeConfig("customBackgroundColor", "#32353e")
appLauncher.writeConfig("backgroundOpacity", 58)
appLauncher.writeConfig("showSystemActions", false)
appLauncher.writeConfig("searchRunners", "krunner_services")

var applications = panel.addWidget("io.gitgud.wackyideas.smarttasks")
applications.currentConfigGroup = ["General"]
applications.writeConfig("launchers", "preferred://filemanager,preferred://browser,applications:org.kde.konsole.desktop,applications:systemsettings.desktop")

var fileSearch = panel.addWidget("com.mcc45tr.filesearch")
fileSearch.currentConfigGroup = ["Panel"]
fileSearch.writeConfig("displayMode", 3)
fileSearch.writeConfig("panelHeight", 72)
fileSearch.writeConfig("showSearchButton", false)

var systemSpacer = panel.addWidget("org.kde.plasma.panelspacer")
systemSpacer.writeConfig("expanding", true)

panel.addWidget("KdeControlStation")
panel.addWidget("io.gitgud.wackyideas.clockcalendar")
