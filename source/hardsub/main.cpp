#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <QTranslator>
#include <QLocale>
#include <QDebug>

#include "videohelper.h"
#include "misctools.h"
#include "mkvtoolnixhelper.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QTranslator qtTranslator;
    qtTranslator.load(QLocale::system().name(), ":/localizations");
    app.installTranslator(&qtTranslator);

    VideoHelper vh;
    MiscTools mt;
    MKVToolnixHelper mkvhelper;

    QObject::connect(&app, &QGuiApplication::aboutToQuit, &vh, &VideoHelper::initiateCleanup);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("videohelper", &vh);
    engine.rootContext()->setContextProperty("misctools", &mt);
    engine.rootContext()->setContextProperty("mkvhelper", &mkvhelper);
    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
