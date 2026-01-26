// Generated from SVG file minize.svg
import QtQuick
import QtQuick.Shapes

Item {
    id: minize
    property color linecolor: "#ffffff"
    implicitWidth: 20
    implicitHeight: 20
    transform: [
        Scale {
            xScale: minize.width / 20
            yScale: minize.height / 20
        }
    ]
    Shape {
        preferredRendererType: Shape.GeometryRenderer
        anchors.fill: parent
        ShapePath {
            strokeColor: minize.linecolor
            strokeStyle: ShapePath.SolidLine
            strokeWidth: 1
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 5
            startY: 10
            PathLine {
                 x: 15
                 y: 10
             }
            
            
        }
    }
}
