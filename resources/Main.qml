import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Particles
import QtQuick.Dialogs
import Attendance


ApplicationWindow {
    id: mainWindow
    property bool a;
    flags: Qt.FramelessWindowHint | Qt.Window
    width: Screen.width * 0.6
    height:Math.max(Screen.height * 0.85,800)
    minimumWidth: Screen.width * 0.3
    minimumHeight: Screen.height * 0.4
    property int message: 0
    property bool isfirstclose:true
    property var editors: []
    property bool requestwait:false
    property string displaydata
    property int popupSeq: 0
    property var popupStack: []
    signal stackChange()


    Component.onCompleted: {
        Qt.callLater(() => {
             visible = true;
             mainWindow.x = Math.max((Screen.width - mainWindow.width) / 2, 0)
             mainWindow.y = (Screen.height - 40 - mainWindow.height) / 2
             Qt.callLater(() => {
                  holidayserver.loadPatch()
              })

         })

        }
    RuleAddWindow{
        id:ruleaddwindow
    }
    PersonAddWindow{
        id:personaddwindow
    }
    InputModelAddWindow{
        id:addmodel
    }

    FileDialog{
        id:filedialog
        title:"选择文件"
        nameFilters: ["只支持Excel 文件(*.xlsx)"]
        onAccepted:{
            personModel.importFromExcel(selectedFile);
        }
    }

    function showMessage(mtype,msg,title) {
        var component = Qt.createComponent("./common/MessagePopup.qml");
        if (component.status === Component.Ready) {
            popupSeq += 1
            var name = "popup_" + popupSeq
            popupStack.push(name)
            var popup = component.createObject(mainWindow, {"mtype":mtype,"content":msg,"title":title,"name":name});
            if(popup){
                popup.popupclosed.connect((name )=> {
                      var idx = popupStack.indexOf(name)
                         if (idx !== -1) {
                            popupStack.splice(idx, 1) // 删除 idx 位置的 1 个元素
                            stackChange()
                         }
                });
                popup.open();
            }
        }
    }
    Connections {
        target: messagecenter
        function onSuccessmessage(title,msg,stauts){
            if(!stauts){
               mainWindow.requestwait = stauts
            }
            showMessage("success",msg,title)
        }
        function onWarningmessage(title,msg,stauts) {
            if(!stauts){
               mainWindow.requestwait = stauts
            }
            showMessage("warning",msg,title)
        }
        function onErromessage(title,msg,stauts) {
            if(!stauts){
               mainWindow.requestwait = stauts
            }
            showMessage("erro",msg,title)
        }
        function onDatanull(msg){
            if(displaydata!==msg)
            {
                displaydata=msg
            }
        }
    }
    AlertPopup {
        id: dialog
        title: "提示"
        content: "规则删除后将无法还原,你需要重新设计,请确认是否删除?"
        property int index: -1
        property string key
        onAccepted:()=>{fileManager.removeRuleCover(index,key); showMessage("删除成功")}
        onRejected:()=>{}
    }

    // visible:false
    color: Theme[fileManager.themeColors].backgroundPrimary
    ParallelAnimation{
        id:exit
        running: false
        PropertyAnimation {
            target: mainWindow
            property: "opacity"
            to: 0.0
            duration: 160
            // 3. 动画完成后，安全地退出应用
        }
        PropertyAnimation {
            target: mainWindow
            property: "y"
            to: mainWindow.y - 20
            duration: 160
            // 3. 动画完成后，安全地退出应用
        }
        onFinished: {
           isfirstclose = false;
            Qt.quit();
        }
    }


    onClosing:function(event) {
        if(isfirstclose){
           event.accepted = false;
            exit.start();
        }
        else{
           event.accepted = true;
        }
    }


    WindowUtil{
        id:windowutils
    }
    //窗口动画层
    Rectangle {
        id: background
        anchors.left:parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 50
        color:"transparent"
        smooth: true

        MouseArea {
            anchors.fill: parent
            onClicked: {
                titleBar.searchField.focus = false;
            }
        }
    }

    Title {
        id: titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        titlewidth:parent.width
        anchors.right: parent.right
        titlebarcolor: Theme[fileManager.themeColors].titlebackground
        isMaximized : mainWindow.visibility === Window.Maximized
        // title_height: 40
        z: 1
        onChangeTheme: {
            Theme.changetime = 200;
            if(fileManager.themeColors === "lightTheme")
            {
                fileManager.themeColors= "darkTheme";
            }
            else{
                fileManager.themeColors = "lightTheme";
            }

        }
        onMinimizeClicked: {windowutils.changewindowstate(mainWindow,"minimize"); }
        onMaximizeClicked: {
            if (mainWindow.visibility === Window.Maximized) {
                windowutils.changewindowstate(mainWindow,"normol");
            } else {
                windowutils.changewindowstate(mainWindow,"maximize");
            }
        }
        onChangeSlider: {
            if(Theme.sliderwidth===Theme.impliwidth)
            {
               Theme.sliderwidth= 70;

            }
            else{
                Theme.sliderwidth = Theme.impliwidth;

            }
        }

        onCloseClicked: mainWindow.close();
        onWindowMove: {mainWindow.startSystemMove();
            // titleBar.searchField.focus = false;
        }
        onDoubleclick: {
            if (mainWindow.visibility === Window.Maximized) {
                windowutils.changewindowstate(mainWindow,"normol");
                // titleBar.searchField.focus = false
            } else {
               windowutils.changewindowstate(mainWindow,"maximize");
                // titleBar.searchField.focus = false
            }
        }
    }

    Rectangle{
        id:contentback
        anchors.top:parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 40
        anchors.bottomMargin: 34
        width: Theme.sliderwidth === Theme.impliwidth ? parent.width - Theme.sliderwidth  : parent.width - Theme.sliderwidth
        y:0
        x:Theme.sliderwidth
        color:Theme[fileManager.themeColors].contentbackground

        Behavior on color{
            ColorAnimation {
                    duration: Theme.changetime  // 动画时长，毫秒
                    easing.type: Easing.Linear
                 }
        }

        states: [
                State {
                    name: "Expanded"
                    when: Theme.sliderwidth === Theme.impliwidth
                    PropertyChanges {
                        target: contentback
                        width: parent.width - Theme.sliderwidth
                        x: Theme.sliderwidth
                    }
                },
                State {
                    name: "Collapsed"
                    when: Theme.sliderwidth === 70
                    PropertyChanges {
                        target: contentback
                        width: parent.width - 70
                        x: 70
                    }
                }
            ]
        transitions: [
                Transition {
                    // 从任意状态到任意状态
                    from: "Expanded"
                    to: "Collapsed"
                    ParallelAnimation {
                        // 同时对 width 和 x 进行动画
                            NumberAnimation {
                                target: contentback
                                property: "width"
                                duration: Theme.xchangetime // 与 x 动画时长保持一致
                                easing.type: Easing.Linear
                            }
                            NumberAnimation {
                                target: contentback
                                property: "x"
                                duration: Theme.xchangetime
                                easing.type: Easing.Linear
                        }

                    }
                },
            Transition {
                from: "Collapsed"
                to: "Expanded"
                ParallelAnimation {
                    // 同时对 width 和 x 进行动画
                        NumberAnimation {
                            target: contentback
                            property: "width"
                            duration: Theme.xchangetime // 与 x 动画时长保持一致
                            easing.type: Easing.Linear
                        }
                        NumberAnimation {
                            target: contentback
                            property: "x"
                            duration: Theme.xchangetime
                            easing.type: Easing.Linear
                    }

                }
            }
            ]

            HomeView{
                id: home
                y:0
                show:true
                width:parent.width
                height:parent.height
                z:2
            }
            RuleView{
                id:rule
                y:0
                show:false
                width:parent.width
                height:parent.height
                z:2
            }

            SettingView{
                id: set
                y:0
                show:false
                width:parent.width
                height:parent.height
                z:2
            }



        }
    Loader {
        id: pageLoader
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        // asynchronous:true
        source: "qml/common/Smenu.qml"
        z: 4
        onLoaded: {

        }

    }
    Loader {
        id: foot
        anchors.left: parent.left
        anchors.right:parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        asynchronous:true
        z:3
        source: "qml/common/Footbar.qml"
    }
    Connections{
        target:pageLoader.item;
        function onMenuChanged(menuid){
            if(menuid === "home"){
                home.show = true
                set.show = false
                rule.show =false
            }
            else if(menuid === "rule"){
                rule.show = true
                set.show = false
                home.show=false
            }
            else if(menuid === "setting"){
                home.show = false
                rule.show =false
                set.show = true
            }

        }
    }
}
