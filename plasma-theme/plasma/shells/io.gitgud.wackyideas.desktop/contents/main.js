
loadTemplate("io.gitgud.wackyideas.taskbar")

for (const id of panelIds) {
    const panel = panelById(id)
    if (panel && panel.type === "io.gitgud.wackyideas.panel") {
        panel.locked = true
    }
}

var desktopsArray = desktopsForActivity(currentActivity());
for( var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
    //var clock = desktopsArray[j].addWidget("org.kde.plasma.analogclock");
}

