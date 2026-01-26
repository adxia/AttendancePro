import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id:root
    property bool title: true
    property string titletext: "新标题"
    implicitHeight: 200
    implicitWidth: parent.width
    RectangularShadow {
        anchors.fill: background
        opacity: 0.6
        offset.x: 0
        offset.y: 0
        radius: background.radius
        blur: 10
        spread: 0
        color: Qt.darker(background.color, 1.1)
    }
    Rectangle{
        id:background
        anchors.fill: parent
        color:Theme[fileManager.themeColors].backgroundPrimary
        radius:6
        Behavior on color{
            ColorAnimation {
                        duration: Theme.changetime  // 动画时长，毫秒
                        easing.type: Easing.Linear
                    }
        }
    }
    // Rectangle{
    //     anchors.top: parent.top
    //     anchors.left:parent.left
    //     anchors.right: parent.right
    //     id:title
    //     visible:root.title
    //     height:48
    //     color:"transparent"
    //     Text{
    //         anchors.verticalCenter: parent.verticalCenter
    //         anchors.left: parent.left
    //         anchors.leftMargin: 20
    //         font.pointSize: 11
    //         text:root.titletext
    //         font.weight: 500
    //         font.letterSpacing: 1.3
    //         color:Theme[fileManager.themeColors].textPrimary
    //     }
    // }
    RowLayout {
        id:title
        spacing: 8
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.left:parent.left
        anchors.leftMargin: 30
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 3
            height: 14
            radius: 1.5
            color: "#5C67FA"   // 主题色
        }
        Text {
            id: selectfile
            text: root.titletext
            font.pixelSize: 15
            font.letterSpacing: 1.1
            color: Theme[fileManager.themeColors].textPrimary
            font.weight: 700
        }
    }

    Rectangle{
        id:titleline
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: title.bottom
        anchors.topMargin: 10
        height:1
        radius: 2
        width:parent.width - 40
        color:Theme[fileManager.themeColors].searchbackground
        Behavior on color{
            ColorAnimation {
                        duration: Theme.changetime  // 动画时长，毫秒
                        easing.type: Easing.Linear
                    }
        }
    }

}
