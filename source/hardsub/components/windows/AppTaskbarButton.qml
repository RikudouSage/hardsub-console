import QtQuick 2.7
import QtWinExtras 1.0

TaskbarButton {
    property alias current: progress.value
    property alias maximum: progress.maximum
    property alias progressVisible: progress.visible
    id: root
}
