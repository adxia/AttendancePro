import QtQuick
import QtQuick.Effects

Item {
    id:root
    property real bx: allstauts.x
    property real bw: allstauts.width
    property string name:"allstauts"
    height:46
    MouseArea{
        anchors.fill: parent
        onClicked:root.focus=true
    }

    Rectangle{
        id:titleline
        x:20
        y:16 + allstauts.height - 10
        height:2
        radius: 2
        width:parent.width - 40
        color:Theme[fileManager.themeColors].searchbackground
    }
    Rectangle{
        x:root.bx
        y:16 + allstauts.height -10
        height:2
        radius: 2
        width:root.bw
        color:Theme[fileManager.themeColors].primaryColor
        Behavior on width{
            NumberAnimation{
                duration: 160
            }
        }
        Behavior on x{
            XAnimator{
                duration: 160
            }
        }
    }
    Rectangle{
        y: 6
        id: allstauts
        anchors.left: parent.left
        anchors.leftMargin: 20
        width:allstext.implicitWidth+16
        height:40
        color:"transparent"
        Text {
            id:allstext
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "全部状态"
            font.letterSpacing: 1.3
            font.pointSize: 10.5
            color: root.name ==="allstauts"?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].textSecondary
            font.weight: 600
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{messagecenter.tabelchangemessage("allstauts");root.bx = allstauts.x;root.bw=allstauts.width;root.name = "allstauts"}
        }
    }
    Rectangle{
        y: 5
        id: await
        anchors.left: allstauts.right
        anchors.leftMargin: 16
        width:awaittext.implicitWidth+16
        height:40
        color:"transparent"
        Text {
            id:awaittext
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "待维护"
            font.letterSpacing: 1.3
            font.pointSize: 10.5
            color: root.name ==="await"?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].textSecondary
            font.weight: 600
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{messagecenter.tabelchangemessage("await");root.bx = await.x;root.bw=await.width;root.name = "await"}
        }
    }
    Rectangle{
        y: 5
        id: awaitcheck
        anchors.left: await.right
        anchors.leftMargin: 16
        width:awaitchecktext.implicitWidth+16
        height:40
        color:"transparent"
        Text {
            id:awaitchecktext
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "待检查"
            font.letterSpacing: 1.3
            font.pointSize: 10.5
            color: root.name ==="awaitcheck"?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].textSecondary
            font.weight: 600
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{messagecenter.tabelchangemessage("awaitcheck");root.bx = awaitcheck.x;root.bw=awaitcheck.width;root.name = "awaitcheck"}
        }
    }
    Rectangle{
        y: 5
        id: completed
        anchors.left: awaitcheck.right
        anchors.leftMargin: 16
        width:completedtext.implicitWidth+16
        height:40
        color:"transparent"
        Text {
            id:completedtext
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "已完成"
            font.letterSpacing: 1.3
            font.pointSize: 10.5
             color: root.name ==="completed"?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].textSecondary
            font.weight: 600
        }
        MouseArea{
            anchors.fill: parent
            onClicked:{messagecenter.tabelchangemessage("completed");root.bx = completed.x;root.bw=completed.width;root.name = "completed"}
        }
    }


    RectangularShadow {
        anchors.fill: refreshbtn
        opacity: 0.5
        offset.x: 0
        offset.y: 2
        radius: refreshbtn.lradius
        blur: 10
        spread: 0
        color: fileManager.themeColors==="darkTheme"?Qt.darker(refreshbtn.lcolor, 1.5): Qt.darker(refreshbtn.lcolor, 1.1)
        Behavior on y{
            YAnimator{
                duration: 200
            }
        }
    }
    LButton{
        y:lhovered?7:9
        id:refreshbtn
        anchors.right:parent.right
        anchors.rightMargin: 20
        implicitHeight: 32
        implicitWidth: 88
        Behavior on y{
            YAnimator{
                duration: 200
            }
        }
        prefixComponent: Component {
            Text{
                id:refersh
                font.family: "Font Awesome 7 Free"
                text:mainWindow.requestwait ? "\uF110":'\uf2f9'
                color:"#fefefe"
                font.pointSize: 8
                font.weight: 600
                RotationAnimator {
                   target: refersh;
                   from: 0;
                   to: 360;
                   loops: Animation.Infinite
                   duration: 500
                   running: mainWindow.requestwait
                }
            }


        }

        ltext:mainWindow.requestwait ?"刷新中..":"数据刷新"
        horizontaloffset:-1
        prefixverticaloffset:1
        lfontcolor:lhovered?"#fefefe":"#fefefe"
        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
        lfontsize: 10
        lborder:0
        lradius: 4
        lfontweight: 500
        onClick:{
            if(mainWindow.requestwait){
                showMessage("warning","正在获取数据中。。。")
            }
            else{
                mainWindow.requestwait=true;
                tableModel.getDataAsync();
            }
        }
    }
}
