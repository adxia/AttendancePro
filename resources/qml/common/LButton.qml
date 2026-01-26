import QtQuick

Item {
    property int lwidth: 40
    property int lheight: 28
    property int lradius: 4
    property color lcolor: "transparent"
    property string ltext: "点击"
    property color lfontcolor: "#424242"
    property double lfontsize: 11
     property int lfontweight: 400
    property bool lhovered: false
    property int lborder: 0
    property bool lcontent:true
    property real lspace: 4
    property color lbordercolor: "#424242"
    signal click
    property Component prefixComponent: null
    property int prefixverticaloffset:0
    property int horizontaloffset:0
    property int verticalloffset:0
    implicitWidth:lwidth
    implicitHeight:lheight
    Rectangle{
        anchors.fill: parent
        radius:lradius
        color:lcolor
        border.width:lborder
        // antialiasing:true
        border.color:lbordercolor
        layer.smooth: false
        layer.enabled: false
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: lspace
            anchors.horizontalCenterOffset: horizontaloffset
            anchors.verticalCenterOffset: verticalloffset
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                id: prefixLoader
                sourceComponent: prefixComponent
                visible: prefixLoader
                anchors.verticalCenterOffset: prefixverticaloffset
                onLoaded: {
                    if(item && item.hasOwnProperty("hovered")){
                        item.hovered =Qt.binding(()=>lhovered)
                    }
                }

            }
            Text{
                visible:lcontent
                anchors.verticalCenter: parent.verticalCenter 
                font.pointSize:lfontsize
                font.weight: lfontweight
                text:ltext
                color:lfontcolor
            }
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: lhovered=true
            onExited:lhovered=false
            onClicked:click()
        }
    }
}
