import QtQuick

Item {
    id: rootItem
    property bool show: true
    property real showAnimated: show
    anchors.fill:parent
    scale: 0.9 + showAnimated * 0.1
    opacity: showAnimated
    width:500
    visible: opacity > 0

    Behavior on showAnimated {
        NumberAnimation {
            duration: 240
            easing.type: Easing.InOutCubic
        }
    }
}
