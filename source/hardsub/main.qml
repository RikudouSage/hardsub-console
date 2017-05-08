import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.LocalStorage 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.1
import QtWinExtras 1.0

import "qrc:/DB.js" as DB
import "qrc:/components"

ApplicationWindow {

    property string sourceVideoPath
    property string sourceSubtitlePath
    property string outputVideoPath
    property int totalDuration
    property int currentDuration
    property int secondsPassed: 0

    visible: true
    width: 640
    minimumWidth: 640
    maximumWidth: 640
    height: 450
    minimumHeight: 450
    maximumHeight: 450
    title: qsTr("Hardsub Console")

    onCurrentDurationChanged: {
        var d = Math.round((currentDuration / totalDuration * 100) * 100) / 100;
        progressPage.percents = d;
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        interactive: false

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
                            taskbarButton.progress.visible = true;
                            swipeView.setCurrentIndex(1);
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
    }

    footer: TabBar {
        visible: false
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: "Hardsub"
        }
        TabButton {
            text: "Progress"
        }
    }

    FileDialog {
        id: dlgSourceFile
        title: qsTr("Select video")
        folder: sourceVideoPath
        nameFilters: [qsTr("Videos %1").arg("(*.mkv)")]
        onAccepted: {
            DB.updateSourceDir(folder);
            sourceFile.text = String(fileUrl).replace("file:///","");
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
            subtitlesFile.text = String(fileUrl).replace("file:///","");
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
            outputDir.text = String(fileUrl).replace("file:///","");
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
            taskbarButton.progress.visible = false;
            var msgBoxHandler = function() {
                msgbox.close();
                msgbox.button1.clicked.disconnect(msgBoxHandler);
                msgbox.button1.visible = false;
                msgbox.button2.clicked.disconnect(msgBoxHandlerOpen);
                msgbox.button2.visible = false;
                swipeView.setCurrentIndex(0);
            };
            var msgBoxHandlerOpen = function() {
                msgBoxHandler();
                misctools.openDirectory("file:///"+outputDir.text);
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
            taskbarButton.progress.visible = false;
            var msgBoxHandler = function() {
                msgbox.close();
                msgbox.button1.clicked.disconnect(msgBoxHandler);
                msgbox.button1.visible = false;
                swipeView.setCurrentIndex(0);
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
            swipeView.setCurrentIndex(0);
            taskbarButton.progress.visible = false;
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

    TaskbarButton {
        id: taskbarButton
        progress.maximum: totalDuration
        progress.value: currentDuration
        progress.visible: false
    }

    Component.onCompleted: {
        misctools.checkNewVersion();
        var defaultPath = dlgSourceFile.shortcuts.movies;
        DB.transaction(function(tx) {
            var res = tx.executeSql("SELECT * FROM paths");
            var resUpdate = tx.executeSql("SELECT * FROM updateVersion");
            if(!res.rows.length) {
                tx.executeSql("INSERT INTO paths (sourcePath, subtitlesPath, outputPath) VALUES (?,?,?)", [
                                defaultPath, defaultPath, defaultPath
                              ]);
                res = tx.executeSql("SELECT * FROM paths");
            }
            if(!resUpdate.rows.length) {
                tx.executeSql("INSERT INTO updateVersion (updateVersion) VALUES (1)");
            }

            var row = res.rows.item(0);
            sourceVideoPath = row.sourcePath;
            sourceSubtitlePath = row.subtitlesPath;
            outputVideoPath = row.outputPath;
        });
    }
}
