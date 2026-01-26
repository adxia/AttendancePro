import QtQuick
import QtQuick.Controls.FluentWinUI3
import QtQuick.Effects
import QtQuick.Controls.impl

Item {
    id: root
    width: 200
    height: 38
    property list<string> lmodel:["HP LaserJet Pro M404n12esa"]
    property alias lcurrentindex: combo.currentIndex
    property alias lcurrentText: combo.currentText
    signal changed(int ind,string text)

    ComboBox {
        id: combo
        anchors.left: parent.left
        anchors.top: parent.top
        implicitHeight:root.height
        implicitWidth: root.width
        font.pointSize: 10
        model:lmodel
        currentIndex:0
        onActivated: (index) => {
               root.changed(index, currentText)
           }

        background: Rectangle {
               color: Theme[fileManager.themeColors].changebackground    // 背景颜色
               radius: 4
               height:root.height
               width:root.width
               border.width: 1
               border.color:fileManager.themeColors==="darkTheme"?Qt.lighter(Theme[fileManager.themeColors].textSecondary,0.5):Qt.lighter(Theme[fileManager.themeColors].textSecondary,1.7)
           }
        contentItem: Text {
                anchors.top: parent.top
                anchors.topMargin: 11
                text: combo.displayText.length > 40 ? combo.displayText.substring(0, 40) + "…" : combo.displayText    // 显示选中的文本
                color: Theme[fileManager.themeColors].textPrimary                  // 改成红色
                font.pointSize: 10
            }
        indicator: Text{
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 13
            font.family:"bootstrap-icons"
            text:"\uF282"
            font.pointSize: 10
            color:Theme[fileManager.themeColors].textPrimary

        }
        popup: Popup {
            id: popup
            x: combo.x
            y: root.height+1
            width: combo.width
            height:Math.min(listView.contentHeight,360)
            onOpened:{
                enter.running = true
                enterto.restart()
            }
            Timer {
                id:enterto
                interval: 100
                running: false
                repeat: false
                onTriggered: enteropacity.running=true
            }
            Timer {
                id:exitto
                interval: 80
                running: false
                repeat: false
                onTriggered: exitopacity.running=true
            }
            function closepopup(){
                exit.running=true
                exitto.restart()

            }
            onClosed: listView.opacity = 0
            enter:null
            exit:null
            background:null
            contentItem: Item{
                            id:background2
                            anchors.top:parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            NumberAnimation {
                                id:enter
                                running:false
                               target: background2
                               property: "height"
                               from: 0
                               to:popup.height
                               duration: 140
                            }
                            OpacityAnimator {
                               id:enteropacity
                               running:false
                               target: listView
                               from: 0
                               to:1
                               duration: 140
                            }

                            NumberAnimation {
                               id:exitopacity
                               running:false
                               target: background2
                               property: "height"
                               to: 0
                               duration: 160
                               onFinished:popup.close()

                            }
                            OpacityAnimator {
                               id:exit
                               running:false
                               target: listView
                               from:1
                               to:0
                               duration: 160
                            }


                            BorderImage {
                               id: backshadow
                               anchors.top:parent.top
                               anchors.horizontalCenter: parent.horizontalCenter
                               width:parent.width + 14
                               height:parent.height + 11
                               source: fileManager.themeColors === "darkTheme"?"qrc:/images/shadow_rect_black.png":"qrc:/images/shadow_rect.png"
                               border { left: 10; top: 10; right: 10; bottom: 10 }
                            }
                            Rectangle {
                               id: back
                               width:parent.width
                               height:parent.height + 4
                               anchors.top:parent.top
                               radius:8
                               color:Theme[fileManager.themeColors].backgroundPrimary
                            }
                            ListView {
                            id: listView
                            anchors.fill: parent
                            model: combo.delegateModel
                            opacity:0
                            palette: Palette {
                                accent: "#5C67FA"   // 改竖条颜色
                            }
                            delegate: ItemDelegate {
                                    width: parent.width
                                    padding: 10
                                    highlighted: ListView.isCurrentItem
                                    contentItem: Text {
                                           anchors.left: parent.left
                                           anchors.leftMargin: 20
                                           text: modelData.length > 23 ? modelData.substring(0, 18) + "…"+ modelData.substring(modelData.length - 5): modelData
                                           font.pointSize: 10
                                           color: Theme[fileManager.themeColors].textPrimary
                                           horizontalAlignment: Text.AlignLeft
                                           verticalAlignment: Text.AlignVCenter
                                       }
                                }
                            currentIndex: combo.currentIndex
                            highlightRangeMode: ListView.NoHighlightRange
                            preferredHighlightBegin: 0
                            preferredHighlightEnd: 0
                            ScrollIndicator.vertical: ScrollIndicator { }
                         }
                        }
                    }
    }
}
