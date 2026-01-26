import "../common"
import QtQuick

import QtQuick.Controls.Material
import Attendance 1.0
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts

MainView {
    signal change(string id)
    signal mica(int id)
    id: set
    //implicitWidth: 400
    implicitHeight: 600
    WindowUtil{
        id:windowutil
    }
    FolderDialog{
        id:savedialog
        title:"请选择要保存的路径"
        currentFolder:"./"
        onAccepted: {
            settings.savePath = selectedFolder.toString()
        }
    }
    Rectangle {
        id:root
        anchors.fill: parent
        color: "transparent"
    Item{
        id:back
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top:parent.top
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        Flickable{
            id: flick
            boundsBehavior: Flickable.StopAtBounds
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            clip: true
            contentWidth: parent.width
            contentHeight: content.implicitHeight + 10
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                background: Rectangle {
                    //anchors.fill: flick
                    implicitWidth: 6
                    radius: 0
                    color:"transparent"
                }
                contentItem: Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: 5
                    color:flick.pressed ? "#999999" : Theme[fileManager.themeColors].scrollbar
                }
            }
            ColumnLayout{
                id:content
                width:back.width
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 20
                Card{
                    Layout.alignment:Qt.AlignHCenter
                    width:parent.width - 40
                    // anchors.top:parent.top
                    // anchors.topMargin: 20
                    // anchors.left: parent.left
                    // anchors.leftMargin: 40
                    // anchors.right: parent.right
                    // anchors.rightMargin: 40
                    implicitWidth: Math.min(parent.width-40,1000)
                    implicitHeight: 250
                    id:systemsetting
                    titletext: "常规设置"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: systemsetting.focus = true
                    }

                    Text{
                        id:title
                        y:66
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        font.pointSize: 10.5
                        text:"保存路径"
                        font.weight: 400
                        font.letterSpacing: 1.2
                        color:Theme[fileManager.themeColors].textSecondary
                    }
                    Search{
                        id:search
                        anchors.left: parent.left
                        anchors.leftMargin:30
                        anchors.right: parent.right
                        anchors.rightMargin: 160
                        anchors.top: title.bottom
                        anchors.topMargin: 8
                        lheight:38
                        searchicon:false
                        leftpadding:20
                        ltext:"请选择输出文件保存路径.."
                        text:settings !== null?settings.savePath:""
                    }
                    RectangularShadow {
                        anchors.fill: importbtn
                        opacity: 0.4
                        offset.x: 0
                        offset.y: 0
                        radius: importbtn.lradius
                        blur: 10
                        spread: 0
                        color: Qt.darker(importbtn.lcolor, 1.2)
                    }
                    LButton{
                        anchors.top: search.top
                        anchors.left: search.right
                        anchors.leftMargin: -10
                        lwidth:120
                        id:importbtn
                        implicitHeight: 38
                        // implicitWidth: 120
                        prefixComponent: Component {
                            Text{
                                font.family: "Font Awesome 7 Free"
                                text:'\uf07c'
                                color:"#fefefe"
                                font.pointSize: 10
                                font.weight: 400
                            }
                        }
                        lspace: 6
                        prefixverticaloffset:0
                        horizontaloffset:0
                        verticalloffset:1
                        ltext:"选择文件夹"
                        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                        lfontcolor:lhovered?"#fefefe":"#fefefe"
                        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                        lfontsize: 10
                        lborder: 0
                        lradius: 4
                        lfontweight: 500
                        onClick:{savedialog.open()}

                    }
                    Text{
                        id:filesize
                        anchors.top:importbtn.bottom
                        anchors.topMargin: 40
                        anchors.left: parent.left
                        anchors.leftMargin:30
                        font.pointSize: 10.5
                        text:"输入文件大小限制"
                        font.weight: 400
                        font.letterSpacing: 1.2
                        color:Theme[fileManager.themeColors].textSecondary
                    }
                    Slider{
                        id:filesizeslider
                        anchors.top:filesize.bottom
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 160
                        width: 440
                        from:1
                        to:100
                        value: settings !== null ? settings.fileSize:5
                        onValueChanged: if(settings) settings.fileSize = value
                        Material.accent: Theme[fileManager.themeColors].primaryColor
                    }
                    Label {
                        anchors.top:filesize.bottom
                        anchors.topMargin: 14
                        anchors.left:filesizeslider.right
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 22
                        text: Math.round(filesizeslider.value)+" MB"
                        font.pointSize:11
                        color: Theme[fileManager.themeColors].textPrimary
                    }
                }
                Card{

                    Layout.alignment:Qt.AlignHCenter
                    width:parent.width - 40
                    // anchors.top:systemsetting.bottom
                    // anchors.topMargin: 20
                    // anchors.left: parent.left
                    // anchors.leftMargin: 40
                    // anchors.right: parent.right
                    // anchors.rightMargin: 40
                    implicitWidth: Math.min(parent.width-40,1000)
                    implicitHeight: 220
                    id:excelmapping
                    titletext: "Excel 映射配置"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: systemsetting.focus = true
                    }
                    Text{
                        id:model
                        y:66
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        font.pointSize: 10.5
                        text:"当前使用模板"
                        font.weight: 400
                        font.letterSpacing: 1.2
                        color:Theme[fileManager.themeColors].textSecondary
                    }
                    LComboBox{
                        property bool ready: false
                        id:modelselect
                        anchors.left: parent.left
                        anchors.leftMargin:30
                        anchors.right: parent.right
                        anchors.rightMargin: 160
                        anchors.top:model.bottom
                        anchors.topMargin: 10
                        lmodel: ready ? (templatemanager.templateNames.length === 0?["快新增模板吧！"]:templatemanager.templateNames):0
                        lcurrentindex:ready? (settings.modelName !== "" && templatemanager.templateNames.length !== 0) ? lmodel.indexOf(settings.modelName):0:0

                        onChanged: (index,text) => {
                            if(settings) settings.modelName = text
                        }
                        Component.onCompleted: {
                           Qt.callLater(
                               () => {
                                   ready = true
                               }
                            )
                           }
                        }
                    RectangularShadow {
                        anchors.fill: addmodelbtn
                        opacity: 0.4
                        offset.x: 0
                        offset.y: 0
                        radius: addmodelbtn.lradius
                        blur: 10
                        spread: 0
                        color: Qt.darker(addmodelbtn.lcolor, 1.1)
                    }
                    LButton{
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        anchors.top: modelselect.bottom
                        anchors.topMargin: 30
                        lwidth:130
                        id:addmodelbtn
                        implicitHeight: 36
                        prefixComponent: Component {
                            Text{
                                font.family: "bootstrap-icons"
                                text:'\uF4FE'
                                color:"#fefefe"
                                font.pointSize: 14
                                font.weight: 400
                            }
                        }
                        lspace: 0
                        prefixverticaloffset:0
                        horizontaloffset:0
                        verticalloffset:1
                        ltext:"新增模板"
                        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                        lfontcolor:lhovered?"#fefefe":"#fefefe"
                        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                        lfontsize: 10
                        lborder: 0
                        lradius: 4
                        lfontweight: 500
                        onClick:{
                            addmodel.record = null
                            addmodel.isEdit = false
                            addmodel.title = "新增Excel映射模板"
                            addmodel.open()
                        }

                    }
                    LButton{
                        id:editmodel
                        anchors.left: addmodelbtn.right
                        anchors.leftMargin:  20
                        anchors.top:  modelselect.bottom
                        anchors.topMargin: 30
                        implicitHeight: 36
                        implicitWidth: 130
                        ltext:"编辑模板"
                        lcolor:lhovered?Theme[fileManager.themeColors].primaryColor:Qt.darker(Theme[fileManager.themeColors].buttonback,1.1)
                        lbordercolor:lhovered?Theme[fileManager.themeColors].primaryColor:"transparent"
                        lfontcolor:lhovered?"#ffffff" : Theme[fileManager.themeColors].textPrimary
                        lfontsize: 10
                        lborder: 0
                        onClick:{
                            if(!settings.modelName | settings.modelName==="快新增模板吧！"){
                                showMessage("error","模型无法编辑","错误")
                            }
                            else{
                                addmodel.record = templatemanager.getTemplate(settings.modelName)
                                addmodel.isEdit = true
                                addmodel.title = "Excel映射模板编辑"
                                addmodel.open()
                            }

                            }
                    }
                }


                Card{
                    Layout.alignment:Qt.AlignHCenter
                    width:parent.width - 40
                    implicitWidth: Math.min(parent.width-40,1000)
                    implicitHeight: 310
                    id:apis
                    titletext: "节假日API配置"
                    MouseArea{
                        anchors.fill: parent
                        onClicked: systemsetting.focus = true
                    }
                    Text{
                        id:apiadress
                        y:66
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        font.pointSize: 10.5
                        text:"接口地址"
                        font.weight: 400
                        font.letterSpacing: 1.2
                        color:Theme[fileManager.themeColors].textSecondary
                    }
                    Search{
                        id:apiadressinput
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        anchors.right: parent.right
                        anchors.rightMargin: 160
                        anchors.top: apiadress.bottom
                        anchors.topMargin: 8
                        lheight:38
                        searchicon:false
                        leftpadding:20
                        ltext:"请输入接口地址"
                        text: settings !== null ? settings.apiPath: ""
                        onSearchText:(text)=>{
                                  settings.apiPath = text
                        }
                    }
                    Text{
                        id:time
                        anchors.top: apiadressinput.bottom
                        anchors.topMargin: 60
                        anchors.left: parent.left
                        anchors.leftMargin:  30
                        font.pointSize: 10.5
                        text:"超时时间(毫秒)"
                        font.weight: 400
                        font.letterSpacing: 1.2
                        color:Theme[fileManager.themeColors].textSecondary
                    }
                    Search{
                        id:timeinput
                        anchors.left: parent.left
                        anchors.leftMargin:  30
                        anchors.right: parent.right
                        anchors.rightMargin: 160
                        anchors.top: time.bottom
                        anchors.topMargin: 8
                        lheight:38
                        searchicon:false
                        leftpadding:20
                        ltext:"3000"
                        text: settings !== null ? settings.outTime: ""
                        onSearchText:(text)=>{
                            settings.outTime = text
                        }
                    }
                    LButton{
                        id:tsestid
                        anchors.left: sync.right
                        anchors.leftMargin:  20
                        anchors.top: timeinput.bottom
                        anchors.topMargin: 70
                        implicitHeight: 36
                        implicitWidth: 130
                        ltext:"测试链接"
                        lcolor:lhovered?Theme[fileManager.themeColors].primaryColor:Qt.darker(Theme[fileManager.themeColors].buttonback,1.1)
                        lbordercolor:lhovered?Theme[fileManager.themeColors].primaryColor:"transparent"
                        lfontcolor:lhovered?"#ffffff" : Theme[fileManager.themeColors].textPrimary
                        lfontsize: 10
                        lborder: 0
                        onClick:{
                            holidayserver.test()
                            }
                    }
                    RectangularShadow {
                        anchors.fill: sync
                        opacity: 0.4
                        offset.x: 0
                        offset.y: 0
                        radius: sync.lradius
                        blur: 10
                        spread: 0
                        color: Qt.darker(sync.lcolor, 1.1)
                    }
                    LButton{
                        anchors.left: parent.left
                        anchors.leftMargin:  30
                        anchors.top: timeinput.bottom
                        anchors.topMargin: 70
                        lwidth:130
                        id:sync
                        implicitHeight: 36
                        prefixComponent: Component {
                            Text{
                                font.family: "Font Awesome 7 Free"
                                text:'\uf063'
                                color:"#fefefe"
                                font.pointSize: 8
                                font.weight: 400
                            }
                        }
                        lspace: 6
                        prefixverticaloffset:0
                        horizontaloffset:0
                        verticalloffset:1
                        ltext:"开始同步"
                        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                        lfontcolor:lhovered?"#fefefe":"#fefefe"
                        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                        lfontsize: 10
                        lborder: 0
                        lradius: 4
                        lfontweight: 500
                        onClick:{holidayserver.updateFromApi()}
                    }
            }

          }
        }
    }

    }

}
