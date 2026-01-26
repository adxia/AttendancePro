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
             startX: 4
             startY: 6
             PathLine {
                 x: 14
                 y: 6
             }
             PathLine {
                 x: 14
                 y: 16
             }
             PathLine {
                 x: 4
                 y: 16
             }
             PathLine {
                 x: 4
                 y: 6
             }
              PathSvg {
                path: "M 6 6 L 6 4 L 16 4 L 16 14 L 14 14"
            }
        }
    }
}
