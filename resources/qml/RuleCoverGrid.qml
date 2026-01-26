import QtQuick
import QtQuick.Controls.Fusion
import BvcInspectionSystem 1.0
import QtQuick.Effects
    GridView {
        id: tools
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 15 // 左边距
        anchors.rightMargin: 20 // 右边距
        // cacheBuffer: 10
        clip:true
        //计算item宽高
        flow:GridView.FlowLeftToRight
        property int column: Math.max(Math.floor(tools.width / 270), 1)
        property int columns: Math.min(column,4)
        cellWidth: Math.floor(width / columns)
        cellHeight:Math.max(220, Math.min(Math.round(cellWidth / Math.SQRT2), 270))
        property int enditem: (Math.ceil(fileManager.count/columns)*cellHeight)-(cellHeight-20)
        property int itemsY
        add: Transition {
            ParallelAnimation {
                    OpacityAnimator { from:0; to: 1; duration: 160 }
                    YAnimator { from: enditem; duration: 160 }
                }
        }
        remove: Transition {
            ParallelAnimation {
                        OpacityAnimator { to: 0; duration: 160 }
                        YAnimator { to:tools.itemsY-20; duration: 160 }
                    }
        }
        // displaced: Transition{
        //     NumberAnimation {
        //                properties: "x,y"
        //                duration: 160
        //            }
        // }
        currentIndex:-1
        model:fileManager.ruleCoverModels
        delegate:Component{
            Rectangle{
                id: root
                width:tools.cellWidth
                height: tools.cellHeight
                color: "transparent"
            Rectangle{
                id:contentishadow
                width:240
                height: 240
                color:Theme[fileManager.themeColors].itembackground
                radius: 10
                x:contenti.x
                y:contenti.y
                layer.enabled: true
                layer.smooth: true
                layer.samples: 1
                transform: Scale {
                    id: contentishadowScale
                    origin.x: 0
                    origin.y: 0
                    xScale: contenti.width / 240
                    yScale: contenti.height / 240
                }
                layer.effect:MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#1A000000"
                    shadowBlur: 0.5    // 相当于 radius
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 0
                    shadowOpacity:0.8
                    blurMax: 20
                    blurMultiplier:0
                }

            }
            Rectangle {
                    id:contenti
                    width:parent.width-10
                    height: parent.height - 10
                    property real yOffset: 0
                    property bool hovered:false;
                    x:8
                    y: 8 - yOffset
                    color: Theme[fileManager.themeColors].itembackground
                    border.width: 1
                    border.color: conetentbackground.hovered ? Theme[fileManager.themeColors].primaryColor: "transparent"
                    clip:true
                    radius: 6
                    Behavior on yOffset {
                        NumberAnimation{
                            duration: 120
                            easing.type: Easing.Linear
                        }
                    }
                    Rectangle {
                        id:componet
                        width: 54
                        height:54
                        clip: true
                        radius: 8
                        y:32
                        x:20
                        antialiasing: true
                        color: Theme[fileManager.themeColors].primaryColor
                        layer.enabled: true
                        layer.smooth: true
                        layer.samples: 1
                        layer.effect:MultiEffect {
                            shadowEnabled: true
                            shadowColor: Theme[fileManager.themeColors].dropshodow
                            shadowBlur: 0.8   // 相当于 radius
                            shadowHorizontalOffset: 2
                            shadowVerticalOffset: 2
                            shadowOpacity:0.5
                            blurMax: 20
                            blurMultiplier:0
                        }
                        Text {
                            anchors.centerIn: parent
                            text:icon
                            color: "white"
                            font.pointSize: 20
                            font.family: "bootstrap-icons"
                        }
                    }
                    Text {
                        x:20
                        anchors.top: parent.top
                        anchors.topMargin: 100
                        text: label
                        color: Theme[fileManager.themeColors].textPrimary
                        font.pointSize: 11
                        font.weight: 500
                        font.letterSpacing: 1.4

                    }
                    Text {
                        x:20
                        anchors.top: parent.top
                        anchors.topMargin: 124
                        text:desc.length > 32 ? desc.substr(0, 32) + "...." : desc
                        color: Theme[fileManager.themeColors].textSecondary
                        font.pointSize: 10
                        width: parent.width-40
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHLeft
                        lineHeight: 20              // 每行高度 30px
                        lineHeightMode: Text.FixedHeight

                    }

            }

            Rectangle{
                id:conetentbackground
                width:parent.width-10
                height: parent.height - 10
                layer.enabled: false
                property bool hovered:false;
                x:8
                y: 8
                color: "transparent"
                MouseArea{
                    anchors.fill:conetentbackground
                    hoverEnabled:true
                    onEntered:{
                        conetentbackground.hovered = true;
                        contenti.yOffset = 4;
                        editbutton.margin = 14;
                        bottombutton.margin = 14;

                    }
                    onExited:{
                        conetentbackground.hovered = false;
                        contenti.yOffset = 0;
                        editbutton.margin = 10;
                        bottombutton.margin = 10;
                    }
                    // onClicked:{

                    // }
                    //底部按钮-编辑
                    Rectangle{
                        id:editbutton
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.bottomMargin: margin
                        anchors.rightMargin: 20
                        property bool ishovered:false
                        property real margin:10
                        width:60
                        height:30
                        radius: 6
                        border.width:0
                        opacity: conetentbackground.hovered
                        color:ishovered ? "#5C67FA" : Theme[fileManager.themeColors].buttonback

                        Behavior on opacity { OpacityAnimator { duration: 120 } }
                        Behavior on margin{
                            NumberAnimation{
                                duration: 120
                                easing.type: Easing.Linear
                            }
                        }
                        Timer {
                            id:hide
                            interval: 250
                            running: false
                            repeat: false
                            onTriggered: mainWindow.hide();
                        }
                        MouseArea{
                            anchors.fill:editbutton
                            hoverEnabled:true
                            propagateComposedEvents: true
                            onEntered:{
                                editbutton.ishovered=true;

                            }
                            onExited:{
                                editbutton.ishovered=false;

                            }
                            onClicked:{
                                var editor = Qt.createComponent("EditWindow.qml");
                                if(editor.status === Component.Ready)
                                {
                                    if(mainWindow.editors.length >1){
                                        showMessage("窗口数量达到最大值")
                                    }
                                    else{

                                    var cre = editor.createObject(null, { "title": label,"icon":icon });
                                    if(cre){
                                        mainWindow.editors.push(cre);
                                        windowutils.enbleshadow(cre);
                                        cre.onClosing.connect((closeEvent)=>{
                                          let index = mainWindow.editors.indexOf(cre);
                                              if (index >= 0) {

                                                  mainWindow.editors.splice(index, 1);
                                              }
                                              cre.destroy();
                                              mainWindow.show();
                                              }
                                            )
                                        cre.show();
                                        // Qt.callLater(()=>{
                                        //      mainWindow.hide();
                                        //      }
                                        //     )
                                        hide.start();



                                    }
                                    }
                                }
                            }
                        }
                        //编辑
                        Text{
                            id:delete1
                            anchors.top:parent.top
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                            text: "\uF4CA"
                            color: editbutton.ishovered ? "white":Theme[fileManager.themeColors].textSecondary
                            font.pointSize: 9
                            font.family: "bootstrap-icons"
                            font.weight: 500
                        }
                        Text{
                            id:delete2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            text: "编辑"
                            color: editbutton.ishovered ? "white":Theme[fileManager.themeColors].textSecondary
                            font.pointSize: 8
                            font.weight: 500
                        }
                    }

                    //底部按钮-删除
                    Rectangle{
                        id:bottombutton
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.bottomMargin: margin
                        anchors.rightMargin: 90
                        property bool deleteishovered:false
                        property real margin:10
                        width:60
                        height:30
                        radius: 6
                        border.width:0
                        Behavior on margin{
                            NumberAnimation{
                                duration: 120
                                easing.type: Easing.Linear
                            }
                        }
                        Behavior on opacity { OpacityAnimator { duration: 120 } }
                        // border.color:
                        color:deleteishovered ? "#EF5350": Theme[fileManager.themeColors].buttonback
                        opacity:  conetentbackground.hovered ? 1:0

                        MouseArea{
                            anchors.fill:bottombutton
                            hoverEnabled:true
                            propagateComposedEvents: true
                            onEntered:{
                                bottombutton.deleteishovered=true;
                                // bottombutton.color = "#EF5350";
                                bt1.color="white";
                                bt2.color="white";
                                bt1.text = '\uF78A';
                            }
                            onExited:{
                                bottombutton.deleteishovered=false;
                                // bottombutton.color = "transparent";
                                bt1.color="#EF5350";
                                bt2.color="#EF5350";
                                bt1.text = '\uF78B';
                            }
                            onClicked:{
                                Qt.callLater(() => dialog.open());
                                tools.itemsY = root.y;
                                dialog.index = index;
                                dialog.key = uuid;
                            }
                        }
                        //删除
                        Text{
                            id:bt1
                            // anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.top:parent.top
                            anchors.leftMargin: 10
                            anchors.topMargin: 9
                            text: "\uF78B"
                            color: "#EF5350"
                            font.pointSize: 8
                            font.family: "bootstrap-icons"
                            font.weight: 500
                        }
                        Text{
                            id:bt2
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            text: "删除"
                            color: "#EF5350"
                            font.pointSize: 8
                            font.weight: 500
                        }
                    }

                }
            }
        }

    }
    }

