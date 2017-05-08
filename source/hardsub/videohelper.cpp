#include "videohelper.h"
#include <QString>
#include <QStringList>
#include <QRegularExpression>
#include <QProcess>

#include "videoconverter.h"

VideoHelper::VideoHelper() {
    connect(vc, &VideoConverter::resultReady, this, &VideoHelper::handleResults);
    connect(vc, &VideoConverter::fileDoesNotExist, this, &VideoHelper::handleFileDoesNotExist);
    connect(vc, &VideoConverter::canDeleteObject, this, &VideoHelper::cleanupPointers);
    connect(vc, &VideoConverter::currentDurationChanged, this, &VideoHelper::handleDurationUpdate);
    connect(this, &VideoHelper::stopConversion, vc, &VideoConverter::handleStopRequest);
    connect(vc, &VideoConverter::cancelled, this, &VideoHelper::cancelled);
}

void VideoHelper::handleDurationUpdate(int duration) {
    emit currentDurationChanged(duration);
}

int VideoHelper::getBitrate(QString filename) {
    QProcess ffmpeg;
    ffmpeg.start("ffmpeg", QStringList() << "-i" << filename);
    ffmpeg.waitForFinished(5000);
    QString output = ffmpeg.readAllStandardError();
    QRegularExpression regex("[0-9]+ kb/s");
    QRegularExpressionMatch matches = regex.match(output);
    QString bitrate = matches.captured(0);
    bitrate = bitrate.replace(" kb/s", "");
    return bitrate.toInt();
}

int VideoHelper::getLength(QString filename) {
    QProcess ffmpeg;
    ffmpeg.start("ffmpeg", QStringList() << "-i" << filename);
    ffmpeg.waitForFinished(5000);
    QString output = ffmpeg.readAllStandardError();
    QRegularExpression regex("Duration: ([0-9]+:[0-9]+:[0-9]+)");
    QRegularExpressionMatch matches = regex.match(output);
    QString duration = matches.captured(1);
    QStringList parts = duration.split(":");
    int resultSeconds = 0;
    QString hours = parts.at(0);
    resultSeconds += hours.toInt() * 60 * 60;
    QString minutes = parts.at(1);
    resultSeconds += minutes.toInt() * 60;
    QString seconds = parts.at(2);
    resultSeconds += seconds.toInt();
    return resultSeconds;
}

void VideoHelper::handleResults() {
    emit resultReady();
}

void VideoHelper::handleFileDoesNotExist() {
    emit fileDoesNotExist();
}

void VideoHelper::initiateCleanup() {
    vc->terminateProcess();
}

void VideoHelper::cleanupPointers() {
    delete vc;
}

void VideoHelper::startConversion(const QString &srcVideo, const QString &subtitles, const QString &outputVideo, int bitrate) {
    vc->doWork(srcVideo, subtitles, outputVideo, bitrate);
}
