#ifndef MKVTOOLNIXHELPER_H
#define MKVTOOLNIXHELPER_H

#include <QObject>
#include <QStringList>
#include <QProcess>
#include <QVariantMap>

class MKVToolnixHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool loadingInfo READ loadingInfo WRITE setLoadingInfo NOTIFY loadingInfoChanged)
    Q_PROPERTY(bool errorLoadingInfo READ errorLoadingInfo WRITE setErrorLoadingInfo NOTIFY errorLoadingInfoChanged)
    Q_PROPERTY(bool resultsReady READ resultsReady WRITE setResultsReady NOTIFY resultsReadyChanged)
    QProcess *mkvinfo;
    QProcess *mkvmerge;
// qproperties
private:
    bool m_loadingInfo = false;
    bool m_errorLoadingInfo = false;
    bool m_resultsReady = false;
public:
    bool loadingInfo();
    void setLoadingInfo(bool loading);
    bool errorLoadingInfo();
    void setErrorLoadingInfo(bool loadingInfo);
    bool resultsReady();
    void setResultsReady(bool resultsReady);
signals:
    void loadingInfoChanged();
    void errorLoadingInfoChanged();
    void resultsReadyChanged();

// other methods
public:
    MKVToolnixHelper();
    Q_INVOKABLE void getTracksInfo(const QString file);

private slots:
    void handleMkvinfoResults(int exitCode);
    void handleMkvinfoError();
    void handleExtractSubtitlesRequest(QString videoFile, QStringList trackIDs);
    void handleExtractVideoRequest(QString videoFile, QString saveFile);
    void handleMkvmergeResults(int exitCode);
    void handleMkvmergeError();

signals:
    void resultsProcessed(QVariantMap results);
    void extractSubtitles(QString videoFile, QStringList trackIDs);
    void extractSubtitlesVideoDoesNotExist();
    void extractingSubtitlesStarted();
    void extractingSubtitlesDone(QStringList tempPaths);

    void extractVideo(QString videoFile, QString saveFile);
    void extractVideoDoesNotExist();
    void extractVideoDirDoesNotExist();
    void extractingVideoStarted();
    void extractingVideoFailed();
    void extractingVideoSucceeded();
};

#endif // MKVTOOLNIXHELPER_H
