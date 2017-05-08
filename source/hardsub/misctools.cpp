#include "misctools.h"
#include <QDesktopServices>
#include <QUrl>
#include <QString>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>

MiscTools::MiscTools() {
    connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(handleVersionCheck(QNetworkReply*)));
}

MiscTools::~MiscTools() {
    delete networkManager;
}

void MiscTools::openDirectory(QString dir) {
    QDesktopServices::openUrl(QUrl(dir));
}

QString MiscTools::getVersion() {
    return "2.1.1";
}

QString MiscTools::getVersionCheckURL() {
    return "https://raw.githubusercontent.com/RikudouSage/hardsub-konzole/master/VERSION.txt";
}

QString MiscTools::getReleasesURL() {
    return "https://github.com/RikudouSage/hardsub-konzole/releases";
}

void MiscTools::checkNewVersion() {
    networkManager->get(QNetworkRequest(QUrl(getVersionCheckURL())));
}

void MiscTools::handleVersionCheck(QNetworkReply *reply) {
    QString remoteVersion = reply->readAll();
    if(remoteVersion != getVersion()) {
        emit newVersionAvailable(remoteVersion);
    }
}
