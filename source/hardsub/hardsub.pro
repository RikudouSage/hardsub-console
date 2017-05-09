QT += qml quick
win32:QT += winextras

CONFIG += c++11

SOURCES += main.cpp \
    videohelper.cpp \
    videoconverter.cpp \
    misctools.cpp

RESOURCES += qml.qrc

win32:RESOURCES += windows.qrc
unix:RESOURCES += linux.qrc

RC_ICONS = icon.ico

DEFINES += QT_DEPRECATED_WARNINGS
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

TRANSLATIONS += localizations/cs_CZ.ts

HEADERS += \
    videohelper.h \
    videoconverter.h \
    misctools.h

lupdate_only {
    SOURCES += ./*.qml
}
