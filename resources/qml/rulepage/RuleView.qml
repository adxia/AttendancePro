import "../common"
import QtQuick
import QtQuick.Layouts

import QtQuick.Controls.Material
import Attendance 1.0
import QtQuick.Dialogs
import QtQuick.Effects

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
            console.log("用户选择保存路径:", selectedFolder)
        }
    }
    RectangularShadow {
        anchors.fill: tablecard
        opacity: 0.2
        offset.x: 0
        offset.y: 0
        radius: tablecard.radius
        blur: 10
        spread: 0
        color: Qt.darker(tablecard.color, 1.1)
    }
    Rectangle{
        id:tablecard
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height:340
        anchors.topMargin: 20
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        radius:6
        color:Theme[fileManager.themeColors].backgroundPrimary
        RowLayout {
            id:tabname
            spacing: 2
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left:parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            Rectangle {
                Layout.alignment:Qt.AlignVCenter
                width: 3
                height: 16
                radius: 1.5
                color: "#5C67FA"   // 主题色
            }
            Text {
                Layout.alignment:Qt.AlignVCenter
                id: selectmodel
                text: "计算规则"
                font.pixelSize: 16
                font.letterSpacing: 1.1
                color: Theme[fileManager.themeColors].textPrimary
                font.weight: 700
            }
            Item{
                Layout.preferredWidth: 100
                Layout.preferredHeight: addrule.height
                Layout.alignment:Qt.AlignRight | Qt.AlignVCenter
                RectangularShadow {
                    anchors.fill: addrule
                    opacity: 0.2
                    offset.x: 0
                    offset.y: 0
                    radius: addrule.lradius
                    blur: 10
                    spread: 0
                    color: Qt.darker(addrule.color, 1.1)
                }
                LButton{
                    lwidth:100
                    id:addrule
                    implicitHeight: 34
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
                    ltext:"新增规则"
                    lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                    lfontcolor:lhovered?"#fefefe":"#fefefe"
                    lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                    lfontsize: 10
                    lborder: 0
                    lradius: 4
                    lfontweight: 500
                    onClick:{
                        ruleaddwindow.title = "计算规则新增"
                        ruleaddwindow.isEdit = false
                        ruleaddwindow.record = null
                        ruleaddwindow.open()
                    }

                }
            }
        }

        TableViews{
            id:table
            anchors.top:parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 60
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.bottomMargin: 20
            clip: true
            lmodel:tableModel
            onEdited:(row)=>{
                    ruleaddwindow.title = "计算规则编辑"
                    ruleaddwindow.isEdit = true
                    ruleaddwindow.editRow = row
                    ruleaddwindow.record = tableModel.getRow(row)
                    ruleaddwindow.open()
            }
        }
        Paginator {
               id: paginator
               visible:totalCount>pageSize
               anchors.bottom: parent.bottom
               anchors.bottomMargin: 14
               anchors.horizontalCenter: parent.horizontalCenter
               totalCount: tableModel.totalCount
               pageSize: 15
               onPageChanged: (page) => {

               }
           }

    }


    RectangularShadow {
        anchors.fill: persontablecard
        opacity: 0.2
        offset.x: 0
        offset.y: 0
        radius: persontablecard.radius
        blur: 10
        spread: 0
        color: Qt.darker(persontablecard.color, 1.1)
    }

    Rectangle{
        id:persontablecard
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.top: tablecard.bottom
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 10
        anchors.topMargin: 20
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        radius:6
        color:Theme[fileManager.themeColors].backgroundPrimary
        RowLayout {
            id:personrule
            spacing: 10
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.left:parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            Rectangle {
                Layout.alignment:Qt.AlignVCenter
                width: 3
                height: 16
                radius: 1.5
                color: "#5C67FA"   // 主题色
            }
            Text {
                id: personmap
                text: "人员规则分配"
                font.pixelSize: 16
                font.letterSpacing: 1.1
                color: Theme[fileManager.themeColors].textPrimary
                font.weight: 700
            }
            Item {
                Layout.fillWidth: true
            }

            Item{
                Layout.alignment:Qt.AlignRight | Qt.AlignVCenter
                Layout.preferredWidth: 100
                Layout.preferredHeight: addperson.height
                RectangularShadow {
                    anchors.fill: addperson
                    opacity: 0.4
                    offset.x: 0
                    offset.y: 0
                    radius: addperson.lradius
                    blur: 10
                    spread: 0
                    color: Qt.darker(addperson.lcolor, 1.1)
                }
                LButton{
                    Layout.alignment:Qt.AlignRight | Qt.AlignVCenter
                    lwidth:100
                    id:addperson
                    implicitHeight: 34
                    prefixComponent: Component {
                        Text{
                            font.family: "bootstrap-icons"
                            text:'\uF357'
                            color:"#fefefe"
                            font.pointSize: 8
                            font.weight: 400
                        }
                    }
                    lspace: 4
                    prefixverticaloffset:0
                    horizontaloffset:0
                    verticalloffset:1
                    ltext:"Excel导入"
                    lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                    lfontcolor:lhovered?"#fefefe":"#fefefe"
                    lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                    lfontsize: 10
                    lborder: 0
                    lradius: 4
                    lfontweight: 500
                    onClick:{
                        filedialog.open()
                    }

                }
            }
            Item{
                Layout.alignment:Qt.AlignRight | Qt.AlignVCenter
                Layout.preferredWidth: 100
                Layout.preferredHeight: importperson.height
                RectangularShadow {
                    anchors.fill: importperson
                    opacity: 0.4
                    offset.x: 0
                    offset.y: 0
                    radius: importperson.lradius
                    blur: 10
                    spread: 0
                    color: Qt.darker(importperson.lcolor, 1.1)
                }

                LButton{
                    lwidth:100
                    id:importperson
                    implicitHeight: 34
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
                    ltext:"添加人员"
                    lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
                    lfontcolor:lhovered?"#fefefe":"#fefefe"
                    lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                    lfontsize: 10
                    lborder: 0
                    lradius: 4
                    lfontweight: 500
                    onClick:{
                        personaddwindow.title = "人员新增"
                        personaddwindow.isEdit = false
                        personaddwindow.record = null
                        personaddwindow.open()
                    }

                    }
                }
            }

        TableViews{
            id:tableperson
            anchors.top:parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 60
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.bottomMargin: 20
            clip: true
            lmodel:personModel
            onEdited:(row)=>{
                personaddwindow.title = "人员规则分配编辑"
                personaddwindow.isEdit = true
                personaddwindow.editRow = row
                personaddwindow.record = personModel.getRow(row)
                personaddwindow.open()
            }
        }
        Paginator {
               id: paginatorperson
               visible:totalCount>pageSize
               anchors.bottom: parent.bottom
               anchors.bottomMargin: 14
               anchors.horizontalCenter: parent.horizontalCenter
               totalCount: tableModel.totalCount
               pageSize: 15
               onPageChanged: (page) => {

               }
           }

    }
}
