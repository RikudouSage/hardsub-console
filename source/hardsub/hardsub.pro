QT += qml quick

CONFIG += c++11

SOURCES += main.cpp \
    videohelper.cpp \
    videoconverter.cpp \
    misctools.cpp

RESOURCES += qml.qrc

RC_ICONS = icon.ico

DEFINES += QT_DEPRECATED_WARNINGS
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    videohelper.h \
    videoconverter.h \
    misctools.h