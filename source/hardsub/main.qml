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
    title: "Hardsub Konzole"

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
                    text: "Zvolte soubor s původním videem:"
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
                        text: "Zvolit video"
                        onClicked: {
                            dlgSourceFile.open();
                        }
                    }
                }
                Label {
                    width: parent.width
                    text: "Zvolte soubor s titulkami:"
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
                        text: "Zvolit titulky"
                        onClicked: {
                            dlgSubtitlesFile.open();
                        }
                    }
                }
                Label {
                    width: parent.width
                    text: "Zvolte složku, do které se uloží hardsub:"
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
                        text: "Zvolit složku"
                        onClicked: {
                            dlgOutputFile.open();
                        }
                    }
                }

                Label {
                    width: parent.width
                    text: "Zadejte název výsledného souboru:"
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
                    text: "Zadejte bitrate videa v kB:"
                }

                TextField {
                    id: bitrate
                    width: parent.width * 0.9
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Vytvořit hardsub"
                    onClicked: {
                        var srcVideo = sourceFile.text;
                        var subtitles = subtitlesFile.text;
                        var outputVideo = outputDir.text+"/"+outputFile.text;
                        var br = bitrate.text;
                        if(srcVideo && subtitles && outputVideo.replace("/","") && br) {
                            totalDuration = videohelper.getLength(sourceFile.text);
                            durationTimer.start();
                            videohelper.startConversion(srcVideo, subtitles, outputVideo, br);
                            swipeView.setCurrentIndex(1);
                        } else {
                            var msgBoxHandler = function() {
                                msgbox.close();
                                msgbox.okButton.clicked.disconnect(msgBoxHandler);
                                msgbox.okButton.visible = false;
                            };
                            msgbox.title = "Chyba";
                            msgbox.text = "Je potřeba vyplnit všechna pole.";
                            msgbox.okButton.text = "OK";
                            msgbox.okButton.visible = true;
                            msgbox.okButton.clicked.connect(msgBoxHandler);
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
                text: "Zastavit vytváření hardsubu"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 20
                anchors.bottom: conversionLabel.top
                onClicked: {
                    videohelper.stopConversion();
                }
            }

            Label {
                id: conversionLabel
                text: "Probíhá konverze ("+progressPage.percents+" %)"
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
                property string remainingText: "0 min."
                id: remainingLabel
                width: parent.width * 0.8
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.topMargin: 20
                anchors.top: progressBar.bottom
                text: "Zbývá přibližně: "+remainingText;
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
        title: "Zvolte video"
        folder: sourceVideoPath
        nameFilters: ["Videa (*.mkv)"]
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
        title: "Zvolte titulky"
        folder: sourceSubtitlePath
        nameFilters: ["Titulky (*.ass *.srt)", "Všechny soubory (*)"]
        onAccepted: {
            DB.updateSubtitlesDir(folder);
            subtitlesFile.text = String(fileUrl).replace("file:///","");
        }
    }

    FileDialog {
        id: dlgOutputFile
        title: "Zvolte soubor k uložení"
        folder: outputVideoPath
        selectExisting: true
        selectFolder: true
        onAccepted: {
            DB.updateOutputDir(folder);
            outputDir.text = String(fileUrl).replace("file:///","");
        }
    }

    Connections {
        target: videohelper
        onResultReady: {
            durationTimer.stop();
            remainingLabel.remainingText = "0 min.";
            secondsPassed = 0;
            currentDuration = 0;
            totalDuration = 0;
            var msgBoxHandler = function() {
                msgbox.close();
                msgbox.okButton.clicked.disconnect(msgBoxHandler);
                msgbox.okButton.visible = false;
                msgbox.openButton.clicked.disconnect(msgBoxHandlerOpen);
                msgbox.openButton.visible = false;
                swipeView.setCurrentIndex(0);
            };
            var msgBoxHandlerOpen = function() {
                msgBoxHandler();
                misctools.openDirectory("file:///"+outputDir.text);
            };
            msgbox.title = "Hotovo";
            msgbox.text = "Video bylo úspěšně převedeno! Chcete otevřít složku s videem?"
            msgbox.okButton.text = "Zavřít";
            msgbox.okButton.visible = true;
            msgbox.okButton.clicked.connect(msgBoxHandler);
            msgbox.openButton.text = "Otevřít složku";
            msgbox.openButton.visible = true;
            msgbox.openButton.focus = true;
            msgbox.openButton.clicked.connect(msgBoxHandlerOpen);
            msgbox.open();
        }
        onFileDoesNotExist: {
            currentDuration = 0;
            totalDuration = 0;
            var msgBoxHandler = function() {
                msgbox.close();
                msgbox.okButton.clicked.disconnect(msgBoxHandler);
                msgbox.okButton.visible = false;
                swipeView.setCurrentIndex(0);
            };
            msgbox.title = "Chyba";
            msgbox.text = "Jeden ze zadaných souborů neexistuje";
            msgbox.okButton.text = "OK";
            msgbox.okButton.visible = true;
            msgbox.okButton.clicked.connect(msgBoxHandler);
            msgbox.open();
        }
        onCurrentDurationChanged: {
            currentDuration = duration;
        }
        onCancelled: {
            durationTimer.stop();
            remainingLabel.remainingText = "0 min.";
            secondsPassed = 0;
            currentDuration = 0;
            totalDuration = 0;
            swipeView.setCurrentIndex(0);
        }
    }

    MessageDialog {
        id: doneDialog
        text: "Video bylo úspěšně převedeno! Chcete otevřít složku s videem?"
        standardButtons: StandardButton.Open | StandardButton.Cancel
        title: "Hotovo"
        onAccepted: {
            if(clickedButton == StandardButton.Open) {
                misctools.openDirectory("file:///"+outputDir.text);
            }
        }
    }

    MessageBox {
        id: msgbox
    }

    MessageDialog {
        id: msg
        function setAndShow(message, title) {
            text = message;
            msg.title = title;
            msg.visible = true;
        }
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
            var remainingText = String(minutes)+" min.";
            if(hours) {
                remainingText = String(hours)+" h, "+remainingText;
            }

            remainingLabel.remainingText = remainingText;
        }
    }

    Component.onCompleted: {
        var defaultPath = dlgSourceFile.shortcuts.movies;
        DB.transaction(function(tx) {
            var res = tx.executeSql("SELECT * FROM paths");
            if(!res.rows.length) {
                tx.executeSql("INSERT INTO paths (sourcePath, subtitlesPath, outputPath) VALUES (?,?,?)", [
                                defaultPath, defaultPath, defaultPath
                              ]);
                res = tx.executeSql("SELECT * FROM paths");
            }
            var row = res.rows.item(0);
            sourceVideoPath = row.sourcePath;
            sourceSubtitlePath = row.subtitlesPath;
            outputVideoPath = row.outputPath;
        });
    }
}
