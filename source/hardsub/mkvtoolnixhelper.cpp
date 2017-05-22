#include "mkvtoolnixhelper.h"
#include <QStringList>
#include <QDebug>
#include <QProcess>
#include <QFile>
#include <QDir>

MKVToolnixHelper::MKVToolnixHelper() {
    mkvinfo = new QProcess(this);
    mkvmerge = new QProcess(this);

    connect(mkvinfo, SIGNAL(finished(int)), this, SLOT(handleMkvinfoResults(int)));
    connect(mkvinfo, SIGNAL(error(QProcess::ProcessError)), this, SLOT(handleMkvinfoError()));

    connect(mkvmerge, SIGNAL(finished(int)), this, SLOT(handleMkvmergeResults(int)));
    connect(mkvmerge, SIGNAL(error(QProcess::ProcessError)), this, SLOT(handleMkvmergeError()));

    connect(subtitlesProcess, SIGNAL(finished(int)), this, SLOT(handleSubtitlesResult()));
    //connect(subtitlesProcess, SIGNAL(error(QProcess::ProcessError)), this, SLOT(handleSubtitlesError()));

    connect(this, &MKVToolnixHelper::extractSubtitles, this, &MKVToolnixHelper::handleExtractSubtitlesRequest);
    connect(this, &MKVToolnixHelper::extractVideo, this, &MKVToolnixHelper::handleExtractVideoRequest);
}

void MKVToolnixHelper::handleMkvmergeResults(int exitCode) {
    if(exitCode != QProcess::NormalExit) {
        emit extractingVideoFailed();
        return;
    }
    emit extractingVideoSucceeded();
}

void MKVToolnixHelper::handleExtractVideoRequest(QString videoFile, QString saveFile) {
    QFile videoFileHandle(videoFile);
    if(!videoFileHandle.exists()) {
        emit extractVideoDoesNotExist();
        return;
    }
    QFileInfo saveFileHandle(saveFile);
    if(!saveFileHandle.absoluteDir().exists()) {
        emit extractVideoDirDoesNotExist();
        return;
    }
    QStringList arguments;
    arguments << "--ui-language" << "en";
    arguments << "-o" << saveFile << "--no-subtitles" << videoFile;
    mkvmerge->start("mkvmerge", arguments);
}

void MKVToolnixHelper::handleExtractSubtitlesRequest(QString videoFile, QStringList trackIDs) {
    QFile videoFileHandle(videoFile);
    if(!videoFileHandle.exists()) {
        emit extractSubtitlesVideoDoesNotExist();
        return;
    }

    m_currentVideoFile = videoFile;
    m_currentTrackIDs = trackIDs;

    m_totalSubtitlesTracks = trackIDs.length();

    if(m_currentSubtitleTrack == 0) {
        emit extractingSubtitlesStarted();
    }

    QString trackID = trackIDs.at(m_currentSubtitleTrack);

    QStringList arguments;
    m_currentSubtitleFilename = QString(QDir::tempPath()+"/hardsub_subtitles"+QString::number(m_currentSubtitleTrack));
    arguments << "tracks" << videoFile << trackID+":"+m_currentSubtitleFilename;
    subtitlesProcess->start("mkvextract", arguments);
}

void MKVToolnixHelper::handleSubtitlesResult() {
    m_subtitleTracks << m_currentSubtitleFilename;
    m_currentSubtitleTrack++;
    if(m_currentSubtitleTrack == m_totalSubtitlesTracks) {
        emit extractingSubtitlesDone(m_subtitleTracks);
        m_totalSubtitlesTracks = 0;
        m_currentSubtitleTrack = 0;
        m_subtitleTracks = QStringList();
        m_currentSubtitleFilename = QString();
        m_currentVideoFile = QString();
        m_currentTrackIDs = QStringList();
    } else {
        handleExtractSubtitlesRequest(m_currentVideoFile, m_currentTrackIDs);
    }
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

void MKVToolnixHelper::handleMkvmergeError() {
    emit extractingVideoFailed();
}

void MKVToolnixHelper::getTracksInfo(const QString file) {
    setResultsReady(false);
    setErrorLoadingInfo(false);
    setLoadingInfo(true);
    QProcess mkvinfoLngCheck;
    mkvinfoLngCheck.start("mkvinfo", QStringList() << "--ui-language" << "list");
    mkvinfoLngCheck.waitForFinished(1500);
    QString stdOut = mkvinfoLngCheck.readAllStandardOutput();
    QString lng;
    if(stdOut.indexOf("en_US ") > -1) {
        lng = "en_US";
    } else if(stdOut.indexOf("en ") > -1) {
        lng = "en";
    } else {
        setLoadingInfo(false);
        setErrorLoadingInfo(true);
        return;
    }
    QStringList args;
    args << "--ui-language" << lng;
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
