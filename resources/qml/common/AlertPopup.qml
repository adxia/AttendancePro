import QtQuick
import QtQuick.Window
// import QtQuick.Controls.FluentWinUI3
import QtQuick.Controls.Basic

Popup {
    id: root
    modal: true
    x:(parent.width-width)/2
    y:(parent.height-height)/2
    focus: true
    width: 380
    height: 220
    padding: 0
    margins: 0
    property int topmargin:0
    Overlay.modal: Rectangle {
                anchors.fill: parent
                anchors.topMargin: topmargin
                color: "#99000000"
            }
    onOpened:{
        enter.running = true
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: 200;easing.type: Easing.InOutQuad; }
    }
    background:null
    property alias title: titleText.text
    property alias content: contentText.text
    signal accepted()
    signal rejected()
    Rectangle {
            anchors.fill: parent
           id:backgroundpopup
           color: Theme[fileManager.themeColors].itembackground
           radius: 10
           Behavior on color{
               ColorAnimation {
                   duration: 100
               }
           }
           ParallelAnimation{
               id:enter
               running:false
               ScaleAnimator {
                  target: backgroundpopup
                  from: 0.4
                  to: 1
                  duration: 140
               }
               OpacityAnimator{
                   target: backgroundpopup
                   from: 0
                   to: 1
                   duration: 140
               }
           }

           ParallelAnimation{
               id:exit
               running:false
               ScaleAnimator {
                  target: backgroundpopup
                  from: 1
                  to: 0.4
                  duration: 160

               }
               OpacityAnimator{
                   target: backgroundpopup
                   from: 1
                   to: 0
                   duration: 160
               }
               onStopped: root.close()
           }




    Column {
        // anchors.fill: parent
        anchors.top: parent.top
        anchors.bottom:parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        // spacing: 15

        Text {
            id: titleText
            text: "标题"
            font.pointSize: 18
            color:Theme[fileManager.themeColors].textPrimary
            font.weight: 600
            height:50
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: contentText
            text: "这里是内容"
            color:Theme[fileManager.themeColors].textPrimary
            height:90
            font.pointSize: 11
            font.letterSpacing: 1.2
            lineHeight: 1.2
            width:parent.width-20
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            spacing: 26
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                id:control
                checkable: true
                checked: true
                text: "取消"
                focus: true          // 关键
                    Keys.onPressed:function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            control.clicked()   // 调用你按钮的点击逻辑
                        }
                    }
                background: Rectangle {
                    id:controlb
                    implicitWidth: 90
                    implicitHeight:32
                    radius:4
                    color:control.hovered ? Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].buttonback
                    border.width: 0
                    Behavior on color{
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
                contentItem: Text {
                    text: control.text
                    color: control.hovered ? "#ffffff":Theme[fileManager.themeColors].textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.pointSize: 10
                    font.weight: 500
                    }
                onClicked: {
                    root.rejected()
                    exit.running = true
                }
            }
            Button {
                id:yes
                text: "确认"
                focus: true
                Keys.onPressed:function(event){
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        yes
                        .clicked()   // 调用你按钮的点击逻辑
                    }
                }
                background: Rectangle {
                    id:yesb
                    implicitWidth: 90
                    implicitHeight:32
                    radius:4
                    color:yes.hovered ? Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].buttonback
                    border.width: 0
                    Behavior on color{
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
                contentItem: Text {
                    text: yes.text
                    font.pointSize: 10
                    color: yes.hovered ? "#ffffff" : Theme[fileManager.themeColors].textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.weight: 500
                    }
                onClicked: {
                    root.accepted()
                    exit.running = true
                }
            }
        }
    }
    }
}
