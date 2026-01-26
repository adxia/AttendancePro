import QtQuick
import QtQuick.Controls.FluentWinUI3

Item {
    id:root
    property alias lfocus: search.focus
    property string ltext: "搜索"
    property int leftpadding: 16
    property bool searchicon: true
    property real lheight:32
    property alias text: search.text
    property string mask:""
    property var lvalidator: null
    property bool read:false
    signal searchText(string text)
    TextField {
        id:search
        font.pointSize:10
        font.letterSpacing :1
        font.weight: 500
        font.preferTypoLineMetrics:true
        color:Theme[fileManager.themeColors].textPrimary
        placeholderText: ltext
        placeholderTextColor:Theme[fileManager.themeColors].textSecondary
        focusReason:Qt.MouseFocusReason
        topPadding: 2
        leftPadding:root.leftpadding
        bottomPadding: 0
        inputMask:root.mask
        readOnly: root.read
        validator: root.lvalidator
        verticalAlignment: Text.AlignVCenter
        onTextChanged:debounceTimer.restart();
        Timer{
        id: debounceTimer
            interval: 600   // 延时 200ms
            repeat: false   // 只触发一次
            onTriggered: {
               searchText(search.text)// 这里才真正执行搜索
               // search.focus=false
            }
        }
        onAccepted: {
            debounceTimer.stop()
            // search.focus=false
            searchText(search.text) // 调用立即搜索
           }
        background: Rectangle {
            id:b1
            implicitWidth: root.width - 15
            implicitHeight: root.lheight
            radius:4
            border.width: 0
            color: "transparent"
            clip: false
           Rectangle{
                z:2
                id:back
                anchors.top: parent.top
                anchors.right : b1.right
                anchors.left: b1.left
                radius:4
                height: parent.height
                width: parent.width
                border.width:1
                border.color: search.focus ? Theme[fileManager.themeColors].primaryColor:(fileManager.themeColors==="darkTheme"?Qt.lighter(Theme[fileManager.themeColors].textSecondary,0.5):Qt.lighter(Theme[fileManager.themeColors].textSecondary,1.7))
                color:Theme[fileManager.themeColors].backgroundPrimary
                Behavior on width{
                   NumberAnimation{
                       duration: 200
                   }
                }
           }
           Text{
               visible:root.searchicon
               z:3
               anchors.verticalCenter: parent.verticalCenter
               anchors.left: parent.left
               anchors.leftMargin: 10
               font.family: "Font Awesome 7 Free"
               text:'\uf002'
               color:Theme[fileManager.themeColors].textSecondary
               font.pointSize: 9
               font.weight: 400
           }

        }
        Behavior on x{
            XAnimator{
                duration:Theme.changetime
            }
        }
        }
}
