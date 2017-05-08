#include "videoconverter.h"
#include <QProcess>
#include <QFile>
#include <QFileInfo>
#include <QStringList>
#include <QDir>
#include <QRegularExpression>
#include <QRegularExpressionMatch>

void VideoConverter::doWork(const QString &srcVideo, const QString &subtitles, const QString &outputVideo, int bitrate) {
    QFile srcVideoFile(srcVideo);
    QFile subtitlesFile(subtitles);
    QFileInfo outputVideoFile(outputVideo);
    if(outputVideoFile.exists()) {
        QFile tmp(outputVideo);
        tmp.remove();
    }
    if(!srcVideoFile.exists() || !subtitlesFile.exists() || !outputVideoFile.dir().exists()) {
        emit fileDoesNotExist();
        return;
    }

    QString currentPath = QDir::currentPath();
    QFileInfo fi_subtitles(subtitles);
    QDir::setCurrent(fi_subtitles.dir().absolutePath());

    QString s_subtitles = fi_subtitles.fileName();

    //QProcess ffmpeg;
    QString s_bitrate = QString::number(bitrate);
    s_bitrate += "k";
    QStringList arguments;
    arguments << "-i" << srcVideo;
    arguments << "-c:a" << "copy";
    arguments << "-c:v" << "libx264";
    arguments << "-b:v" << s_bitrate;
    arguments << "-vf" << "subtitles="+s_subtitles;
    arguments << outputVideo;

    ffmpeg.start("ffmpeg", arguments);
    processRunning = true;
    connect(&ffmpeg, SIGNAL(finished(int,QProcess::ExitStatus)), this, SLOT(itsDone()));
    connect(&ffmpeg, SIGNAL(readyReadStandardError()), this, SLOT(progressUpdate()));
    QDir::setCurrent(currentPath);
}

void VideoConverter::progressUpdate() {
    if(processRunning) {
        QString output = ffmpeg.readAllStandardError();
        QRegularExpression regex("time=([0-9]+:[0-9]+:[0-9]+)");
        QRegularExpressionMatch matches = regex.match(output);
        if(matches.capturedLength() > 0) {
            QString duration = matches.captured(1);
            QStringList parts = duration.split(":");
            int resultSeconds = 0;
            QString hours = parts.at(0);
            resultSeconds += hours.toInt() * 60 * 60;
            QString minutes = parts.at(1);
            resultSeconds += minutes.toInt() * 60;
            QString seconds = parts.at(2);
            resultSeconds += seconds.toInt();
            emit currentDurationChanged(resultSeconds);
        }
    }
}

void VideoConverter::itsDone() {
    processRunning = false;
    emit resultReady();
}

void VideoConverter::terminateProcess() {
    disconnect(&ffmpeg, SIGNAL(finished(int,QProcess::ExitStatus)), this, SLOT(itsDone()));
    connect(&ffmpeg, SIGNAL(finished(int,QProcess::ExitStatus)), this, SIGNAL(canDeleteObject()));
    ffmpeg.kill();
}

void VideoConverter::handleStopRequest() {
    disconnect(&ffmpeg, SIGNAL(finished(int,QProcess::ExitStatus)), this, SLOT(itsDone()));
    connect(&ffmpeg, SIGNAL(finished(int,QProcess::ExitStatus)), this, SIGNAL(cancelled()));
    ffmpeg.kill();
}
