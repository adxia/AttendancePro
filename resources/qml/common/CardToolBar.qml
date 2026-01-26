import QtQuick
import QtQuick.Effects
import QtQuick.Controls

Item {

    id:root
    MouseArea{
        anchors.fill: root
        onClicked: search.lfocus = false
    }

    LButton{
        property real topmargin:parent.height/2-implicitHeight
        anchors.top: parent.top
        anchors.topMargin: topmargin
        id:importbtn
        anchors.left:parent.left

        anchors.leftMargin: 26
        implicitHeight: 32
        implicitWidth: 88
        prefixComponent: Component {
            Text{
                font.family: "Font Awesome 7 Free"
                text:'\uf07c'
                color:"#fefefe"
                font.pointSize: 8
                font.weight: 400
            }
        }
        lspace: 6
        prefixverticaloffset:0
        horizontaloffset:0
        verticalloffset:1
        ltext:"导入"
        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
        lfontcolor:lhovered?"#fefefe":"#fefefe"
        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].primaryColor
        lfontsize: 10
        lborder: 0
        lradius: 4
        lfontweight: 500
        onClick:{filedialog.open()}

    }

    LButton{
        property real topmargin:parent.height/2-implicitHeight
        anchors.top: parent.top
        anchors.topMargin: topmargin
        id:exportbtn
        anchors.left:importbtn.right
        anchors.leftMargin: 10
        implicitHeight: 32
        implicitWidth: 88

        prefixComponent: Component {

            Text{
                 property bool hovered
                font.family: "Font Awesome 7 Free"
                text:'\uf093'
                color:hovered?"#fefefe": Theme[fileManager.themeColors].primaryColor
                font.pointSize: 9
                font.weight: 400
            }
        }
        lspace: 6
        prefixverticaloffset:0
        horizontaloffset:0
        verticalloffset:1
        ltext:"导出"
        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
        lfontcolor:lhovered?"#fefefe":Theme[fileManager.themeColors].primaryColor
        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].backgroundPrimary
        lfontsize: 10
        lborder: lhovered?0:1
        lradius: 4
        lfontweight: 500
        onClick:{savedialog.open()}
    }
    Search{
        id:search
        property real topmargin:parent.height/2-height
        anchors.right:searchbtn.left
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: topmargin
        width: Window.width*220/1000
        height:32
        ltext:"输入CID/SKU/Batch进行搜索"
        onSearchText:(text)=>{ messagecenter.search(text)}
    }
    LButton{
        property real topmargin:parent.height/2-implicitHeight
        anchors.top: parent.top
        anchors.topMargin: topmargin
        id:searchbtn
        anchors.right:parent.right
        anchors.rightMargin: 20
        implicitHeight: 32
        implicitWidth: 88
        // Behavior on topmargin{
        //     NumberAnimation{
        //         duration: 200
        //     }
        // }
        prefixComponent: Component {

            Text{
                 property bool hovered
                font.family: "Font Awesome 7 Free"
                text:'\uf002'
                color:hovered?"#fefefe": Theme[fileManager.themeColors].primaryColor
                font.pointSize: 9
                font.weight: 400
            }
        }
        lspace: 6
        prefixverticaloffset:0
        horizontaloffset:0
        verticalloffset:1
        ltext:"搜索"
        lbordercolor:lhovered?"transparent":Theme[fileManager.themeColors].primaryColor
        lfontcolor:lhovered?"#fefefe":Theme[fileManager.themeColors].primaryColor
        lcolor: lhovered?Qt.darker(Theme[fileManager.themeColors].primaryColor,1.1):Theme[fileManager.themeColors].backgroundPrimary
        lfontsize: 10
        lborder: lhovered?0:1
        lradius: 4
        lfontweight: 500
        onClick:{messagecenter.search(search.text)}
    }

}
