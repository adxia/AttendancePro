import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Layouts
import QtQuick.Effects

Popup {
    id: root
    width: 520
    height:480
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
        root.overlaycolor = "#99000000"
        enter.running = true
        opac = 1
        form = record
               ? Object.assign({}, record)   // 编辑
               : {                            // 新建
                   userName: "",
                   userID: 0,
                   userDepartment: "",
                   ruleName: "",
               }
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
           Keys.onReleased:(event)=> {
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
                    text:"员工名称"
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
                    leftpadding:20
                    ltext:"请输入员工名称"
                    text: root.form?.userName ?? ""
                    onTextChanged: root.form.userName = text
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
                    text:"员工工号"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }
                Search{
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
                         regularExpression: /^[0-9]+$/
                    }
                    ltext:"请输入员工工号"
                    text: root.form?.userID ?? ""
                    onTextChanged: {
                        root.form.userID = text
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
                    text:"所属项目"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }

              Search{
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
                    ltext:"请输入项目"
                    text: root.form?.userDepartment ?? ""
                    onTextChanged: {
                        root.form.userDepartment = text
                    }
                }

                Text{
                    id:tolerancetext
                    anchors.top:endtime.bottom
                    anchors.topMargin: 66
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    font.pointSize: 11
                    font.weight: 500
                    font.letterSpacing: 1.2
                    text:"考勤计算规则"
                    color:Theme[fileManager.themeColors].textSecondary
                    height: 20
                }

                LComboBox{
                    property bool ready: false
                    id:tolerance
                    anchors.left: parent.left
                    anchors.leftMargin:20
                    anchors.right: parent.right
                    anchors.rightMargin: 34
                    anchors.top:tolerancetext.bottom
                    anchors.topMargin: 10
                    lmodel: ready ? tableModel.ruleNames : ["请先新增计算规则"]
                    //lcurrentText: root.form ? root.form.ruleName : ""
                    lcurrentindex: root.form
                                   ? lmodel.indexOf(root.form.ruleName)
                                   : 0
                    onChanged: (index,text) => {
                        root.form.ruleName = text
                    }
                    Component.onCompleted: {
                           Qt.callLater(
                               () => ready = true
                               )
                       }
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
                        if(root.form.userName === "" || root.form.ruleName==="")
                        {
                            mainWindow.showMessage("error","姓名、使用规则不能为空")
                        }
                        else{
                            var a = personModel.applyRow(root.isEdit,root.editRow,root.form)
                            if(a){
                               root.closepopup()
                            }
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
