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
        tx.executeSql("CREATE TABLE IF NOT EXISTS appVersion(appVersion)");
        updater(tx);
        if(typeof func == "function") {
            func(tx);
        }
    });
}

function updater(tx) {
    var appVersion = internalAppVersion;
    var currentVersion = 0;
    var res = tx.executeSql("SELECT * FROM appVersion");
    if(res.rows.length) {
        currentVersion = parseInt(res.rows.item(0).appVersion);
    }
    if(appVersion == currentVersion) {
        return;
    }
    switch(currentVersion) {
    case 0:
        var defaultPath = dlgSourceFile.shortcuts.movies;
        tx.executeSql("INSERT INTO appVersion (appVersion) VALUES (1)");
        res = tx.executeSql("SELECT * FROM paths");
        if(!res.rows.length) {
            tx.executeSql("INSERT INTO paths (sourcePath, subtitlesPath, outputPath) VALUES (?,?,?)", [
                            defaultPath, defaultPath, defaultPath
                          ]);
        }
        tx.executeSql("ALTER TABLE paths ADD COLUMN mkvToolnixPath");
        tx.executeSql("ALTER TABLE paths ADD COLUMN mkvToolnixSavePath");
        tx.executeSql(
                    "UPDATE paths SET mkvToolnixPath = ?, mkvToolnixSavePath = ?",
                    [defaultPath, defaultPath]
                    );
        var resUpdate = tx.executeSql("SELECT * FROM updateVersion");
        if(!resUpdate.rows.length) {
            tx.executeSql("INSERT INTO updateVersion (updateVersion) VALUES (1)");
        }
        break;
    }
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

function updateMKVSourceDir(path) {
    transaction(function(tx){
        tx.executeSql("UPDATE paths SET mkvToolnixPath = ?", [path]);
    });
}

function updateMKVSaveDir(path) {
    transaction(function(tx){
        tx.executeSql("UPDATE paths SET mkvToolnixSavePath = ?", [path]);
    });
}
