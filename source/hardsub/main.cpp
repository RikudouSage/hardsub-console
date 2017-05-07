#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>

#include "videohelper.h"
#include "misctools.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    VideoHelper vh;
    MiscTools mt;

    QObject::connect(&app, QGuiApplication::aboutToQuit, &vh, VideoHelper::initiateCleanup);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("videohelper", &vh);
    engine.rootContext()->setContextProperty("misctools", &mt);
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
