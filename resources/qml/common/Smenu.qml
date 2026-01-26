pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Attendance

Item {
    id: root
    signal menuChanged(string menuid)
    property bool start: false
    property color themcolor
    property string tagglechange: "home"
    property int posy: 0
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    width: Theme.sliderwidth
    ListModel {
        id: menumodel
        ListElement {
            menuid: "home"
            label: "考勤处理"
            source: "bootstrap-icons"
            icon:'\uF3FC'
            iconpre:'\uF3FB'
        }
        ListElement {
            menuid: "rule"
            label: "规则配置"
            source: "bootstrap-icons"
            icon:'\uF1D8'
            iconpre:'\uF1D7'

        }
        ListElement {
            menuid: "setting"
            label: "系统设置"
            source: "bootstrap-icons"
            icon:'\uF3E5'
            iconpre:'\uF3E2'
        }
    }

    BorderImage {
        opacity: fileManager.themeColors==="lightTheme"
        width: drawer.width + 3
        height: root.height
        anchors.left:parent.left
        anchors.leftMargin: 2
       source: "qrc:/images/shadow_rect.png"
       border { left: 10; top: 10; right: 10; bottom: 10 }
    }

    Rectangle {
        id: drawer
        width: root.width
        height: root.height
        color:"transparent"
        Behavior on width{
            NumberAnimation{
                property: "width"
                duration: Theme.xchangetime  // 动画时长，毫秒
                easing.type: Easing.Linear

            }
        }
        Rectangle {
            anchors.fill: parent
            color: Theme[fileManager.themeColors].backgroundPrimary
            Behavior on color{
                ColorAnimation {
                            duration: Theme.changetime  // 动画时长，毫秒
                            easing.type: Easing.Linear
                        }
            }
            Rectangle {
                anchors.top: parent.top
                height: 50
                width: parent.width
                anchors.topMargin: 0
                color:"transparent"
                Behavior on color{
                    ColorAnimation {
                                duration: Theme.changetime // 动画时长，毫秒
                                easing.type: Easing.Linear
                            }
                }

                Row {
                    id: logo
                    spacing: 8
                    leftPadding:11
                    y:20
                    width: Theme.sliderwidth
                    height: 46
                    Rectangle{
                        id:sliderchange2
                        width:48
                        height:46
                        radius:6
                        color:Theme[fileManager.themeColors].backgroundPrimary
                        Text{
                            id:slidericon2
                            anchors.verticalCenter:parent.verticalCenter
                            anchors.horizontalCenter:parent.horizontalCenter
                            font.family:"bootstrap-icons"
                            //text:'\uF2CE'
                            text:'\uF3f3'
                            font.pointSize:14
                            color:Theme[fileManager.themeColors].primaryColor
                            font.weight: 500
                        }
                        Behavior on color{
                            ColorAnimation {
                                        duration: Theme.changetime   // 动画时长，毫秒
                                        easing.type: Easing.Linear
                                    }
                        }
                        MouseArea {
                            id: sliderArea2
                            anchors.fill: parent
                            hoverEnabled: true // 启用悬停检
                            onClicked:{
                                    titleBar.changeSlider();
                            }
                        }
                    }
                    Label {
                        // anchors.leftMargin: 40
                        leftPadding: -14
                        // y:20
                        anchors.verticalCenter: parent.verticalCenter
                        text: "AttendancePro"
                        color: Theme[fileManager.themeColors].textPrimary
                        font.pixelSize: 18
                        font.weight: 600
                        visible: Theme.sliderwidth === Theme.impliwidth
                    }
                }
                 }
                Rectangle {
                    id: background
                    x:10
                    width: Theme.sliderwidth - 20
                    height: 46
                    radius: 6
                    color: Theme[fileManager.themeColors].menubackground
                    y: menu.children[0].y
                    Behavior on color{
                        ColorAnimation {
                                    duration: Theme.changetime   // 动画时长，毫秒
                                    easing.type: Easing.Linear
                                }
                    }
                    Behavior on y {
                        YAnimator{
                            duration: 120
                            easing.type: Easing.Linear
                        }

                    }

                }
                Column {
                    id: menu
                    spacing: 14
                    topPadding: 110
                    width: Theme.sliderwidth
                    height: 0
                    Repeater {
                        model: menumodel
                        delegate: Rectangle {
                            id:menus
                            required property string menuid
                            required property string label
                            required property string source
                            required property string icon
                            required property string iconpre
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Theme.sliderwidth - 30
                            height: 46
                            radius: 10
                            color: "transParent"
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.tagglechange = menus.menuid
                                    background.y = parent.y
                                    root.menuChanged(menus.menuid)
                                }
                                Row {
                                    anchors.fill: parent
                                    spacing: 20
                                    leftPadding:9
                                    topPadding: 120

                                    Text{
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.verticalCenterOffset: 1
                                        font.family: menus.source
                                        font.pointSize:16
                                        text: menus.menuid == root.tagglechange ? menus.iconpre : menus.icon
                                        color: menus.menuid == root.tagglechange ? Theme[fileManager.themeColors].menuPrimary : Theme[fileManager.themeColors].textPrimary
                                    }


                                    Text {
                                        id: text
                                        opacity: Theme.sliderwidth === Theme.impliwidth
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: menus.label
                                        color: menus.menuid == root.tagglechange ? Theme[fileManager.themeColors].menuPrimary : Theme[fileManager.themeColors].textPrimary
                                        font.pointSize: 12
                                        font.weight: 400
                                    }

                                }
                            }
                        }
                    }
                }
        }
    }
}
