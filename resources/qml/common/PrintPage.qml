import QtQuick
Item{
    id: printPage

    property string ltext:"77341"
    property string orderinfo:"血型卡抽检单"
    property string cid:"OCDI2025090177"
    property string orderawb:"412A1214151"
    property int lindex: 0
    property int lcount: 0
    // property ListModel model:[]
    property var lmodel
    anchors.horizontalCenter: parent.horizontalCenter
    width:840
    height:1188


    Rectangle{
        id:page
        anchors.fill:parent
        color:"white"
        Text {
            anchors.left:parent.left
            anchors.leftMargin: 40
            anchors.top:parent.top
            anchors.topMargin: 50
            id: lefttitle
            text: orderinfo
            font.pointSize: 18
            font.weight: 400
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top:parent.top
            anchors.topMargin: 50
            id: righttitle
            text: "运单号："+ lmodel.awb
            font.pointSize: 18
            font.weight:400
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Canvas {
            id: dashLine
            anchors.top:righttitle.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width:parent.width - 78
            height: 1
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#646464";
                ctx.lineWidth = height;        // 线宽
                ctx.setLineDash([4, 2]);       // 5像素实线，3像素空白
                ctx.beginPath();
                ctx.moveTo(0, height/2);
                ctx.lineTo(width, height/2);
                ctx.stroke();
            }
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.top:dashLine.top
            anchors.topMargin: 100
            id: cid
            text: "CID"
            font.pointSize: 18
            font.weight:500
            font.letterSpacing: 1.2
            color:"#646464"
            }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.top:dashLine.top
            anchors.topMargin: 240
            id: sku
            text: "SKU"
            font.pointSize: 18
            font.weight:500
            font.letterSpacing: 1.2
            color:"#646464"
            }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.top:dashLine.top
            anchors.topMargin: 380
            id: bacth
            text: "批号"
            font.pointSize: 18
            font.weight:500
            font.letterSpacing: 1.2
            color:"#646464"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: page.width-240
            anchors.top:dashLine.top
            anchors.topMargin: 98
            id: qty
            text: "托盘数量"
            font.pointSize: 18
            font.weight:500
            font.letterSpacing: 1.2
            color:"#646464"
            }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: page.width-240
            anchors.top:dashLine.top
            anchors.topMargin: 238
            id: insqty
            text: "抽检数量"
            font.pointSize: 18
            font.weight:500
            font.letterSpacing: 1.2
            color:"#646464"
            }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: page.width-240
            anchors.top:dashLine.top
            anchors.topMargin: 378
            id: insloc
            text: "抽检位置"
            font.pointSize: 18
            font.weight:500
            font.letterSpacing: 1.2
            color:"#646464"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.top:dashLine.top
            anchors.topMargin: 145
            id: cidtext
            text: lmodel.cid
            font.pointSize: 20
            font.weight:500
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.top:dashLine.top
            anchors.topMargin: 285
            id: skutext
            text: lmodel.sku
            font.pointSize: 20
            font.weight:500
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.top:dashLine.top
            anchors.topMargin: 435
            id: batchtext
            text: lmodel.batch
            font.pointSize: 20
            font.weight:500
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: page.width-240
            anchors.top:dashLine.top
            anchors.topMargin: 145
            id: qtytext
            text: lmodel.quantity
            font.pointSize: 20
            font.weight:500
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: page.width-240
            anchors.top:dashLine.top
            anchors.topMargin: 285
            id: insqytext
            text: lmodel.sample_num===""?"数据错误":lmodel.sample_num + "bx"
            font.pointSize: 20
            font.weight:500
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: page.width-240
            anchors.top:dashLine.top
            anchors.topMargin: 435
            id: insloctext
            text: "1-3层中"
            font.pointSize: 20
            font.weight:500
            font.letterSpacing: 1.2
            color:"#3c3c3c"
            }




        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:image.bottom
            anchors.topMargin: 10
            id: inputField
            text: "托盘号："+ lmodel.pallet
            font.pointSize: 20
            font.weight: 500
            font.letterSpacing:1
            color:"#323232"
            }
        Image {
            id:image
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: printPage.height*0.15
            width: printPage.width * 0.25
            height: width
            source: "image://qr/" +  lmodel.cid +"|"+ lmodel.sku +"|"+ lmodel.batch+ "|"+ lmodel.pallet
            cache: false
        }
        Canvas {
            id: bottomLine
            anchors.bottom:page.bottom
            anchors.bottomMargin: 90
            anchors.horizontalCenter: parent.horizontalCenter
            width:parent.width - 78
            height: 1
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = "#645464";
                ctx.lineWidth = height;
                ctx.setLineDash([4, 2]);
                ctx.beginPath();
                ctx.moveTo(0, height/2);
                ctx.lineTo(width, height/2);
                ctx.stroke();
            }
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin:40
            anchors.top:bottomLine.bottom
            anchors.topMargin: 10
            text: "本单据由系统自动生成，仅用于内部管理使用"
            font.pointSize: 13
            font.weight: 400
            font.letterSpacing: 1
            color:"#646464"
            }
        Text {
            anchors.right: parent.right
            anchors.rightMargin:40
            anchors.top:bottomLine.bottom
            anchors.topMargin: 10
            text: "生成时间：" + (lmodel.creatdate === "" ? "未知的时间":lmodel.creatdate)
            font.pointSize: 13
            font.weight: 400
            font.letterSpacing: 1
            color:"#646464"
            }

        // Text {
        //     anchors.right: parent.right
        //     anchors.rightMargin:40
        //     // anchors.horizontalCenter: parent.horizontalCenter
        //     anchors.top:bottomLine.bottom
        //     anchors.topMargin: 50
        //     text: lindex+" / "+lcount
        //     font.pointSize: 15
        //     font.weight: 400
        //     font.letterSpacing: 1
        //     color:"#646464"
        //     }
    }
}
