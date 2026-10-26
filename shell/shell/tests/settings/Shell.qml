pragma Singleton
import QtQuick

QtObject {
    property var config: ({})
    property int configRevision: 0
    property bool plasmaRunning: false
    property string version: "test"
    property string buildCommit: ""
    property var launches: []
    property var wallpapers: []
    function loadConfig() {
        return config;
    }
    function saveConfigKeys(changes) {
        config = Object.assign({}, config, changes);
        configRevision++;
    }
    function saveConfigKey(key, value) {
        const changes = {};
        changes[key] = value;
        saveConfigKeys(changes);
    }
    function removeConfigKey(key) {
        const next = Object.assign({}, config);
        delete next[key];
        config = next;
        configRevision++;
    }
    function picturesPath() {
        return "/tmp";
    }
    function setWithoutPlasmashell(value) {
    }
    function wallpaperFiles(folder) {
        return wallpapers;
    }
    function plasmaWallpaper() {
        return "";
    }
    function hasProgram(program) {
        return false;
    }
    function toolPath(program) {
        return "";
    }
    function configPath() {
        return "/tmp/sirca-settings-test/config.json";
    }
    function runDetached(program, args) {
        launches = launches.concat([
            {
                program: program,
                args: args
            }
        ]);
    }
}
