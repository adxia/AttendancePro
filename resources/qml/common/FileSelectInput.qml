import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform

Item {
    id: root
    height: 68
    width: parent.width
    property string placeText: "请选择文件..."
    property string filePath: ""
    property string title: "选择文件"
    property var nameFilters: ["Excel Files (*.xlsx *.xls)", "All Files (*)"]
    property string icon: '\uf017'
    signal fileSelected(string path)

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme[fileManager.themeColors].fileinput
        border.color:fileManager.themeColors ==="darkTheme" ? "transparent": Qt.lighter("#D1D5DB",1.1)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6
        Rectangle{
            width:6
            color:"transparent"
        }
        Rectangle{
            width:44
            height: 44
            radius:8
            color:fileManager.themeColors === "darkTheme" ? Theme[fileManager.themeColors].Toast:'#0D5C67FA'
            Text{
                anchors.centerIn: parent
                font.family: "Font Awesome 7 Free"
                text:root.icon
                color:fileManager.themeColors === "darkTheme" ? "white":Theme[fileManager.themeColors].primaryColor
                font.pointSize: 14
                font.weight: 400
            }
        }
        Rectangle{
            width:6
            color:"transparent"
        }
        ColumnLayout{
            Text{
              text: root.title
              color:Theme[fileManager.themeColors].textPrimary
              font.pixelSize: 13
              font.weight: 600
            }

            Text {
                font.pixelSize: 14
                text: root.filePath === "" ? root.placeText : root.filePath.replace(/^file:\/\/\//, "")
                color: root.filePath === "" ? Theme[fileManager.themeColors].textTertiary : Theme[fileManager.themeColors].textPrimary
                elide: Text.ElideMiddle
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
            }
        }


        Rectangle {
            width: 100
            height:42
            radius: 8
            color: Theme[fileManager.themeColors].buttonback
            border.color:Qt.darker(Theme[fileManager.themeColors].buttonback,1.1)
            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -16
                text: "浏览"
                color: Theme[fileManager.themeColors].textSecondary
                font.pixelSize: 12
            }
            Text{
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 16
                font.family: "Font Awesome 7 Free"
                text:'\uf07c'
                color:Theme[fileManager.themeColors].textSecondary
                font.pointSize: 10
                font.weight: 400
            }
            MouseArea {
                anchors.fill: parent
                onClicked: fileDialog.open()
            }
        }
        Rectangle{
            width:6
            color:"transparent"
        }
    }

    FileDialog {
        id: fileDialog
        title: root.title
        nameFilters: root.nameFilters

        onAccepted: {
            root.filePath = fileDialog.file
            root.fileSelected(root.filePath)
        }
    }
}
