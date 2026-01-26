import QtQuick
import QtQuick.Shapes


Item {
    id: close
    implicitWidth: 20
    implicitHeight: 20
    property color linecolor:Theme[fileManager.themeColors].textPrimary
    transform: [
        Scale {
            xScale: close.width / 20
            yScale: close.height / 20
        }
    ]
    Shape {
        preferredRendererType: Shape.GeometryRenderer
        ShapePath {
            strokeColor: close.linecolor
            strokeWidth: 1
            capStyle: ShapePath.RoundCap
            strokeStyle: ShapePath.SolidLine
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"
            startX: 5; startY: 5
                PathLine { x: 15; y: 15 }
                PathMove { x: 15; y: 5 }
                PathLine { x: 5; y: 15 }
            PathSvg {
                path: "M 5 5 L 15 15 M 15 5 L 5 15 "
            }
        }
    }
}
