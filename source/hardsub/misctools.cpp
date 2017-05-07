#include "misctools.h"
#include <QDesktopServices>
#include <QUrl>

void MiscTools::openDirectory(QString dir) {
    QDesktopServices::openUrl(QUrl(dir));
}
