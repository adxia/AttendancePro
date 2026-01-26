import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Layouts
import QtQuick.Effects

Popup {
    id: root
    width: 580
    height:660
    modal: true
    focus: true
    x:(parent.width-width)/2
    y:(parent.height-height)/2

    closePolicy: Popup.NoAutoClose
    property string title: "计算规则新增"
    property real dragStartX
    property real dragStartY
    property int topmargin:0
    property real lscale:1
    property real rotate:0
    property color overlaycolor:"#99000000"
    property int  opac: 1
    property int centerIndex:-1
    property bool isEdit: false
    property int editRow: -1
    property var record: null
    property var form: ({})

    Overlay.modal:Rectangle {
        id:back
        anchors.fill: parent
        anchors.topMargin: topmargin
        color: root.overlaycolor
    }
    background:null
    onOpened:{
        if(!isEdit){
            starttime.text = ""
            endtime.text = ""
        }
        root.overlaycolor = "#99000000"
        enter.running = true
        opac = 1
        form = record
               ? Object.assign({}, record)   // 编辑
               : {                            // 新建
                   ruleName: "",
                   standardStart: "",
                   standardEnd: "",
                   standardHours: 8,
                   lunchStar:"",
                   lunchEnd:"",
                   latetolerance: 0,
                   leaveEarlytolerance:0
               }
        starttime.text = root.form.standardStart
        endtime.text = root.form.standardEnd
        lunchstartime.text = root.form.lunchStar
        lunchendtime.text = root.form.lunchEnd
    }

    function closepopup(){
        opac = 0
        root.overlaycolor = "#00000000"
        exitopacity.running=true
    }
    Behavior on overlaycolor{
        ColorAnimation {
            duration: 160
        }
    }

    // 内容区域放这里
    Rectangle {
           anchors.fill: parent
           id:backgroundpopup
           color: Theme[fileManager.themeColors].itembackground
           radius: 10
           clip:true
           focus:true

           Keys.onReleased: (event)=>{
               if (event.key === Qt.Key_Escape) {
                  root.closepopup()
               }
           }
           Behavior on color{
               ColorAnimation {
                   duration: 100
               }
           }
           ParallelAnimation{
               id:enter
               running:false
               YAnimator {
                  target: backgroundpopup
                  from: 40
                  to: 0
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
               id:exitopacity
               running:false
               YAnimator {
                  target: backgroundpopup
                  to: -40
                  duration: 160
               }
               OpacityAnimator{
                   target: backgroundpopup
                   from: 1
                   to: 0
                   duration: 160
               }
               onFinished:root.close()
           }
           Rectangle{
                width:parent.width - 20
                height:parent.height -20
                anchors.centerIn: parent
                color:"transparent"
                Rectangle{
                    id:title
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    anchors.right: parent.right
                    anchors.left: parent.left
                    height:40
                    color:"transparent"
                    Text{
                        anchors.left: parent.left
                        anchors.leftMargin:20

                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 13
                        font.weight: 600
                        font.letterSpacing: 1.2
                        text:root.title
                        color:Theme[fileManager.themeColors].textPrimary
                    }

                }
                Rectangle{
                    id:line
                    anchors.top:title.bottom
                    anchors.topMargin: 10
                    height:2
                    width:parent.width-20
                    anchors.horizontalCenter: parent.horizontalCenter
                    color:Qt.darker(Theme[fileManager.themeColors].searchbackground,1.02)
                }

                Text{
                    id:nametext
                    anchors.top:line.bottom
                    anchors.topMargin: 16
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"规则名称"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    id:name
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top:nametext.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    read:root.form?.ruleName === "general"
                    leftpadding:20
                    ltext:"请输入规则名"
                    text: root.form?.ruleName ?? ""
                    onTextChanged: root.form.ruleName = text
                }

                Text{
                    id:starttimetext
                    anchors.top:name.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"上班时间"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    property int lastLength: 0
                    id:starttime
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width/2 + 10
                    anchors.top:starttimetext.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    //mask:"99:99"
                    lvalidator: RegularExpressionValidator {
                        regularExpression: /^$|^(?:0?\d|1\d|2[0-3])(?:[:：](?:[0-5]?\d)?)?$/
                    }
                    ltext:"请输入上班时间"
                    text: root.form?.standardStart ?? ""
                    onTextChanged:  {
                        let increasing = text.length > lastLength
                        if(increasing){
                            if (text.indexOf("：") >= 0) {
                                text = text.replace(/：/g, ":") // 全局替换中文冒号
                            }
                            if (parseInt(text) > 2 && parseInt(text)<25 && text.indexOf(":") === -1) {
                                if(text.length===1){
                                   text = "0"+ text + ":"
                                }
                                else{
                                  text = text + ":"
                                }
                            }
                            else if(text.length === 2 && parseInt(text)< 3 && text.indexOf(":") === -1){
                                text = text + ":"
                            }
                        }
                        lastLength = text.length
                        root.form.standardStart = text
                    }
                }


                Text{
                    id:endtimetext
                    anchors.top:name.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:parent.width/2 + 10
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"下班时间"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    property int lastLength: 0
                    id:endtime
                    anchors.left: parent.left
                    anchors.leftMargin:parent.width/2 + 10
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top:starttimetext.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    lvalidator: RegularExpressionValidator {
                         regularExpression: /^$|^(?:0?\d|1\d|2[0-3])(?:[:：](?:[0-5]?\d)?)?$/
                    }
                    ltext:"请输入下班时间"
                    text: root.form?.standardEnd ?? ""
                    onTextChanged: {
                        let increasing = text.length > lastLength
                        if(increasing){
                            if (text.indexOf("：") >= 0) {
                                text = text.replace(/：/g, ":") // 全局替换中文冒号
                            }
                            if (parseInt(text) > 2 && parseInt(text)<25 && text.indexOf(":") === -1) {
                                if(text.length===1){
                                   text = "0"+ text + ":"
                                }
                                else{
                                  text = text + ":"
                                }
                            }
                            else if(text.length === 2 && parseInt(text)< 3 && text.indexOf(":") === -1){
                                text = text + ":"
                            }
                        }
                        lastLength = text.length
                        root.form.standardEnd = text
                    }
                }

                Text{
                    id:lunchstar
                    anchors.top:endtime.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"午休开始时间"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    property int lastLength: 0
                    id:lunchstartime
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width/2 + 10
                    anchors.top:lunchstar.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    lvalidator: RegularExpressionValidator {
                         regularExpression: /^$|^(?:0?\d|1\d|2[0-3])(?:[:：](?:[0-5]?\d)?)?$/
                    }
                    ltext:"请输入午休开始时间"
                    text: root.form?.lunchStar ?? ""
                    onTextChanged: {
                        let increasing = text.length > lastLength
                        if(increasing){
                            if (text.indexOf("：") >= 0) {
                                text = text.replace(/：/g, ":") // 全局替换中文冒号
                            }
                            if (parseInt(text) > 2 && parseInt(text)<25 && text.indexOf(":") === -1) {
                                if(text.length===1){
                                   text = "0"+ text + ":"
                                }
                                else{
                                  text = text + ":"
                                }
                            }
                            else if(text.length === 2 && parseInt(text)< 3 && text.indexOf(":") === -1){
                                text = text + ":"
                            }
                        }
                        lastLength = text.length
                        root.form.lunchStar = text
                    }
                }


                Text{
                    id:lunchend
                    anchors.top:endtime.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:parent.width/2 +10
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"午休结束时间"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    property int lastLength: 0
                    id:lunchendtime
                    anchors.left: parent.left
                    anchors.leftMargin:parent.width/2 +10
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top:lunchend.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    lvalidator: RegularExpressionValidator {
                         regularExpression: /^$|^(?:0?\d|1\d|2[0-3])(?:[:：](?:[0-5]?\d)?)?$/
                    }
                    ltext:"请输入午休结束时间"
                    text: root.form?.lunchEnd ?? ""
                    onTextChanged: {
                        let increasing = text.length > lastLength
                        if(increasing){
                            if (text.indexOf("：") >= 0) {
                                text = text.replace(/：/g, ":") // 全局替换中文冒号
                            }
                            if (parseInt(text) > 2 && parseInt(text)<25 && text.indexOf(":") === -1) {
                                if(text.length===1){
                                   text = "0"+ text + ":"
                                }
                                else{
                                  text = text + ":"
                                }
                            }
                            else if(text.length === 2 && parseInt(text)< 3 && text.indexOf(":") === -1){
                                text = text + ":"
                            }
                        }
                        lastLength = text.length
                        root.form.lunchEnd = text
                    }
                }


                Text{
                    id:hourstext
                    anchors.top:lunchstartime.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"上班时长(0.5-24 小时)"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    id:hours
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top:hourstext.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    lvalidator: RegularExpressionValidator {
                         regularExpression: /^(?:$|(?:[0-9]|1[0-9]|2[0-3])(?:\.5)?|24 ?)$/
                    }
                    ltext:"请输入上班时长"
                    text: root.form?.standardHours ?? ""
                    onTextChanged: root.form.standardHours = text

                }

                Text{
                    id:tolerancetext
                    anchors.top:hours.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"迟到阈值(分钟)"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    id:tolerance
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width/2 + 10
                    anchors.top:tolerancetext.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    lvalidator: RegularExpressionValidator {
                         regularExpression: /^(?:$|[0-9]|[1-5][0-9]|60)$/
                    }
                    ltext:"请输入迟到阈值"
                    text: root.form?.latetolerance ?? ""
                    onTextChanged: root.form.latetolerance = text
                }

                Text{
                    id:leaveEarlytext
                    anchors.top:hours.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:parent.width/2 + 10
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"早退阈值(分钟)"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
                    id:leaveEarly
                    anchors.left: parent.left
                    anchors.leftMargin:parent.width/2 + 10
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top:tolerancetext.bottom
                    anchors.topMargin: 10
                    lheight:38
                    searchicon:false
                    leftpadding:20
                    lvalidator: RegularExpressionValidator {
                         regularExpression: /^(?:$|[0-9]|[1-5][0-9]|60)$/
                    }

                    ltext:"请输入早退阈值"
                    text: root.form?.leaveEarlytolerance ?? ""
                    onTextChanged: root.form.leaveEarlytolerance = text
                }



                LButton{
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    anchors.right:save.left
                    anchors.rightMargin: 20
                    implicitHeight: 34
                    implicitWidth: 88
                    ltext:"关闭"
                    lcolor:lhovered?Theme[fileManager.themeColors].primaryColor:Qt.darker(Theme[fileManager.themeColors].buttonback,1.05)
                    lbordercolor:lhovered?Theme[fileManager.themeColors].primaryColor:"transparent"
                    lfontcolor:lhovered?"#ffffff" : Theme[fileManager.themeColors].textPrimary
                    lfontsize: 10
                    lborder: 0
                    onClick:{
                        root.closepopup()
                    }
                }

                LButton{
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 20
                    anchors.right:parent.right
                    anchors.rightMargin: 30
                    lwidth:88
                    id:save
                    implicitHeight: 34
                    lspace: 6
                    prefixverticaloffset:0
                    horizontaloffset:0
                    verticalloffset:1
                    ltext:"确 定"
                    lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                    lfontcolor:lhovered?"#fefefe":"#fefefe"
                    lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                    lfontsize: 10
                    lborder: 0
                    lradius: 4
                    lfontweight: 500
                    onClick:{
                        if(root.form.ruleName === "" || root.form.standardStart==="" || root.form.standardEnd==="" )
                        {
                            mainWindow.showMessage("error","规则名、上班时间、下班时间不能为空")
                            return
                        }
                        var a = tableModel.applyRow(root.isEdit,root.editRow,root.form)
                        if(a){
                           root.closepopup()
                        }

                    }

                }

           }
        }


    Behavior on lscale{
        NumberAnimation{
            duration: 100
        }
    }
    Behavior on rotate{
        NumberAnimation{
            duration: 100
        }
    }

}
