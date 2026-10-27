// Create only missing panels. lastScreen also covers saved containments whose
// views have not been restored yet (or whose output is temporarily disconnected).
(function () {
    var occupiedScreens = {};
    for (var id of panelIds) {
        var existing = panelById(id);
        if (existing && existing.type === "io.gitgud.wackyideas.panel") {
            var screen = existing.screen;
            if (screen < 0) screen = Number(existing.readConfig("lastScreen", -1));
            // The combined applet keeps the existing task model and pins.
            // Remove the former standalone launcher without replacing the panel.
            const launchers = existing.widgets("p-connor.plasma-drawer");
            if (launchers.length) {
                existing.locked = false;
                for (const launcher of launchers) launcher.remove();
                existing.locked = true;
            }
            occupiedScreens[screen] = true;
        }
    }

    for (var screen = 0; screen < screenCount; ++screen) {
        if (occupiedScreens[screen]) continue;
        var panel = new Panel("io.gitgud.wackyideas.panel");
        // Assign the output before sizing or adding applets.
        panel.screen = screen;
        // SberOS keeps the unified panel on the lower screen edge.

        panel.location = "bottom"
        panel.height = 88
        // Keep one shared panel and strut; the panel containment paints the mock's islands.
        panel.floating = false
        panel.floatingApplets = false

        // Match the mock: outer zones at the screen edges, search centered.
        panel.alignment = "center"
        panel.lengthMode = "fill"

        panel.addWidget("io.gitgud.wackyideas.sbermenu")
        var applications = panel.addWidget("io.gitgud.wackyideas.smarttasks")
        applications.currentConfigGroup = ["General"]
        applications.writeConfig("launchers", "preferred://filemanager,preferred://browser,applications:org.kde.konsole.desktop,applications:systemsettings.desktop")

        var fileSearch = panel.addWidget("com.mcc45tr.filesearch")
        fileSearch.currentConfigGroup = ["Panel"]
        fileSearch.writeConfig("displayMode", 3)
        fileSearch.writeConfig("showSearchButton", false)

        panel.addWidget("KdeControlStation")
        panel.addWidget("io.gitgud.wackyideas.clockcalendar")

        // The SberOS panel layout is fixed; users cannot add or rearrange applets.
        panel.locked = true
    }
})();
