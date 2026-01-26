import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Effects
import Qt.labs.qmlmodels
import Qt.labs.platform

Item {
    id:root
    anchors.fill: parent
    property int headerheight:50
    property int headerfontWeight:500
    property int headerfontSize:11
    property int headerradius: 6
    property var lmodel: tableModel
    signal edited(int row)
    //property var columnWeights:model.col

    Text{
        visible: tableView.rows === 0 ? true:false
        anchors.centerIn: parent
        anchors.verticalCenterOffset:-60
        text: mainWindow.displaydata
        font.pointSize: 11
        font.letterSpacing: 1.2
        color: "#888888"
    }
    HorizontalHeaderView {
           id: horizontalHeader
           columnSpacing: -0.5
           rowSpacing: -0.5
           anchors.left: parent.left
           anchors.leftMargin:70
           anchors.right: parent.right
           anchors.rightMargin: 120
           anchors.top: parent.top
           syncView: tableView
           boundsBehavior:Flickable.StopAtBounds
           resizableColumns:false
           contentWidth:tableView.width
           // clip: true
           // interactive: true
           delegate: Rectangle {
                  implicitHeight: root.headerheight
                  implicitWidth:(tableView.width/root.lmodel.columnCount())+1
                  color: Theme[fileManager.themeColors].tabletitle
                  border.width: 0
                  border.color: "#5C67FA"
                  TextEdit {
                      id:text
                      anchors.centerIn: parent;
                      leftPadding: 15
                      rightPadding: 15
                      anchors.left: parent.left
                      anchors.leftMargin: 10
                      anchors.verticalCenter: parent.verticalCenter
                      text: display
                      font.weight: root.headerfontWeight
                      font.pointSize: headerfontSize
                      color:Theme[fileManager.themeColors].textPrimary
                      readOnly: true
                      selectByMouse: true
                      wrapMode: Text.NoWrap
                      selectionColor: "#805C67FA"
                      font.letterSpacing: 1.4
                  }
              }
       }
    HorizontalHeaderView {
           z:4
           id: leftHeader
           anchors.left: parent.left
           anchors.leftMargin: 0
           anchors.top: horizontalHeader.top
           syncView: verticalHeader
           interactive: false
           // boundsBehavior:Flickable.StopAtBounds
           delegate: Rectangle {
                  implicitHeight: root.headerheight
                  implicitWidth:70
                  color: Theme[fileManager.themeColors].tabletitle
                  border.width: 0
                  Text{
                    // anchors.left: parent.left
                    // anchors.leftMargin: 20
                     anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text:"序号"
                    font.weight: root.headerfontWeight
                    font.pointSize: headerfontSize
                    color:Theme[fileManager.themeColors].textPrimary
                    wrapMode: Text.NoWrap
                    font.letterSpacing: 2

                  }
              }
       }
    HorizontalHeaderView {
           id: rightHeader
           z:4
           anchors.right: parent.right
           anchors.rightMargin: tableView.rows===0? 120:0
           anchors.top: horizontalHeader.top
           syncView: verticalButton
           interactive: false
           delegate: Rectangle {
                  implicitHeight: root.headerheight
                  implicitWidth:121
                  color: Theme[fileManager.themeColors].tabletitle
                  border.width: 0
                  Text{
                    // anchors.centerIn: parent
                    anchors.left:parent.left
                    anchors.leftMargin: 17
                    anchors.verticalCenter: parent.verticalCenter
                    text:"操作"
                    font.weight: root.headerfontWeight
                    font.pointSize: headerfontSize
                    color:Theme[fileManager.themeColors].textPrimary
                    wrapMode: Text.NoWrap
                     font.letterSpacing: 1.4
                  }
              }
       }
    VerticalHeaderView {
           z:4
           id: verticalHeader
           anchors.left: parent.left
           anchors.leftMargin: 0
           anchors.top: parent.top
           anchors.topMargin: horizontalHeader.height
           anchors.bottom: parent.bottom
           syncView: tableView
           clip:true
           boundsBehavior:Flickable.StopAtBounds
           // interactive: false
           delegate: Rectangle {
                  implicitHeight: root.headerheight
                  implicitWidth:70
                  // color: "transparent"
                  color:row%2===0?Theme[fileManager.themeColors].backgroundPrimary:Theme[fileManager.themeColors].backgroundSecondary
                  border.width: 0
                  border.color: "#805C67FA"

                  Text{
                    // anchors.centerIn: parent
                      anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    // anchors.left: parent.left
                    // anchors.leftMargin: 30
                    // anchors.verticalCenter: parent.verticalCenter
                    text:index+1
                    font.weight: 400
                    font.pointSize: 10.5
                    color:Theme[fileManager.themeColors].textPrimary
                    wrapMode: Text.NoWrap

                  }

              }
       }

    VerticalHeaderView {
           z:4
           id: verticalButton
           anchors.right: parent.right
           anchors.top: parent.top
           anchors.topMargin: horizontalHeader.height
           anchors.bottom: parent.bottom
           syncView: tableView
           clip:true
           // interactive: false
           boundsBehavior:Flickable.StopAtBounds
           ScrollBar.vertical:ScrollBar {
                      id: vbar
                      width: 10
                      policy: vbar.height < verticalButton.contentHeight?ScrollBar.AsNeeded:ScrollBar.AlwaysOff
                      anchors.right: verticalButton.right

                      // 轨道背景（track）
                      background: Rectangle {
                          anchors.fill: vbar
                          implicitWidth: 6
                          radius: 0
                          // color: Theme[fileManager.themeColors].searchbackground
                          color:"transparent"
                      }
                      contentItem: Rectangle {
                          implicitWidth: 4
                          implicitHeight: 4
                          radius: 5
                          color:vbar.pressed ? "#999999" : Theme[fileManager.themeColors].scrollbar
                      }
                 }

           delegate: Rectangle {
                  id:viewroot
                  implicitHeight: 30
                  implicitWidth:120
                  color:row%2===0?Theme[fileManager.themeColors].backgroundPrimary:Theme[fileManager.themeColors].backgroundSecondary
                  border.width: 0
                  Row{

                             anchors.left: parent.left
                             anchors.leftMargin: 10
                             anchors.verticalCenter: parent.verticalCenter
                             spacing: 1
                             LButton{
                                 id:printbtn
                                 visible:tableView.model.data(tableView.model.index(row, 4)) !== "null"
                                 opacity: visible
                                 implicitHeight: 26
                                 implicitWidth: 46
                                 ltext:"编辑"
                                 lfontweight:500
                                 lfontcolor:lhovered ? Qt.lighter(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
                                 lfontsize: 10
                                 lborder: 0
                                 onClick:{
                                     edited(row)
                                 }

                             }
                             Rectangle{
                                 visible: printbtn.visible
                                 anchors.verticalCenter: parent.verticalCenter
                                 width:1
                                 height:16
                                 color:Theme[fileManager.themeColors].scrollbar
                                 Behavior on x {
                                    XAnimator{
                                        duration:300
                                    }
                                 }
                             }

                             LButton{
                                 id:f
                                 // anchors.verticalCenter: parent.verticalCenter
                                 // anchors.left:printbtn.right
                                 // anchors.leftMargin: 8
                                 implicitHeight: 26
                                 implicitWidth: 46
                                 ltext:"删除"
                                 lfontweight:500
                                 // lbordercolor:lhovered?Theme[fileManager.themeColors].primaryColor:"transparent"
                                 lfontcolor:"#E57373"
                                 lfontsize: 10
                                 lborder: 0
                                 Behavior on x {
                                    XAnimator{
                                        duration:300
                                    }
                                 }
                                 onClick:{
                                   root.lmodel.deleteRow(row)
                                 }
                             }
                  }


              }
       }
    TableView {
        z:2
        id: tableView
       // property var columnWeights: root.columnWeights
        property bool ctrlActive: false
        anchors.top: parent.top
        clip:true
        anchors.topMargin: horizontalHeader.height
        anchors.leftMargin: 70
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 120
        anchors.bottom: parent.bottom
        columnSpacing: -0.5
        rowSpacing: -0.5
        animate:true
        contentWidth:tableView.width
        focus:true
        boundsBehavior:Flickable.StopAtBounds
        selectionMode: TableView.ContiguousSelection    // 或 Multiple / Extended
        selectionBehavior: TableView.SelectCells // 也可以是 Rows/Columns
        selectionModel: ItemSelectionModel {
                 model: tableView.model
             }
        Keys.onReleased: (event) => {
                   tableView.ctrlActive = false
           }
        Keys.onPressed: (event) => {
             if (event.modifiers & Qt.ShiftModifier)
                      {
                      tableView.ctrlActive = true
           }
               // 判断是否 Ctrl + C
               if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_C) {
                   copySelectionToClipboard()
                   event.accepted = true
               }
           }
        function copySelectionToClipboard() {
            let selectedIndexes = tableView.selectionModel.selectedIndexes
            if (selectedIndexes.length === 0)
                return

            // 按行列分组
            let dataMap = {}
            for (let i = 0; i < selectedIndexes.length; ++i) {
                let idx = selectedIndexes[i]
                if (!dataMap[idx.row])
                    dataMap[idx.row] = {}
                dataMap[idx.row][idx.column] = root.lmodel.data(idx)
            }

            // 组装文本（制表符 + 换行）
            let rows = Object.keys(dataMap).sort((a, b) => a - b)
            let text = rows.map(row =>
                Object.keys(dataMap[row]).sort((a, b) => a - b)
                    .map(col => dataMap[row][col])
                    .join("\t")
            ).join("\n")

            clipboardHelper.setText(text)
        }
        SelectionRectangle {
                target: tableView
                enabled: tableView.ctrlActive
                topLeftHandle: Rectangle {
                    width: 6
                    height: 6
                    radius:3
                    visible: SelectionRectangle.control.active
                    color:Theme[fileManager.themeColors].scrollbar
                       }

                    bottomRightHandle: Rectangle {
                        width: 6
                        height: 6
                        radius:3
                        visible: SelectionRectangle.control.active
                        color:Theme[fileManager.themeColors].scrollbar
                           }
                       }

           acceptedButtons: Qt.NoButton
        rowHeightProvider: function(row) {
           return 44;

         }

        ScrollBar.horizontal:ScrollBar {
                   id: hbar
                   height:10
                   policy: tableView.width <tableView.contentWidth?ScrollBar.AsNeeded:ScrollBar.AlwaysOff
                   size: tableView.width / tableView.contentWidth
                   background: Rectangle {
                       anchors.fill: hbar
                       implicitWidth: 6
                       implicitHeight: 6
                       radius: 0
                       color:"transparent"
                   }
                   contentItem: Rectangle {
                       implicitWidth: 4
                       implicitHeight: 4
                       radius: 5
                       color:hbar.pressed ? "#999999" : Theme[fileManager.themeColors].scrollbar
                   }
              }

            model: root.lmodel

        delegate: Rectangle {
           required property bool selected
           property color selectcolor: fileManager.themeColors ==="lightTheme"?Qt.darker(baseColor,1.1):Qt.darker(baseColor,0.7)
           property color baseColor: row % 2 === 0? Theme[fileManager.themeColors].backgroundPrimary: Theme[fileManager.themeColors].backgroundSecondary
           //property color daycolor:"#E57373"
            id:tableroot
            implicitWidth:(tableView.width/root.lmodel.columnCount())+1
            implicitHeight: 42
            border.width: 0
            color:selected?selectcolor :baseColor
            clip: false
            MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onDoubleClicked: {
                            tableView.selectionModel.select(
                                tableView.model.index(row, column),
                                ItemSelectionModel.ClearAndSelect
                            )
                        }
                        onClicked: {
                                   tableView.selectionModel.clearSelection()
                               }
         }
            TextEdit {
                id:textItem
                leftPadding: 15
                rightPadding: 15
                text: display
                font.pointSize: column === 6 ? 10:10.5
                font.weight:400
                color:Theme[fileManager.themeColors].textSecondary
                readOnly: true
                enabled: false
                selectByMouse: false
                wrapMode: Text.NoWrap
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                selectionColor: "#805C67FA"

            }

        }

        }
    RectangularShadow {
        z:3
        anchors.fill: back
        opacity: 1
        offset.x: 0
        offset.y: -4
        radius: back.radius
        blur: 10
        spread: 0
        color: fileManager.themeColors === "darkTheme"?Qt.darker(back.color, 2):Qt.darker(back.color, 1.2)
    }
    Rectangle{
           id:back
           z:3
           anchors.top:parent.top
           anchors.right: parent.right
           anchors.rightMargin: 0
           height:root.headerheight+(tableView.rows*44)-(tableView.rows/2)
           width:120
           color: Theme[fileManager.themeColors].tabletitle
    }
}
