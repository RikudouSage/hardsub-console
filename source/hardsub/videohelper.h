#ifndef VIDEOHELPER_H
#define VIDEOHELPER_H

#include <QObject>
#include <QString>
#include <QThread>

#include "videoconverter.h"

class VideoHelper : public QObject
{
    Q_OBJECT
    VideoConverter *vc = new VideoConverter;
public:
    VideoHelper();
    Q_INVOKABLE int getBitrate(QString filename);
    Q_INVOKABLE int getLength(QString filename);

public slots:
    void handleResults();
    void handleFileDoesNotExist();
    void initiateCleanup();
    void cleanupPointers();
    void startConversion(const QString &srcVideo, const QString &subtitles, const QString &outputVideo, int bitrate);
    void handleDurationUpdate(int duration);

signals:
    void resultReady();
    void fileDoesNotExist();
    void currentDurationChanged(int duration);
};

#endif // VIDEOHELPER_H
