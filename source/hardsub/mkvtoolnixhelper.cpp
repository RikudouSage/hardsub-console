#include "mkvtoolnixhelper.h"
#include <QStringList>
#include <QDebug>
#include <QProcess>
#include <QFile>
#include <QDir>

MKVToolnixHelper::MKVToolnixHelper() {
    mkvinfo = new QProcess(this);

    connect(mkvinfo, SIGNAL(finished(int)), this, SLOT(handleMkvinfoResults(int)));
    connect(mkvinfo, SIGNAL(error(QProcess::ProcessError)), this, SLOT(handleMkvinfoError()));

    connect(this, &MKVToolnixHelper::extractSubtitles, this, &MKVToolnixHelper::handleExtractSubtitlesRequest);
}

void MKVToolnixHelper::handleExtractSubtitlesRequest(QString videoFile, QStringList trackIDs) {
    QFile videoFileHandle(videoFile);
    if(!videoFileHandle.exists()) {
        emit extractSubtitlesVideoDoesNotExist();
        return;
    }
    emit extractingSubtitlesStarted();
    int i = 0;
    QStringList result;
    foreach (QString trackID, trackIDs) {
        QProcess process;
        QStringList arguments;
        QString filename(QDir::tempPath()+"/hardsub_subtitles"+QString::number(i));
        arguments << "tracks" << videoFile << trackID+":"+filename;
        process.start("mkvextract", arguments);
        process.waitForFinished();
        if(process.exitCode() == QProcess::NormalExit) {
            result << filename;
        }
        i++;
    }
    emit extractingSubtitlesDone(result);
}

void MKVToolnixHelper::handleMkvinfoResults(int exitCode) {
    setResultsReady(false);
    setLoadingInfo(false);
    if(exitCode != QProcess::NormalExit) {
        setErrorLoadingInfo(true);
        return;
    }
    QString result = mkvinfo->readAllStandardOutput();
    QVariantMap results;

    int startPos = 0;
    int i = 0;
    while(result.indexOf("A track", startPos) > -1) {
        QVariantMap item;
        QString itemName = "item"+QString::number(i);
        startPos = result.indexOf("A track", startPos) + 1;
        int trackID = result.mid(result.indexOf("track ID for mkvmerge & mkvextract: ", startPos) + 36, 1).toInt();
        QString trackType = result.mid(result.indexOf("Track type: ", startPos) + 12, 5);
        if(trackType == "subti") {
            trackType = "subtitles";
        }
        item.insert("id", trackID);
        item.insert("type", trackType);
        results.insert(itemName, item);
        i++;
    }

    setResultsReady(true);
    emit resultsProcessed(results);
}

void MKVToolnixHelper::handleMkvinfoError() {
    setResultsReady(false);
    setLoadingInfo(false);
    setErrorLoadingInfo(true);
}

void MKVToolnixHelper::getTracksInfo(const QString file) {
    setResultsReady(false);
    setErrorLoadingInfo(false);
    setLoadingInfo(true);
    QStringList args;
    args << "--ui-language" << "en";
    args << file;
    mkvinfo->start("mkvinfo", args);
}


// qproperties

bool MKVToolnixHelper::loadingInfo() {
    return m_loadingInfo;
}

void MKVToolnixHelper::setLoadingInfo(bool loading) {
    if(loading != m_loadingInfo) {
        m_loadingInfo = loading;
        emit loadingInfoChanged();
    }
}

bool MKVToolnixHelper::errorLoadingInfo() {
    return m_errorLoadingInfo;
}

void MKVToolnixHelper::setErrorLoadingInfo(bool loadingInfo) {
    if(loadingInfo != m_errorLoadingInfo) {
        m_errorLoadingInfo = loadingInfo;
        emit errorLoadingInfoChanged();
    }
}

bool MKVToolnixHelper::resultsReady() {
    return m_resultsReady;
}

void MKVToolnixHelper::setResultsReady(bool resultsReady) {
    if(resultsReady != m_resultsReady) {
        m_resultsReady = resultsReady;
        emit resultsReadyChanged();
    }
}
