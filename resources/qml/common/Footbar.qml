import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import Attendance

Item {
    id: footbar
    property int footbar_height:34
    WindowUtil{
        id:windowutils
    }
    BorderImage {
       opacity: fileManager.themeColors==="lightTheme"
       height: footbar.footbar_height
       width: parent.width
       anchors.bottom: parent.bottom
       anchors.bottomMargin: 5
       source: "qrc:/images/shadow_rect.png"
       border { left: 40; top: 20; right: 40; bottom: 10 }
    }
    Rectangle{
        id:footback
        height: footbar.footbar_height
        implicitWidth: parent.width
        anchors.bottom: parent.bottom
        anchors.margins: 0
        border.width: 0
        layer.enabled: true
        layer.smooth: true
        color:Theme[fileManager.themeColors].footback
        Rectangle{
            id:back
            width:parent.width
            height: parent.height
            color:parent.color
        }

        // Behavior on color{
        //     ColorAnimation {
        //                 duration: Theme.changetime   // 动画时长，毫秒
        //                 easing.type: Easing.Linear
        //             }
        // }
        Text{
            // anchors.verticalCenter:parent.verticalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.right:cpuname.left
            anchors.rightMargin: 10
            font.family:"Font Awesome 7 Free Solid"
            text:'\uf2db'
            font.pointSize: 11
            color:Theme[fileManager.themeColors].footprimary
        }

        Text{
            id:cpuname
            anchors.verticalCenter:parent.verticalCenter
            anchors.right:cpu.left
            anchors.rightMargin: 10
            text:'CPU:'
            font.pointSize: 9
            color:Theme[fileManager.themeColors].textSecondary
        }
        Timer {
            interval: 2400
            running: true
            repeat: true
            onTriggered: cpu.text = windowutils.getcpuUsage()
        }
        Text{
            id:cpu
            anchors.verticalCenter:parent.verticalCenter
            anchors.right:cpuicon.left
            anchors.rightMargin: 30
            text: windowutils.getcpuUsage()
            font.pointSize: 10
            color:Theme[fileManager.themeColors].textSecondary
        }

        //内存
        Text{
            id:cpuicon
            anchors.top: parent.top
            anchors.topMargin: 9
            anchors.right:memeryname.left
            anchors.rightMargin: 10
            font.family:"Font Awesome 7 Free Solid"
            text:'\uf538'
            font.pointSize: 11
            color:Theme[fileManager.themeColors].footprimary
        }

        Text{
            id:memeryname
            anchors.verticalCenter:parent.verticalCenter
            anchors.right:memory.left
            anchors.rightMargin: 10
            text:'内存:'
            font.pointSize: 9
            color:Theme[fileManager.themeColors].textSecondary
        }
        Timer {
            interval: 2400
            running: true
            repeat: true
            onTriggered: memory.text =windowutils.getMemoryUsage()
        }
        Text{
            id:memory
            anchors.verticalCenter:parent.verticalCenter
            anchors.right:parent.right
            anchors.rightMargin: 20
            text: windowutils.getMemoryUsage()
            font.pointSize: 9
            color:Theme[fileManager.themeColors].textSecondary
        }

    }

}
