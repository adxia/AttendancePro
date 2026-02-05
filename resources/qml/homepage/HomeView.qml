// pragma ComponentBehavior: Bound
import "../common"
import QtQuick
import QtQuick.Controls.Fusion
import Attendance 1.0
import QtQuick.Effects
import QtQuick.Dialogs
import QtQuick.Layouts

MainView {
    signal changes(string name)
    property var selectedFiles: ({})
    id: home
    FolderDialog{
        id:savedialog
        title:"请选择要保存的路径"
        currentFolder:"./"
        onAccepted: {
            console.log("用户选择保存路径:", selectedFolder)
        }
    }
    Rectangle{
        id:banner
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left:parent.left
        anchors.right: parent.right
        height:120
        radius:10
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        color:Theme[fileManager.themeColors].Toast
        Text {
            id: text
            x:30
            y:20
            text: "小贴示"
            font.pixelSize: 18
            font.letterSpacing: 4
            color: Theme[fileManager.themeColors].textPrimary
            font.bold: true
            font.weight: 550
        }
        Text {
            id:cont
            x:30
            y:54
            text: "1、计算规则现支持自定义，支持自定义Excel输入/输出模板。\n2、节假日数据可在线更新,执行效率提升300%。"
            font.pixelSize: 14
            font.letterSpacing: 1.4
            lineHeight: 1.3
            lineHeightMode: Text.ProportionalHeight
            color: Theme[fileManager.themeColors].textSecondary
            //color:"white"
            font.weight: 400
        }

    }
    RectangularShadow {
        anchors.fill: name
        opacity: 0.05
        offset.x: 0
        offset.y: 0
        radius: name.radius
        blur: 10
        spread: 0
        color: Qt.darker(name.lcolor, 1.4)
    }
    Rectangle{
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: banner.bottom
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 20
        height:120
        radius:10
        color:Theme[fileManager.themeColors].backgroundPrimary
        id:name
        RowLayout {
            id:tabname
            spacing: 2
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.left:parent.left
            anchors.right: parent.right
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            Rectangle {
                Layout.alignment:Qt.AlignVCenter
                width: 3
                height: 14
                radius: 1.5
                color: "#5C67FA"   // 主题色
            }
            Text {
                id: selectmodel
                text: "模式选择"
                font.pixelSize: 15
                font.letterSpacing: 1.1
                color: Theme[fileManager.themeColors].textPrimary
                font.weight: 700
            }
            Text {
                id: selectexplan
                Layout.alignment:Qt.AlignRight | Qt.AlignVCenter
                text: "没有作用，但是美观?"
                font.pixelSize: 13
                font.letterSpacing: 1
                color: Theme[fileManager.themeColors].textTertiary
                font.weight: 400
            }

        }
        LTabs{
            id: tabs
            anchors.top: tabname.bottom
            anchors.topMargin: 15
            anchors.left:parent.left
            anchors.right: parent.right
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            model: ["默认全部", "正式工", "劳务工"]
            onCurrentChanged: index => {
                // console.log("当前 Tab:", index)
            }
        }
    }
    RectangularShadow {
        anchors.fill: filecard
        opacity: 0.05
        offset.x: 0
        offset.y: 0
        radius: filecard.radius
        blur: 10
        spread: 0
        color: Qt.darker(filecard.lcolor, 1.4)
    }
    Rectangle{
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: name.bottom
        anchors.leftMargin: 32
        anchors.rightMargin: 32
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        //height:430
        radius:10
        color:Theme[fileManager.themeColors].backgroundPrimary
        id:filecard
        RowLayout {
            id:file
            spacing: 8
            anchors.top: filecard.top
            anchors.topMargin: 20
            anchors.left:parent.left
            anchors.right: parent.right
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            Rectangle {
                Layout.alignment: Qt.AlignVCenter

                width: 3
                height: 14
                radius: 1.5
                color: "#5C67FA"   // 主题色
            }
            Text {
                id: selectfile
                text: "文件选择"
                font.pixelSize: 15
                font.letterSpacing: 1.1
                color: Theme[fileManager.themeColors].textPrimary
                font.weight: 700
            }
            Text {
                id: fileeplan
                Layout.alignment:Qt.AlignRight | Qt.AlignVCenter
                text: "这个真有用！"
                font.pixelSize: 13
                font.letterSpacing: 1
                color: Theme[fileManager.themeColors].textTertiary
                font.weight: 400
            }
        }
    ListModel {
        id: fileinputmodel
        ListElement {
            title: "打卡记录"
            placeorder: "请选择文件..."
            icon:"\uf017"
        }
        ListElement {
            title: "模板1"
            placeorder: "请选择文件..."
            icon:"\uf0ce"
        }
        ListElement {
            title: "模板2"
            placeorder: "请选择文件..."
            icon:"\uf133"
        }
    }
    ColumnLayout {
        id:fileinput
        anchors.top: file.bottom
        anchors.topMargin: 20
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        anchors.margins: 4
        spacing: 20
        Repeater{
            model:fileinputmodel
            FileSelectInput {
                icon:model.icon
                Layout.fillWidth: true
                title: model.title
                nameFilters: ["Excel 文件 (*.xlsx *.xls)"]

                onFileSelected: path => {
                    selectedFiles[model.title] = path
                    if(title === "打卡记录"){
                        pipeline.preloadInputFile(path,holidayserver,ruleserver)
                    }
                }
            }

        }
    }
    RectangularShadow {
        anchors.fill: startbtn
        opacity: 0.2
        offset.x: 0
        offset.y: 8
        radius: startbtn.lradius
        blur: 10
        spread: 0
        color: Qt.darker(startbtn.lcolor, 1.4)
    }
    LButton{
        id:startbtn
        anchors.top: fileinput.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 40
        lwidth:180
        prefixComponent: Component {
            Text{
                id:refersh
                visible: true
                font.family: "Font Awesome 7 Free"
                text:'\uf04b'
                color:"#fefefe"
                font.pointSize: 10
                font.weight: 400
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
        implicitHeight: 42
        prefixverticaloffset:0
        horizontaloffset:0
        verticalloffset:1
        ltext:mainWindow.requestwait ?"执行中...":"确认开始"
        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
        lfontcolor:lhovered?"#fefefe":"#fefefe"
        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
        lfontsize: 13
        lborder: 0
        lradius: 10
        lfontweight: 500
        onClick:{
            mainWindow.requestwait=true
            pipeline.startRun(selectedFiles["打卡记录"],selectedFiles["模板1"],selectedFiles["模板2"],ruleserver)
        }

    }
    }

}



