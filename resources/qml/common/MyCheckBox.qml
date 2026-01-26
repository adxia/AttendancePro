// MyCheckBox.qml
import QtQuick
import QtQuick.Controls.Fusion as QQC2
import QtQuick.Shapes

QQC2.CheckBox {
    id: root
    property color checkcolor: "#5C67FA"
    property int cheight:18
    property int cwidth:18
    property int cradius: 4
    implicitHeight:cheight
    implicitWidth:cwidth
    // 1. 自定义 indicator
    indicator: Rectangle {
        width: cwidth; height: cheight; radius: cradius
        border.color:root.checked ? "transparent":"#666"
        color: root.checked ? root.checkcolor: "transparent"
        Shape {
            anchors.fill: parent
            visible: root.checked     // 只在选中时显示
            // rendererType:Shape.CurveRenderer
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true                              // 开启抗锯齿
            ShapePath {
                strokeColor: "white"
                strokeWidth: 1.5
                joinStyle: ShapePath.RoundJoin
                capStyle: ShapePath.RoundCap
                strokeStyle: ShapePath.SolidLine
                fillColor: "transparent"
                // 相对父项的路径
                startX: width*0.25; startY: height*0.45
                PathLine { x: width*0.45; y: height*0.7 }
                PathLine { x: width*0.75; y: height*0.3 }
            }
        }
    }

    // 2. 可选：自定义 contentItem
    contentItem: Row {
        spacing: 6
        Text { text: root.text; color: "#333" }
    }
    // 3. 可选：背景、hover/press 动画
    background: Rectangle {
        anchors.fill: parent
        color: root.hovered ? "#1Aeeeeee" : "transparent"
        radius: 4
    }
}
