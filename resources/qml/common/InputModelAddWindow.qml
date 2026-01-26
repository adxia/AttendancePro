import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs

Popup {
    id: root
    width:Math.max(parent.width*0.5,680)
    height:Math.min(parent.height*0.85,740)
    modal: true
    focus: true
    x:(parent.width-width)/2
    y:(parent.height-height)/2

    closePolicy: Popup.NoAutoClose
    property string title: ""
    property real dragStartX
    property real dragStartY
    property int topmargin:0
    property real lscale:1
    property real rotate:0
    property color overlaycolor:"#99000000"
    property int  opac: 1
    property int centerIndex:-1
    property bool isEdit: false
    property var record: null
    property var form: ({})

    ColorDialog {
        property var picked
        options: ColorDialog.DontUseNativeDialog
        id: colorDialog
        title: "选择颜色"
        onAccepted: {
            if(picked){
              picked(colorDialog.selectedColor)
            }
        }
    }

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
                    // ===== 模板基础信息 =====
                     modelName: "",            // 模板名称
                     inputType:"",
                     inputSheetName: "",              // 输入 Sheet 名称 / 写入 Sheet 名称（复用）
                     inputuserColumn: "",      // 姓名列号 / 写入起始行（复用）
                     inputdateColumn: "",             // 日期列号 / 写入起始列号 / 日期格式（被复用）
                     attendanceTime:"",
                     // ===== 输入映射（考勤原始表）=====
                     signInColumn: "",        // 签到时间列号（C）
                     signOutColumn: "",       // 签退时间列号（D）

                     // ===== 正式工表配置 =====
                     formalSheetName: "",     // 写入 Sheet 名称
                     formalStartRow: "",      // 写入起始行
                     formalStartColumn: "",   // 写入起始列号
                     formalNameColumn: "",    // 姓名所在列号
                     formalDateRow: "",       // 日期所在行
                     formalDateFormat: "",    // 日期格式（DD / YYYY/MMM/DD / YYMMDD）

                     // ===== 正式工颜色配置 =====
                     lateTextColor: "#ff0000",
                     missingBgColor: "#ffff00",
                     absenceBgColor: "#00ff00",

                     // ===== 劳务工表配置 =====
                     serviceSheetName: "",
                     serviceStartRow: "",
                     serviceStartColumn: "",
                     serviceNameColumn: "",
                     serviceDateRow: "",
                     serviceDateFormat: "",

                     // ===== 劳务工颜色配置 =====
                     serviceLateTextColor: "#ff0000",
                     serviceMissingBgColor: "#ffff00",
                     serviceAbsenceBgColor: "#00ff00"
               }
                latecolor.color = form.lateTextColor
                colorPreview.color = form.missingBgColor
                absence.color = form.absenceBgColor

                servicelatecolor.color = form.serviceLateTextColor
                servicemissingcolor.color = form.serviceMissingBgColor
                serviceabsence.color = form.serviceAbsenceBgColor

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
                width:parent.width - 10
                height:parent.height - 10
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
            Item{
                id:backi
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top:line.bottom
                anchors.topMargin: 1
                anchors.bottom: parent.bottom
                anchors.bottomMargin:56
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
                    contentHeight: content.implicitHeight + 60
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        background: Rectangle {
                            //anchors.fill: flick
                            implicitWidth: 4
                            radius: 0
                            color:"transparent"
                        }
                        contentItem: Rectangle {
                            implicitWidth: 6
                            implicitHeight: 6
                            radius: 5
                            color:flick.pressed ? "#999999" : Theme[fileManager.themeColors].scrollbar
                        }
                    }
                ColumnLayout{
                    id:content
                    width:backi.width
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    anchors.topMargin: 10
                    anchors.rightMargin: 20
                    spacing: 4

                Item { Layout.fillWidth: true; Layout.preferredHeight: 30;Layout.topMargin: 10;Layout.leftMargin: 10;Layout.rightMargin: 10
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle { width: 3; height: 16; radius: 2; color: "#5C67FA";Layout.alignment: Qt.AlignVCenter }
                        Text { Layout.alignment: Qt.AlignVCenter;text: "模板设置"; font.pixelSize: 14; font.weight: 600; color: Theme[fileManager.themeColors].textPrimary }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 8 ; Layout.leftMargin: 20;Layout.rightMargin: 20
                    Text { text: "模板名称"; font.pointSize: 10.5; color: Theme[fileManager.themeColors].textSecondary }
                    Search {
                        id: nameInput
                        Layout.fillWidth: true; lheight: 38; searchicon: false
                        leftpadding:10
                        ltext: "例如：2026年度考勤统计模板"; text:root.form?.modelName ?? ""
                        onTextChanged: root.form.modelName = text
                    }
                }

                // --- 映射规则区块 ---
                Item { Layout.fillWidth: true; Layout.preferredHeight: 30;Layout.topMargin: 70;Layout.leftMargin: 10;Layout.rightMargin: 10
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle { width: 4; height: 16; radius: 2; color: "#5C67FA";Layout.alignment: Qt.AlignVCenter }
                        Text { text: "输入映射规则配置"; font.pixelSize: 14; font.weight: 600; color: Theme[fileManager.themeColors].textPrimary ;Layout.alignment: Qt.AlignVCenter}
                    }

                }

                // 三列布局：Sheet、姓名列、日期列
                RowLayout {
                    Layout.fillWidth: true; spacing: 10;Layout.leftMargin: 20;Layout.rightMargin: 20;Layout.topMargin: -40
                    ColumnLayout {
                        Layout.preferredWidth: 0;Layout.topMargin: 40
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "表类型"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        LComboBox{ id:tabletype;property bool ready: false;Layout.fillWidth: true;Layout.rightMargin: 16;height:37
                            lmodel:ready ? ["考勤汇总表","打卡流水"]:""
                            lcurrentindex: root.form
                                           ? (lmodel.indexOf(root.form.inputType)===-1?0:lmodel.indexOf(root.form.inputType))
                                           : 0
                            onChanged: (index,text) => {
                                root.form.inputType = text
                            }
                            Component.onCompleted: {
                                   Qt.callLater(
                                       () => ready = true
                                    )
                               }
                        }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "Sheet名称"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search {Layout.fillWidth: true; lheight: 38; searchicon: false; ltext: "Sheet1"; text: root.form?.inputSheetName??""; onTextChanged: root.form.inputSheetName = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "姓名列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "A"; text: root.form?.inputuserColumn??""; onTextChanged: root.form.inputuserColumn = text }
                    }

                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 10;Layout.leftMargin: 20;Layout.rightMargin: 20;Layout.topMargin: 20
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "日期列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "B"; text: root.form?.inputdateColumn??""; onTextChanged: root.form.inputdateColumn = text }
                    }
                    ColumnLayout {
                        visible: tabletype.lcurrentindex === 1?true:false
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "出勤时间列"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "B"; text: root.form?.attendanceTime??""; onTextChanged: root.form.attendanceTime = text }
                    }

                    ColumnLayout {
                        visible: tabletype.lcurrentindex === 1?false:true
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "签到时间列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search {Layout.fillWidth: true; lheight: 38; searchicon: false; ltext: "C" ;text: root.form?.signInColumn??""; onTextChanged: root.form.signInColumn = text}
                    }
                    ColumnLayout {
                        visible: tabletype.lcurrentindex === 1?false:true
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "签退时间列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "D" ;text: root.form?.signOutColumn??""; onTextChanged: root.form.signOutColumn = text}
                    }
                    ColumnLayout {
                        visible: tabletype.lcurrentindex === 1?true:false
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Item { Layout.fillWidth: true; Layout.preferredHeight: 0 }
                        Rectangle { Layout.fillWidth: true; height: 10;width:70; color: "transparent" }
                    }
                }



                // --- 模板1映射 ---
                Item { Layout.fillWidth: true; Layout.preferredHeight: 30;Layout.topMargin: 70;Layout.leftMargin: 10;Layout.rightMargin: 10
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle { width: 4; height: 16; radius: 2; color: "#5C67FA";Layout.alignment: Qt.AlignVCenter }
                        Text { text: "模板1配置"; font.pixelSize: 14; font.weight: 600; color: Theme[fileManager.themeColors].textPrimary ;Layout.alignment: Qt.AlignVCenter}
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 10;Layout.leftMargin: 20;Layout.rightMargin: 20
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "写入Sheet名称"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search {Layout.fillWidth: true; lheight: 38; searchicon: false; ltext: "Sheet1"; text: root.form?.formalSheetName??""; onTextChanged: root.form.formalSheetName = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "写入起始行"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "1"; text: root.form?.formalStartRow??""; onTextChanged: root.form.formalStartRow = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "写入起始列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "B"; text: root.form?.formalStartColumn??""; onTextChanged: root.form.formalStartColumn = text }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 10;Layout.leftMargin: 20;Layout.rightMargin: 20;Layout.topMargin: 16
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "姓名所在列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search {Layout.fillWidth: true; lheight: 38; searchicon: false; ltext: "A"; text: root.form?.formalNameColumn??""; onTextChanged: root.form.formalNameColumn = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "日期所在行"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "5"; text: root.form?.formalDateRow??""; onTextChanged: root.form.formalDateRow = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0;Layout.topMargin: 40
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "日期格式"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        LComboBox{ id:tolerance;property bool ready: false;Layout.fillWidth: true;Layout.rightMargin: 16;height:37
                            lmodel:ready ? ["DD","YYYY/MMM/DD","YYMMDD"]:""
                            lcurrentindex: root.form
                                           ? lmodel.indexOf(root.form.formalDateFormat)
                                           : 0
                            onChanged: (index,text) => {
                                root.form.formalDateFormat = text
                            }
                            Component.onCompleted: {
                                   Qt.callLater(
                                       () => ready = true
                                       )
                               }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 40;Layout.leftMargin: 20;Layout.rightMargin: 20;Layout.topMargin: 26;Layout.alignment: Qt.AlignVCenter
                    RowLayout {
                        Layout.preferredWidth: 0
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true; spacing: 8
                        Text {Layout.alignment: Qt.AlignVCenter; text: "早退字体颜色:"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Rectangle {Layout.alignment: Qt.AlignVCenter;id: latecolor;width: 22;height: 22
                            radius: 6
                            color: root.form?.lateTextColor??"#ff0000"
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.picked = function(c) {
                                        root.form.lateTextColor = c
                                        latecolor.color = c
                                    }
                                    colorDialog.open()
                                    console.log( root.form.lateTextColor)
                                }
                            }
                        }

                    }

                    RowLayout {
                        Layout.preferredWidth: 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true; spacing: 8
                        Text {Layout.alignment: Qt.AlignVCenter; text: "漏打卡背景颜色:"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            id: colorPreview
                            width: 22
                            height: 22
                            radius: 6
                            color: root.form?.missingBgColor??"#00ff00"   // 或某个 property color
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.picked = function(c) {
                                        root.form.missingBgColor = c
                                        colorPreview.color = c
                                    }
                                    colorDialog.open()
                                }
                            }
                        }

                    }

                    RowLayout {
                        Layout.preferredWidth: 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.fillWidth: true; spacing: 8
                        Text {Layout.alignment: Qt.AlignVCenter; text: "缺勤背景颜色:"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            id: absence
                            width: 22
                            height: 22
                            radius: 6
                            color: root.form?.absenceBgColor??"#0000ff"   // 或某个 property color
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.picked = function(c) {
                                        root.form.absenceBgColor  = c
                                         absence.color = c
                                    }
                                    colorDialog.open()
                                }
                            }
                        }
                    }

                }


                // --- 模板2表映射 ---
                Item { Layout.fillWidth: true; Layout.preferredHeight: 30;Layout.topMargin: 45;Layout.leftMargin: 10;Layout.rightMargin: 10
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter
                        Rectangle { width: 4; height: 16; radius: 2; color: "#5C67FA";Layout.alignment: Qt.AlignVCenter }
                        Text { text: "模板2配置"; font.pixelSize: 14; font.weight: 600; color: Theme[fileManager.themeColors].textPrimary ;Layout.alignment: Qt.AlignVCenter}
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 10;Layout.leftMargin: 20;Layout.rightMargin: 20
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "写入Sheet名称"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search {Layout.fillWidth: true; lheight: 38; searchicon: false; ltext: "Sheet1"; text: root.form?.serviceSheetName??""; onTextChanged: root.form.serviceSheetName = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "写入起始行"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "1"; text: root.form?.serviceStartRow??""; onTextChanged: root.form.serviceStartRow = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "写入起始列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "B"; text: root.form?.serviceStartColumn??""; onTextChanged: root.form.serviceStartColumn = text }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 10;Layout.leftMargin: 20;Layout.rightMargin: 20;Layout.topMargin: 16
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "姓名所在列号"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search {Layout.fillWidth: true; lheight: 38; searchicon: false; ltext: "A"; text: root.form?.serviceNameColumn??""; onTextChanged: root.form.serviceNameColumn = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "日期所在行"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Search { Layout.fillWidth: true;lheight: 38; searchicon: false; ltext: "5"; text: root.form?.serviceDateRow??""; onTextChanged: root.form.serviceDateRow = text }
                    }
                    ColumnLayout {
                        Layout.preferredWidth: 0;Layout.topMargin: 40
                        Layout.fillWidth: true; spacing: 8
                        Text { text: "日期格式"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        LComboBox{ id:dateFormat;property bool ready: false;Layout.fillWidth: true;Layout.rightMargin: 16;height:37
                            lmodel:ready ? ["DD","YYYY/MMM/DD","YYMMDD"]:""
                            lcurrentindex: root.form
                                           ? lmodel.indexOf(root.form.serviceDateFormat)
                                           : 0
                            onChanged: (index,text) => {
                                root.form.serviceDateFormat = text
                            }
                            Component.onCompleted: {
                                   Qt.callLater(
                                       () => ready = true

                                    )
                               }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 40;Layout.leftMargin: 20;Layout.rightMargin: 20;Layout.topMargin: 26;Layout.alignment: Qt.AlignVCenter
                    RowLayout {
                        Layout.preferredWidth: 0
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true; spacing: 8
                        Text {Layout.alignment: Qt.AlignVCenter; text: "早退字体颜色:"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Rectangle {Layout.alignment: Qt.AlignVCenter;id: servicelatecolor;width: 22;height: 22
                            radius: 6
                            color: root.form?.serviceLateTextColor??"#ff0000"   // 或某个 property color
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.picked = function(c) {
                                        root.form.serviceLateTextColor = c
                                        servicelatecolor.color = c
                                    }
                                    colorDialog.open()
                                }
                            }
                        }

                    }

                    RowLayout {
                        Layout.preferredWidth: 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Layout.fillWidth: true; spacing: 8
                        Text {Layout.alignment: Qt.AlignVCenter; text: "漏打卡背景颜色:"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            id:servicemissingcolor
                            width: 22
                            height: 22
                            radius: 6
                            color: root.form?.serviceMissingBgColor??"#00ff00"  // 或某个 property color
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.picked = function(c) {
                                        root.form.serviceMissingBgColor = c
                                        servicemissingcolor.color = c
                                    }
                                    colorDialog.open()
                                }
                            }
                        }

                    }
                    RowLayout {
                        Layout.preferredWidth: 0
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        Layout.fillWidth: true; spacing: 8
                        Text {Layout.alignment: Qt.AlignVCenter; text: "缺勤背景颜色:"; font.pointSize: 10; color: Theme[fileManager.themeColors].textSecondary }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            id: serviceabsence
                            width: 22
                            height: 22
                            radius: 6
                            color: root.form?.serviceAbsenceBgColor??"#0000ff"    // 或某个 property color
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.15)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    colorDialog.picked = function(c) {
                                        root.form.serviceAbsenceBgColor = c
                                        serviceabsence.color = c
                                    }
                                    colorDialog.open()
                                }
                            }
                        }
                    }

                }

            }
        }
    }
            LButton{
                visible: root.isEdit
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.right:parent.right
                anchors.rightMargin: 30
                lwidth:88
                id:delbtn
                implicitHeight: 34
                lspace: 6
                prefixverticaloffset:0
                horizontaloffset:0
                verticalloffset:1
                ltext:"删 除"
                lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                lfontcolor:lhovered?"#E57373":"#E57373"
                lcolor: fileManager.themeColors === "lightTheme" ?(lhovered?Qt.lighter("#E57373",1.5):Qt.lighter("#E57373",1.6)):(lhovered?Qt.darker("#E57373",2.8):Qt.darker("#E57373",2.5))
                lfontsize: 10
                lborder: 0
                lradius: 4
                lfontweight: 500

                onClick:{
                    var oldIndex =  templatemanager.templateNames.indexOf(settings.modelName)
                    var ok = templatemanager.deletetemplate(form.id)
                    if(!ok)
                        return

                    Qt.callLater(() => {
                        const newNames = templatemanager.templateNames
                        if (newNames.length === 0) {
                            settings.modelName = ""
                        } else if (oldIndex >= 0) {
                            // 优先选“同位置”，否则退到最后一个
                            const newIndex = Math.min(oldIndex, newNames.length - 1)
                            settings.modelName = newNames[newIndex]
                        } else {
                            // 异常兜底
                            settings.modelName = newNames[0]
                        }
                        root.closepopup()
                    })
                }
            }

                LButton{
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
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
                    anchors.bottomMargin: 10
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
                        var result = AttendanceTemplateRules.validate(root.form)
                        if (!result.ok) {
                            mainWindow.showMessage("error",result.message,"错误")
                            return
                        }
                        if (templatemanager.applayTemplate(root.isEdit, root.form)) {
                            if(!root.isEdit && templatemanager.templateNames.length===1){
                                settings.modelName = templatemanager.templateNames[0]
                            }
                            else if(root.isEdit){
                               settings.modelName = root.form.modelName
                            }

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
