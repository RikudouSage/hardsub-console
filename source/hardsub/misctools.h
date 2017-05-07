#ifndef MISCTOOLS_H
#define MISCTOOLS_H

#include <QObject>

class MiscTools : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE void openDirectory(QString dir);
};

#endif // MISCTOOLS_H
