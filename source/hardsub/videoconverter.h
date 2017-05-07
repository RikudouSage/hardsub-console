#ifndef VIDEOCONVERTER_H
#define VIDEOCONVERTER_H

#include <QObject>
#include <QString>
#include <QProcess>

class VideoConverter : public QObject
{
    Q_OBJECT
    QProcess ffmpeg;
    bool processRunning = false;
public slots:
    void doWork(const QString &srcVideo, const QString &subtitles, const QString &outputVideo, int bitrate);
    void itsDone();
    void terminateProcess();
    void progressUpdate();
signals:
    void resultReady();
    void fileDoesNotExist();
    void canDeleteObject();
    void currentDurationChanged(int duration);
};

#endif // VIDEOCONVERTER_H
