import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.FluentWinUI3

Item {
    id: titleBar
    signal minimizeClicked
    signal maximizeClicked
    signal closeClicked
    signal windowMove
    signal doubleclick
    signal changeTheme
    signal changeSlider
    property string appname
    property int title_height: 40
    property color titlebarcolor
    property bool isMaximized
    property int titlewidth
    property alias searchField: search
    property var dragStartPoint: Qt.point(0, 0)
    property bool isDragging: false
    property int  colorchanget:Theme.changetime

    Rectangle {
        color: Theme[fileManager.themeColors].contentbackground
        height: titleBar.title_height
        implicitWidth: titlewidth
        anchors.top: parent.top

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: false
            propagateComposedEvents: true
            onPressed: (mouse) => {
                dragStartPoint = Qt.point(mouse.x, mouse.y)
                isDragging = false // 重置拖动状态
            }
            onPositionChanged: (mouse) => {
                   // 如果鼠标移动超过一个很小的阈值（例如 5 像素），则判断为拖动
                   if (!isDragging && Qt.vector2d(dragStartPoint.x - mouse.x, dragStartPoint.y - mouse.y).length() > 4) {
                       isDragging = true
                       // 开始窗口移动，这里会阻塞事件，但没关系，因为我们已经进入了拖动模式
                       titleBar.windowMove()
                   }
               }
            onDoubleClicked: titleBar.doubleclick()
            onReleased:(mouse) => {
                           mouse.accepted = Qt.LeftButton
                           search.focus = false
                           // 你可以继续补充其它状态变量
                       }
        }
        Behavior on color{
            ColorAnimation {
                        duration: titleBar.colorchanget   // 动画时长，毫秒
                        easing.type: Easing.Linear
                    }
        }

        Timer{
            id: debounceTimer
                interval: 600   // 延时 200ms
                repeat: false   // 只触发一次
                onTriggered: {
                   fileManager.searchRuleCover(search.text) // 这里才真正执行搜索
                }
        }
        TextField {
            id:search
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize:14
            font.letterSpacing :1.2
            color:Theme[fileManager.themeColors].textPrimary
            // anchors.verticalCenter: parent.verticalCenter
            anchors.bottom: parent.bottom
            placeholderText: "搜索"
            placeholderTextColor:Theme[fileManager.themeColors].textSecondary
            focusReason:Qt.MouseFocusReason
            padding: 0
            topPadding: 6
            verticalAlignment: TextInput.AlignBottom
            onTextChanged:debounceTimer.restart();
            onAccepted: {
                debounceTimer.stop()
                   fileManager.searchRuleCover(search.text)  // 调用立即搜索
               }
            background: Rectangle {
                id:b1
                implicitWidth: Math.max(320,(titleBar.width-156-600)/2)
                implicitHeight: 30
                radius:4
                border.width: 0
                color: "transparent"
                clip: false
               Behavior on width{
                  NumberAnimation{
                      duration: 200
                  }
               }
               Rectangle{
                   z:2
                    id:back
                    anchors.top: parent.top
                    anchors.right : b1.right
                    anchors.left: b1.left
                    radius:4
                    height: parent.height-2
                    width: parent.width
                    color:Theme[fileManager.themeColors].searchbackground
                    Behavior on width{
                       NumberAnimation{
                           duration: 200
                       }
                    }
               }
               Rectangle{
                    id:back1
                    z:1
                    y:2
                    anchors.bottom: parent.bottom
                    anchors.right : search.focus ? undefined:b1.right
                    anchors.left: search.focus ? b1.left:undefined
                    bottomLeftRadius: 4
                    bottomRightRadius: 4
                    topLeftRadius: 8
                    topRightRadius: 8
                    height: parent.height
                    width: search.focus ? parent.width:0
                    color:Theme[fileManager.themeColors].primaryColor
                    Behavior on width{
                       NumberAnimation{
                           duration: 200
                       }
                    }
               }
               Text{
                   z:3
                   anchors.right: parent.right
                   anchors.rightMargin: 10
                   anchors.top: parent.top
                   anchors.topMargin: 10
                    // anchors.verticalCenter: parent.verticalCenter
                    font.weight: 500
                    font.pointSize: 9
                    opacity: 0.8
                    color:Theme[fileManager.themeColors].textSecondary
                    text:'\uF52A'
               }
            }
            Behavior on x{
                XAnimator{
                    duration:Theme.changetime
                }
            }
            }
        Rectangle{
            id:colorchange
            property bool hover:false
            anchors.top: parent.top
            anchors.right: parent.right
            width:52
            height:34
            anchors.rightMargin:156
            color:hover?Theme[fileManager.themeColors].backgroundGradientStart:titleBar.titlebarcolor
            // Behavior on color{
            //     ColorAnimation {
            //                 duration: Theme.changetime   // 动画时长，毫秒
            //                 easing.type: Easing.Linear
            //             }
            // }
            Text{
                id:coloricon
                anchors.verticalCenter:parent.verticalCenter
                anchors.horizontalCenter:parent.horizontalCenter
                font.family:"bootstrap-icons"
                text:fileManager.themeColors !== "lightTheme"  ?'\uF496':'\uF1D2'
                font.pointSize:fileManager.themeColors !== "lightTheme" ? 10:12
                color:Theme[fileManager.themeColors].textSecondary
            }
            MouseArea {
                id: colorArea
                anchors.fill: parent
                hoverEnabled: true // 启用悬停检
                onEntered: {
                    colorchange.hover = true;
                }
                onExited: {
                    colorchange.hover = false;
                }

                onClicked:{
                    if(Theme.isDarkMode){
                       Theme.isDarkMode=false;
                        titleBar.changeTheme();

                    }
                    else{
                        Theme.isDarkMode = true;
                        titleBar.changeTheme();
                    }
                }
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            implicitWidth: 156
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    id: min
                    implicitWidth: 52
                    implicitHeight: 34
                    color: titleBar.titlebarcolor
                    // Behavior on color{
                    //     ColorAnimation {
                    //                 duration: Theme.changetime   // 动画时长，毫秒
                    //                 easing.type: Easing.Linear
                    //             }
                    // }
                    radius: 0
                    Minize {
                        id:minze
                        width: 20
                        height: 20
                        anchors.centerIn: parent
                        linecolor: Theme[fileManager.themeColors].textPrimary
                    }
                    MouseArea {
                        id: minArea
                        anchors.fill: parent
                        hoverEnabled: true // 启用悬停检
                        onClicked: titleBar.minimizeClicked()
                    }

                    states: [
                        State {
                            name: "hovered"
                            when: minArea.containsMouse
                            PropertyChanges {
                                min.color: Theme[fileManager.themeColors].backgroundGradientStart
                            }
                        }
                    ]
                }

                Rectangle {
                    id: max
                    implicitWidth: 52
                    implicitHeight: 34
                    color: titleBar.titlebarcolor
                    radius: 0
                    Loader{
                        id: iconLoader
                        anchors.centerIn: parent
                        sourceComponent: titleBar.isMaximized ?maxnormol : maxactive 
                    }
                    Component {
                        id: maxactive
                        Max {
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            linecolor: Theme[fileManager.themeColors].textPrimary
                        }
                    }
                    Component {
                        id: maxnormol
                        MaxActive {
                            width: 18
                            height: 18
                            anchors.centerIn: parent
                            linecolor:Theme[fileManager.themeColors].textPrimary
                        }
                    }

                    
                    MouseArea {
                        id: maxArea
                        anchors.fill: parent
                        hoverEnabled: true // 启用悬停检
                        onClicked: {search.focus = false;titleBar.maximizeClicked();maxArea.enabled = false;
                        maxArea.enabled = true;}
                    }
                    HoverHandler {
                        id: hoverHandler
                    }
                    states: [
                        State {
                            name: "hovered"
                            when: hoverHandler.hovered
                            PropertyChanges {
                                max.color: Theme[fileManager.themeColors].backgroundGradientStart
                            }
                        }
                    ]
                }

                Rectangle {
                    id: closed
                    implicitWidth: 52
                    implicitHeight: 34
                    color: titleBar.titlebarcolor

                    radius: 0
                    Closeimg {
                        id:closicon
                        width: 20
                        height: 20
                        anchors.centerIn: parent
                        linecolor: Theme[fileManager.themeColors].textPrimary
                    }
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true // 启用悬停检
                        onClicked: titleBar.closeClicked()
                    }
                    states: [
                        State {
                            name: "hovered"
                            when: closeArea.containsMouse
                            PropertyChanges {
                                closed.color: "#e23928"
                                closicon.linecolor:"#fefefe"
                            }
                        }
                    ]
                }
            }
        }
    }
}
