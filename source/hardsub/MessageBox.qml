import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    function open() {
        root.visible = true;
    }
    property alias text: label.text
    property alias button1: okButton
    property alias button2: openButton
    property alias button3: button3

    id: root

    title: "MesageBox"
    width: 680
    minimumWidth: width
    maximumWidth: width
    height: 100
    minimumHeight: height
    maximumHeight: height
    visible: false
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowSystemMenuHint
    Label {
        id: label
        x: 20
        y: 20
        width: parent.width - x*2
        height: parent.height - 40 - y*2
        font.bold: true
        wrapMode: Text.Wrap
    }
    Row {
        x: 20
        y: label.y + label.height
        width: parent.width - x*2
        height: 100
        layoutDirection: Qt.RightToLeft
        spacing: 20
        Button {
            id: okButton
            visible: false
        }
        Button {
            id: openButton
            visible: false
        }
        Button {
            id: button3
            visible: false
        }
    }
}
