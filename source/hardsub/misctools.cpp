#include "misctools.h"
#include <QDesktopServices>
#include <QUrl>
#include <QString>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QProcess>
#include <QFile>
#include <QFileInfo>
#include <QDir>

MiscTools::MiscTools() {
    connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(handleVersionCheck(QNetworkReply*)));
}

MiscTools::~MiscTools() {
    delete networkManager;
}

bool MiscTools::moveFile(QString from, QString to) {
    QFile fromFile(from);
    if(!fromFile.exists()) {
        return false;
    }
    QFileInfo toFile(to);
    QDir toDir = toFile.absoluteDir();
    if(!toDir.exists() && !toDir.mkpath(".")) {
        return false;
    }
    return fromFile.rename(to);
}

void MiscTools::openDirectory(const QString dir) const {
    QDesktopServices::openUrl(QUrl(dir));
}

const QString MiscTools::getVersion() const {
    return "2.1.1";
}

const QString MiscTools::getVersionCheckURL() const {
    return "https://raw.githubusercontent.com/RikudouSage/hardsub-console/master/VERSION.txt";
}

const QString MiscTools::getReleasesURL() const {
    return "https://github.com/RikudouSage/hardsub-konzole/releases";
}

void MiscTools::checkNewVersion() {
    networkManager->get(QNetworkRequest(QUrl(getVersionCheckURL())));
}

void MiscTools::handleVersionCheck(QNetworkReply *reply) {
    QString remoteVersion = reply->readAll();
    if(!remoteVersion.isNull() && !remoteVersion.isEmpty() && remoteVersion != getVersion()) {
        emit newVersionAvailable(remoteVersion);
    }
}

bool MiscTools::binaryExists(const QString binary) const {
    QProcess check;
#if defined(Q_OS_WIN)
    QString command = "where "+binary;
#elif defined(Q_OS_LINUX)
    QString command = "which "+binary;
#endif
    check.start(command);
    check.waitForFinished(2000);
    int exitCode = check.exitCode();
    return exitCode == QProcess::NormalExit;
}

const QString MiscTools::getFilePrefix() const {
#if defined(Q_OS_WIN)
    return QString("file:///");
#elif defined(Q_OS_LINUX)
    return QString("file://");
#endif
}
