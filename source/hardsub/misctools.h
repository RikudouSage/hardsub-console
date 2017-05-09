#ifndef MISCTOOLS_H
#define MISCTOOLS_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>

class MiscTools : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ getVersion CONSTANT)
    Q_PROPERTY(QString versionCheckUrl READ getVersionCheckURL CONSTANT)
    Q_PROPERTY(QString releasesUrl READ getReleasesURL CONSTANT)
    Q_PROPERTY(QString filePrefix READ getFilePrefix CONSTANT)
    QNetworkAccessManager *networkManager = new QNetworkAccessManager(this);
public:
    MiscTools();
    ~MiscTools();
    Q_INVOKABLE void openDirectory(QString dir);
    Q_INVOKABLE void checkNewVersion();

private:
    QString getVersion();
    QString getVersionCheckURL();
    QString getFilePrefix();
    QString getReleasesURL();

private slots:
    void handleVersionCheck(QNetworkReply *reply);

signals:
    void newVersionAvailable(QString version);
};

#endif // MISCTOOLS_H
