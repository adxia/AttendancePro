// Generated from SVG file max.svg
import QtQuick
import QtQuick.Shapes

Item {
    id: max
    // anchors.centerIn: parent
    implicitWidth: 20
    implicitHeight: 20
    property color linecolor: "#ffffff"
    property int ismax: 0
    transform: [
        Scale {
            xScale: max.width / 20
            yScale: max.height / 20
        }
    ]
    Shape {
        preferredRendererType: Shape.GeometryRenderer
     
        ShapePath {
            strokeWidth: 1
            strokeColor: max.linecolor
            strokeStyle: ShapePath.SolidLine
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"
             startX: 5
             startY: 5
             PathLine {
                 x: 15
                 y: 5
             }
             PathLine {
                 x: 15
                 y: 15
             }
             PathLine {
                 x: 5
                 y: 15
             }
             PathLine {
                 x: 5
                 y: 5
             }
        }
    }
}
