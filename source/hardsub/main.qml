import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.1

import "qrc:/DB.js" as DB
import "qrc:/components"

ApplicationWindow {
    readonly property int cPAGE_HARDSUB: 0
    readonly property int cPAGE_PROGRESS: 2
    readonly property int cPAGE_MKVTOOLS: 1
    readonly property int cPAGE_MKV_PROGRESS: 3
    readonly property int internalAppVersion: 1

    property string sourceVideoPath
    property string sourceSubtitlePath
    property string outputVideoPath
    property string mkvToolnixSourcePath
    property string mkvToolnixSavePath

    property int totalDuration
    property int currentDuration
    property int secondsPassed: 0

    property bool isRunning: videohelper.isRunning

    id: appwindow

    visible: true
    width: 640
    minimumWidth: width
    maximumWidth: width
    height: 470
    minimumHeight: height
    maximumHeight: height
    title: isRunning?remainingLabel.remainingText+" - "+qsTr("Hardsub Console"):qsTr("Hardsub Console")

    onCurrentDurationChanged: {
        var d = Math.round((currentDuration / totalDuration * 100) * 100) / 100;
        progressPage.percents = d;
    }

    Label {
        text: "Dominik Chrástecký - 2017"
        font.pixelSize: 12
        color: Material.color(Material.Grey)
        anchors.right: parent.right
        anchors.top: parent.top
        z: 100
        anchors.rightMargin: 10
        anchors.topMargin: 10
        font.family: "Calibri"
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive: false

        onCurrentIndexChanged: {
            if(currentIndex != cPAGE_HARDSUB  && currentIndex != cPAGE_MKVTOOLS) {
                tabBar.enabled = false;
            } else {
                tabBar.enabled = true;
            }
        }

        Page {
            id: mainPage
            Column {
                anchors.fill: parent
                padding: 30
                Label {
                    width: parent.width
                    text: qsTr("Choose the original video file")+":"
                }
                Row {
                    width: parent.width
                    spacing: 20
                    TextField {
                        id: sourceFile
                        width: parent.width * 0.7
                    }
                    Button {
                        id: selectSourceButton
                        text: qsTr("Select video")
                        onClicked: {
                            dlgSourceFile.open();
                        }
                    }
                }
                Label {
                    width: parent.width
                    text: qsTr("Choose the subtitles file")+":"
                }
                Row {
                    width: parent.width
                    spacing: 20
                    TextField {
                        id: subtitlesFile
                        width: parent.width * 0.7
                    }
                    Button {
                        id: selectSubtitlesButton
                        text: qsTr("Select subtitles")
                        onClicked: {
                            dlgSubtitlesFile.open();
                        }
                    }
                }
                Label {
                    width: parent.width
                    text: qsTr("Choose the folder the hardsub will be saved to")+":"
                }
                Row {
                    width: parent.width
                    spacing: 20
                    TextField {
                        id: outputDir
                        width: parent.width * 0.7
                    }
                    Button {
                        id: selectOutputFileButton
                        text: qsTr("Select folder")
                        onClicked: {
                            dlgOutputFile.open();
                        }
                    }
                }

                Label {
                    width: parent.width
                    text: qsTr("Choose the output filename")+":"
                }

                TextField {
                    property bool editedByHand: false
                    id: outputFile
                    width: parent.width * 0.9
                    Keys.onPressed: {
                        editedByHand = true;
                    }
                }

                Label {
                    width: parent.width
                    text: qsTr("Input the output video bitrate in kB")+":"
                }

                TextField {
                    id: bitrate
                    width: parent.width * 0.9
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Create hardsub")
                    onClicked: {
                        var srcVideo = sourceFile.text;
                        var subtitles = subtitlesFile.text;
                        var outputVideo = outputDir.text+"/"+outputFile.text;
                        var br = bitrate.text;
                        if(srcVideo && subtitles && outputVideo.replace("/","") && br) {
                            totalDuration = videohelper.getLength(sourceFile.text);
                            durationTimer.start();
                            videohelper.startConversion(srcVideo, subtitles, outputVideo, br);
                            taskbarButton.progressVisible = true;
                            swipeView.setCurrentIndex(cPAGE_PROGRESS);
                        } else {
                            var msgBoxHandler = function() {
                                msgbox.close();
                                msgbox.button1.clicked.disconnect(msgBoxHandler);
                                msgbox.button1.visible = false;
                            };
                            msgbox.title = qsTr("Error");
                            msgbox.text = qsTr("You need to fill all the fields.");
                            msgbox.button1.text = qsTr("OK");
                            msgbox.button1.visible = true;
                            msgbox.button1.clicked.connect(msgBoxHandler);
                            msgbox.open();
                        }
                    }
                }

                Component.onCompleted: {
                    var maxWidth = Math.max(selectSourceButton.width, selectSubtitlesButton.width, selectOutputFileButton.width);
                    selectSourceButton.width = maxWidth;
                    selectSubtitlesButton.width = maxWidth;
                    selectOutputFileButton.width = maxWidth;
                }
            }
        }

        Page {
            function checkBinaries() {
                mkvinfo = misctools.binaryExists("mkvinfo");
                mkvextract = misctools.binaryExists("mkvextract");
                mkvmerge = misctools.binaryExists("mkvmerge");
                mkvtoolnixReady = mkvinfo && mkvextract && mkvmerge;
            }

            property bool mkvtoolnixReady: false
            property bool mkvinfo: false
            property bool mkvextract: false
            property bool mkvmerge: false

            id: mkvtoolnixPage
            padding: 20

            Label {
                id: mkvPageTitle
                text: qsTr("Extract MKV file")
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 30
            }

            Item {
                visible: mkvtoolnixPage.mkvtoolnixReady
                anchors.fill: parent
                width: parent.width
                anchors.top: mkvPageTitle.bottom
                anchors.topMargin: 20

                Label {
                    id: chooseMKVFileLabel
                    anchors.top: parent.top
                    anchors.topMargin: 30
                    width: parent.width
                    text: qsTr("Choose mkv file")+":"
                }
                Row {
                    id: chooseMKVFileRow
                    anchors.top: chooseMKVFileLabel.bottom
                    width: parent.width
                    spacing: 20
                    TextField {
                        id: mkvSourceFile
                        width: parent.width * 0.7
                    }
                    Button {
                        id: selectMkvSourceFile
                        width: selectSourceButton.width
                        text: qsTr("Select video")
                        onClicked: {
                            selectMKVFileDialog.open();
                        }
                    }
                }

                Column {
                    anchors.top: chooseMKVFileRow.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: mkvToolnixLoadingData
                    visible: mkvhelper.loadingInfo
                    spacing: 5
                    Label {
                        text: qsTr("Loading info...");
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }
                    ProgressBar {
                        indeterminate: true
                        width: 400
                    }
                }

                Column {
                    property var results
                    property int videosCount: 0
                    property int audiosCount: 0
                    property int subtitlesCount: 0
                    anchors.top: chooseMKVFileRow.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: mkvToolnixResults
                    visible: mkvhelper.resultsReady
                    spacing: 5

                    Label {
                        font.pixelSize: 20
                        text: qsTr("The count of video streams: %1").arg(mkvToolnixResults.videosCount)
                    }

                    Label {
                        font.pixelSize: 20
                        text: qsTr("The count of audio streams: %1").arg(mkvToolnixResults.audiosCount)
                    }

                    Label {
                        font.pixelSize: 20
                        text: qsTr("The count of subtitle files: %1").arg(mkvToolnixResults.subtitlesCount)
                    }

                    Row {
                        width: parent.width
                        height: 50
                    }

                    Row {
                        spacing: 10
                        Button {
                            enabled: mkvToolnixResults.subtitlesCount > 0
                            text: qsTr("Extract subtitles")
                            onClicked: {
                                var trackIDS = [];
                                for(var i in mkvToolnixResults.results) {
                                    var result = mkvToolnixResults.results[i];
                                    if(result.type == "subtitles") {
                                        trackIDS.push(result.id);
                                    }
                                }
                                mkvhelper.extractSubtitles(mkvSourceFile.text, trackIDS);
                                swipeView.setCurrentIndex(cPAGE_MKV_PROGRESS);
                            }
                        }
                        Button {
                            enabled: mkvToolnixResults.videosCount > 0
                            text: qsTr("Create copy of video without subtitles")
                            onClicked: {
                                extractVideoDlg.open();
                            }

                            FileDialog {
                                id: extractVideoDlg
                                folder: mkvToolnixSavePath
                                selectExisting: false
                                selectFolder: false
                                selectMultiple: false
                                title: qsTr("Save video")
                                nameFilters: [qsTr("Videos %1").arg("(*.mkv)")]
                                onAccepted: {
                                    var file = String(fileUrl).replace(misctools.filePrefix, "");
                                    if(file.indexOf(".mkv", file.length - 4) == -1) {
                                        file += ".mkv";
                                    }
                                    var orig = String(mkvSourceFile.text);
                                    mkvhelper.extractVideo(orig, file);
                                    swipeView.setCurrentIndex(cPAGE_MKV_PROGRESS);
                                    tabBar.enabled = false;
                                }
                            }
                        }
                    }

                    Connections {
                        target: mkvhelper
                        onResultsProcessed: {
                            mkvToolnixResults.results = results;
                        }
                        onExtractingSubtitlesDone: {
                            saveExtractedSubtitlesDialog.paths = tempPaths;
                            saveExtractedSubtitlesDialog.open();
                        }
                        onExtractVideoDoesNotExist: {
                            var msgBoxHandler = function() {
                                msgbox.close();
                                msgbox.button1.clicked.disconnect(msgBoxHandler);
                                msgbox.button1.visible = false;
                                swipeView.setCurrentIndex(cPAGE_MKVTOOLS);
                                tabBar.enabled = true;
                            };
                            msgbox.title = qsTr("Error");
                            msgbox.text = qsTr("Could not extract video. The original video does not exist.");;
                            msgbox.button1.text = qsTr("Close");
                            msgbox.button1.visible = true;
                            msgbox.button1.clicked.connect(msgBoxHandler);
                            msgbox.open();
                        }
                        onExtractVideoDirDoesNotExist: {
                            var msgBoxHandler = function() {
                                msgbox.close();
                                msgbox.button1.clicked.disconnect(msgBoxHandler);
                                msgbox.button1.visible = false;
                                swipeView.setCurrentIndex(cPAGE_MKVTOOLS);
                                tabBar.enabled = true;
                            };
                            msgbox.title = qsTr("Error");
                            msgbox.text = qsTr("Could not extract video. The directory to save video does not exist.");;
                            msgbox.button1.text = qsTr("Close");
                            msgbox.button1.visible = true;
                            msgbox.button1.clicked.connect(msgBoxHandler);
                            msgbox.open();
                        }
                        onExtractingVideoFailed: {
                            var msgBoxHandler = function() {
                                msgbox.close();
                                msgbox.button1.clicked.disconnect(msgBoxHandler);
                                msgbox.button1.visible = false;
                                swipeView.setCurrentIndex(cPAGE_MKVTOOLS);
                                tabBar.enabled = true;
                            };
                            msgbox.title = qsTr("Error");
                            msgbox.text = qsTr("Could not extract video. Unknown error.");;
                            msgbox.button1.text = qsTr("Close");
                            msgbox.button1.visible = true;
                            msgbox.button1.clicked.connect(msgBoxHandler);
                            msgbox.open();
                        }
                        onExtractingVideoSucceeded: {
                            var folder = String(extractVideoDlg.folder).replace(misctools.filePrefix, "");
                            var msgBoxHandler = function() {
                                msgbox.close();
                                msgbox.button1.clicked.disconnect(msgBoxHandler);
                                msgbox.button1.visible = false;
                                msgbox.button2.clicked.disconnect(msgBoxHandlerOpen);
                                msgbox.button2.visible = false;
                                swipeView.setCurrentIndex(cPAGE_MKVTOOLS);
                                tabBar.enabled = true;
                                sourceFile.text = String(extractVideoDlg.fileUrl).replace(misctools.filePrefix, "");
                                bitrate.text = videohelper.getBitrate(sourceFile.text);
                            };
                            var msgBoxHandlerOpen = function() {
                                msgBoxHandler();
                                misctools.openDirectory(folder);
                            };
                            msgbox.title = qsTr("Done");
                            msgbox.text = qsTr("Video was succesfully extracted. Do you want to open the folder now?");
                            msgbox.button1.text = qsTr("Close");
                            msgbox.button1.visible = true;
                            msgbox.button1.clicked.connect(msgBoxHandler);
                            msgbox.button2.text = qsTr("Open folder");
                            msgbox.button2.visible = true;
                            msgbox.button2.focus = true;
                            msgbox.button2.clicked.connect(msgBoxHandlerOpen);
                            msgbox.open();
                        }
                    }

                    FileDialog {
                        property var paths
                        id: saveExtractedSubtitlesDialog
                        title: qsTr("Select folder to save subtitles")
                        folder: mkvToolnixSavePath
                        selectExisting: true
                        selectFolder: true
                        onAccepted: {
                            DB.updateMKVSaveDir(folder);
                            var success = true;
                            for(var i in paths) {
                                var path = paths[i];
                                var destination = String(folder).replace(misctools.filePrefix, "")+"/subtitles";
                                if(paths.length > 1) {
                                    destination += String(i);
                                }
                                destination += ".ass";
                                if(!misctools.moveFile(path, destination)) {
                                    success = false;
                                }
                            }

                            if(success) {
                                subtitlesFile.text = destination;
                                var msgBoxHandler = function() {
                                    msgbox.close();
                                    msgbox.button1.clicked.disconnect(msgBoxHandler);
                                    msgbox.button1.visible = false;
                                    msgbox.button2.clicked.disconnect(msgBoxHandlerOpen);
                                    msgbox.button2.visible = false;
                                    swipeView.setCurrentIndex(cPAGE_MKVTOOLS);
                                };
                                var msgBoxHandlerOpen = function() {
                                    msgBoxHandler();
                                    misctools.openDirectory(folder);
                                };
                                msgbox.title = qsTr("Done");
                                msgbox.text = qsTr("Subtitles were successfully extracted. Do you want to open the folder now?");
                                msgbox.button1.text = qsTr("Close");
                                msgbox.button1.visible = true;
                                msgbox.button1.clicked.connect(msgBoxHandler);
                                msgbox.button2.text = qsTr("Open folder");
                                msgbox.button2.visible = true;
                                msgbox.button2.focus = true;
                                msgbox.button2.clicked.connect(msgBoxHandlerOpen);
                                msgbox.open();
                            } else {
                                var msgBoxHandler = function() {
                                    msgbox.close();
                                    msgbox.button1.clicked.disconnect(msgBoxHandler);
                                    msgbox.button1.visible = false;
                                    swipeView.setCurrentIndex(cPAGE_MKVTOOLS);
                                };
                                msgbox.title = qsTr("Error");
                                msgbox.text = qsTr("Could not extract subtitles. Make sure the target directory exists and does not contain a file with same name.");;
                                msgbox.button1.text = qsTr("Close");
                                msgbox.button1.visible = true;
                                msgbox.button1.clicked.connect(msgBoxHandler);
                                msgbox.open();
                            }
                        }
                    }

                    onResultsChanged: {
                        if(typeof results != "object") {
                            return;
                        }
                        for(var i in results) {
                            var result = results[i];
                            if(result.type == "video") {
                                videosCount++;
                            } else if(result.type == "audio") {
                                audiosCount++;
                            } else if(result.type == "subtitles") {
                                subtitlesCount++;
                            }
                        }
                    }

                }

                Column {
                    anchors.top: chooseMKVFileRow.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: mkvToolnixLoadingError
                    visible: mkvhelper.errorLoadingInfo
                    spacing: 5
                    Label {
                        text: qsTr("Failed to read data from file!");
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }
                }


                FileDialog {
                    id: selectMKVFileDialog
                    title: qsTr("Select video")
                    folder: mkvToolnixSourcePath
                    nameFilters: [qsTr("Videos %1").arg("(*.mkv)")]
                    onAccepted: {
                        mkvToolnixResults.videosCount = 0;
                        mkvToolnixResults.audiosCount = 0;
                        mkvToolnixResults.subtitlesCount = 0;
                        DB.updateMKVSourceDir(folder);
                        mkvSourceFile.text = String(fileUrl).replace(misctools.filePrefix,"");
                        mkvhelper.getTracksInfo(mkvSourceFile.text);
                    }
                }
            }

            Item {
                visible: !mkvtoolnixPage.mkvtoolnixReady
                width: parent.width
                anchors.top: mkvPageTitle.bottom
                anchors.topMargin: 20
                Label {
                    id: mkvtoolnixNotFoundMessage
                    text: qsTr("Coult not find the MKVToolnix. Please install it according to your distribution.")
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.top: parent.top
                }
                Button {
                    id: mkvtoolnixInstallButton
                    anchors.top: mkvtoolnixNotFoundMessage.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Install MKVToolnix")
                    onClicked: {
                        mkvtoolnixCheckButton.visible = true;
                        misctools.openDirectory("https://mkvtoolnix.download/downloads.html");
                    }
                }
                Button {
                    id: mkvtoolnixCheckButton
                    visible: false
                    anchors.top: mkvtoolnixInstallButton.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Check MKVToolnix again")
                    onClicked: {
                        mkvtoolnixPage.checkBinaries();
                    }
                }
            }

            Component.onCompleted: {
                checkBinaries();
            }
        }

        Page {
            property double percents: 0
            id: progressPage
            Button {
                id: stopConversion
                text: qsTr("Stop hardsub creation")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                anchors.bottom: conversionLabel.top
                onClicked: {
                    videohelper.stopConversion();
                }
            }

            Label {
                id: conversionLabel
                text: qsTr("Hardsub is being created (%1%)").arg(progressPage.percents)
                anchors.centerIn: parent
            }
            Rectangle {
                id: progressBar
                width: parent.width * 0.8
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: conversionLabel.bottom
                anchors.topMargin: 20
                color: Material.color(Material.Pink, Material.Shade100)
                Rectangle {
                    height: parent.height
                    width: parent.width * (progressPage.percents / 100)
                    color: Material.color(Material.Pink)
                }
            }
            Label {
                property string remainingText: qsTr("0 min.")
                id: remainingLabel
                width: parent.width * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.topMargin: 20
                anchors.top: progressBar.bottom
                text: qsTr("Remaining: %1").arg(remainingText);
            }
        }

        Page {
            id: mkvtoolnixProgressPage
            Label {
                id: extractingLabel
                width: parent.width
                text: qsTr("Extracting...");
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                y: appwindow.height / 3
            }
            ProgressBar {
                indeterminate: true
                width: parent.width
                anchors.top: extractingLabel.bottom
                anchors.topMargin: 20
            }
        }
    }

    footer: TabBar {
        visible: true
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Hardsub")
        }
        TabButton {
            text: qsTr("MKV edit")
        }
    }

    FileDialog {
        id: dlgSourceFile
        title: qsTr("Select video")
        folder: sourceVideoPath
        nameFilters: [qsTr("Videos %1").arg("(*.mkv)")]
        onAccepted: {
            DB.updateSourceDir(folder);
            sourceFile.text = String(fileUrl).replace(misctools.filePrefix,"");
            bitrate.text = videohelper.getBitrate(sourceFile.text);
            if(!outputFile.editedByHand) {
                var temp = String(fileUrl).split("/");
                var basename = temp[temp.length - 1];
                var regex = /(.*)\.(.*)/;
                var parts = regex.exec(basename);
                if(parts.length == 3) {
                    var newFilename = parts[1]+".hardsub."+parts[2];
                    outputFile.text = newFilename;
                }
            }
        }
    }

    FileDialog {
        id: dlgSubtitlesFile
        title: qsTr("Select subtitles")
        folder: sourceSubtitlePath
        nameFilters: [qsTr("Subtitles %1").arg("(*.ass *.srt)"), qsTr("All files %1").arg("(*)")]
        onAccepted: {
            DB.updateSubtitlesDir(folder);
            subtitlesFile.text = String(fileUrl).replace(misctools.filePrefix,"");
        }
    }

    FileDialog {
        id: dlgOutputFile
        title: qsTr("Choose the output dir")
        folder: outputVideoPath
        selectExisting: true
        selectFolder: true
        onAccepted: {
            DB.updateOutputDir(folder);
            outputDir.text = String(fileUrl).replace(misctools.filePrefix,"");
        }
    }

    Connections {
        target: misctools
        onNewVersionAvailable: {
            DB.transaction(function(tx) {
                var res = tx.executeSql("SELECT * FROM updateVersion");
                if(!res.rows.item(0).updateVersion) {
                    return;
                }
                var msgBoxDeregister = function() {
                    msgbox.close();
                    msgbox.button1.visible = false;
                    msgbox.button2.visible = false;
                    msgbox.button3.visible = false;
                    msgbox.button1.clicked.disconnect(buttonNoHandler);
                    msgbox.button2.clicked.disconnect(buttonNeverHandler);
                    msgbox.button3.clicked.disconnect(buttonYesHandler);
                };
                var buttonNoHandler = function() {
                    msgBoxDeregister();
                };

                var buttonNeverHandler = function() {
                    msgBoxDeregister();
                    DB.transaction(function(tx) {
                        tx.executeSql("UPDATE updateVersion SET updateVersion = 0");
                    });
                };

                var buttonYesHandler = function() {
                    msgBoxDeregister();
                    misctools.openDirectory(misctools.releasesUrl);
                };

                msgbox.title = qsTr("New version available!");
                msgbox.text = qsTr("New version (%1) of this app is available! Do you want to download it now?").arg(version);
                msgbox.button1.text = qsTr("Never");
                msgbox.button1.visible = true;
                msgbox.button1.clicked.connect(buttonNeverHandler);
                msgbox.button2.text = qsTr("No");
                msgbox.button2.visible = true;
                msgbox.button2.clicked.connect(buttonNoHandler);
                msgbox.button3.text = qsTr("Yes");
                msgbox.button3.visible = true;
                msgbox.button3.clicked.connect(buttonYesHandler);
                msgbox.open();
            });
        }
    }

    Connections {
        target: videohelper
        onResultReady: {
            durationTimer.stop();
            remainingLabel.remainingText = qsTr("0 min.");
            secondsPassed = 0;
            currentDuration = 0;
            totalDuration = 0;
            taskbarButton.progressVisible = false;
            var msgBoxHandler = function() {
                msgbox.close();
                msgbox.button1.clicked.disconnect(msgBoxHandler);
                msgbox.button1.visible = false;
                msgbox.button2.clicked.disconnect(msgBoxHandlerOpen);
                msgbox.button2.visible = false;
                swipeView.setCurrentIndex(cPAGE_HARDSUB);
            };
            var msgBoxHandlerOpen = function() {
                msgBoxHandler();
                misctools.openDirectory(misctools.filePrefix+outputDir.text);
            };
            msgbox.title = qsTr("Done");
            msgbox.text = qsTr("Hardsub created succesfully! Do you want to open the output folder now?");
            msgbox.button1.text = qsTr("Close");
            msgbox.button1.visible = true;
            msgbox.button1.clicked.connect(msgBoxHandler);
            msgbox.button2.text = qsTr("Open folder");
            msgbox.button2.visible = true;
            msgbox.button2.focus = true;
            msgbox.button2.clicked.connect(msgBoxHandlerOpen);
            msgbox.open();
        }
        onFileDoesNotExist: {
            currentDuration = 0;
            totalDuration = 0;
            taskbarButton.progressVisible = false;
            var msgBoxHandler = function() {
                msgbox.close();
                msgbox.button1.clicked.disconnect(msgBoxHandler);
                msgbox.button1.visible = false;
                swipeView.setCurrentIndex(cPAGE_HARDSUB);
            };
            msgbox.title = qsTr("Error");
            msgbox.text = qsTr("One of the selected files does not exist");
            msgbox.button1.text = qsTr("OK");
            msgbox.button1.visible = true;
            msgbox.button1.clicked.connect(msgBoxHandler);
            msgbox.open();
        }
        onCurrentDurationChanged: {
            currentDuration = duration;
        }
        onCancelled: {
            durationTimer.stop();
            remainingLabel.remainingText = qsTr("0 min.");
            secondsPassed = 0;
            currentDuration = 0;
            totalDuration = 0;
            swipeView.setCurrentIndex(cPAGE_HARDSUB);
            taskbarButton.progressVisible = false;
        }
    }

    MessageBox {
        id: msgbox
    }

    Timer {
        repeat: true
        id: durationTimer
        interval: 1000
        running: false
        onTriggered: {
            secondsPassed += 1;
            var remainingSeconds = secondsPassed / currentDuration * totalDuration - secondsPassed;
            var hours = parseInt(remainingSeconds / 60 / 60);
            var minutes = parseInt((remainingSeconds - (hours * 60 * 60)) / 60);
            var remainingText = String(minutes)+" "+qsTr("min.");
            if(hours) {
                //~ Context Short for hour
                remainingText = String(hours)+" "+qsTr("h")+", "+remainingText;
            }

            remainingLabel.remainingText = remainingText;
        }
    }

    AppTaskbarButton {
        id: taskbarButton
        maximum: totalDuration
        current: currentDuration
        progressVisible: false
    }

    Component.onCompleted: {
        misctools.checkNewVersion();
        var defaultPath = dlgSourceFile.shortcuts.movies;
        DB.transaction(function(tx) {
            var res = tx.executeSql("SELECT * FROM paths");
            var row = res.rows.item(0);
            sourceVideoPath = row.sourcePath;
            sourceSubtitlePath = row.subtitlesPath;
            outputVideoPath = row.outputPath;
            mkvToolnixSourcePath = row.mkvToolnixPath;
            mkvToolnixSavePath = row.mkvToolnixSavePath;
        });
    }
}
