import QtQuick
import QtQuick.Window
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import QtQuick.Layouts

Popup {
    id: root
    property string title:"错误"
    property string content:"新消息"
    property int hinty
    property string mtype: "success"
    property string name
    signal popupclosed(string name)
    property real stackY: parent.height - height - (85 * mainWindow.popupStack.indexOf(name)-1)

    modal: false
    x:parent.width - width + 5
    y:stackY
    focus: true
    width: Math.min(Math.max(contetext.implicitWidth + 140,300),640)

    height: Math.max(105,width*0.18)
    opacity:0
    closePolicy: Popup.NoAutoClose

    Behavior on stackY {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

    Connections{
        target: mainWindow
        function onStackChange(){
           stackY =  parent.height - height - (85 * mainWindow.popupStack.indexOf(name)-1)
        }
    }
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 200 }
            NumberAnimation { target: root; property: "y"; from: parent.height; to:root.y; duration: 300; easing.type: Easing.OutCubic }
        }
    }
    exit:Transition {
        ParallelAnimation {
            NumberAnimation { target: root; property: "x"; from: root.x ; to:parent.width ; duration: 300; easing.type: Easing.OutCubic }
        }
    }
    background: Rectangle {
        color:"transparent"
        radius: 6
    }
    RectangularShadow {
        anchors.fill: rect
        opacity: 0.5
        offset.x: 0
        offset.y: 0
        radius: rect.radius
        blur: 10
        spread: 0
        color: fileManager.themeColors === "darkTheme"?Qt.darker(rect.color, 2.2):Qt.darker(rect.color, 1.4)
    }
    Rectangle {
            id: rect
            anchors.fill: parent
            radius: 6
            color: Theme[fileManager.themeColors].backgroundPrimary
            }
    // 自动关闭计时器
       Timer {
           id: autoCloseTimer
           interval:mtype === "success" ?2000:3000   // 3 秒
           repeat: false
           onTriggered: root.close()
       }
       onClosed: {
               root.popupclosed(root.name)

           }
       onOpened: {
           autoCloseTimer.start()
       }
        Rectangle{
            id:indenticon
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            width:28
            height: 28
            radius: 13
            color:mtype === "success"? "#52c41a":(mtype === "warning"?"#FFD54F":"#f24444")
            Text{
                anchors.centerIn: parent
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.top: parent.top
                anchors.topMargin: 5
                // anchors.centerIn: parent
                id: titleText
                text: mtype === "success" ? '\uF633':(mtype === "warning"?"\uF63C":"\uF62A")
                font.pointSize: 15
                color:"white"
                font.weight: 800
                font.family: "bootstrap-icons"
            }
        }
        ColumnLayout{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: indenticon.right
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 15
            spacing: 2
            Text {
                Layout.alignment:Qt.AlignLeft
                id:title
                text: root.title
                font.pointSize: 12
                color:Theme[fileManager.themeColors].textPrimary
                font.weight: 500
                horizontalAlignment:Text.AlignLeft
            }
            Text {
                Layout.alignment:Qt.AlignLeft
                Layout.preferredWidth: Math.min(implicitWidth, 500)
                Layout.maximumWidth: 500
                id:contetext
                text: root.content
                font.pointSize: 11
                color:Theme[fileManager.themeColors].textSecondary
                font.weight: 400
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WordWrap

            }

        }

    }


