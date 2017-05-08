var mainDB;

function get() {
    if(!mainDB) {
        mainDB = LocalStorage.openDatabaseSync("main", "1.0","MainDB", 1000000);
    }
    return mainDB;
}

function transaction(func) {
    get().transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS paths (sourcePath, subtitlesPath, outputPath)");
        tx.executeSql("CREATE TABLE IF NOT EXISTS updateVersion (updateVersion)");
        if(typeof func == "function") {
            func(tx);
        }
    });
}

function updateSourceDir(path) {
    transaction(function(tx) {
        tx.executeSql("UPDATE paths SET sourcePath = ?", [path]);
    });
}

function updateSubtitlesDir(path) {
    transaction(function(tx) {
        tx.executeSql("UPDATE paths SET subtitlesPath = ?", [path]);
    });
}

function updateOutputDir(path) {
    transaction(function(tx) {
        tx.executeSql("UPDATE paths SET outputPath = ?", [path]);
    });
}
