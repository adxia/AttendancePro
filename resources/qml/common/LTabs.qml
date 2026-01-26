import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    height: 46
    width: parent.width

    property var model: ["模式一", "模式二", "模式三"]
    property int currentIndex: 0
    signal currentChanged(int index)

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme[fileManager.themeColors].comboboxshadow   // 背景条
    }

    Rectangle{
        id:background
        height:root.height-10
        radius: 6
        width:((root.width-16)/root.model.length)
        color:"#5C67FA"
        x:4 +  root.currentIndex*width + root.currentIndex*4
        y:5
        Behavior on x {
            XAnimator { duration: 150 }
        }
    }
    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4
        Repeater {
            model: root.model
            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                radius: 6
                color:"transparent"
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 14
                    font.weight: index === root.currentIndex ? 600 : 400
                    color: index === root.currentIndex
                           ? "White"
                           : Theme[fileManager.themeColors].textPrimary
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.currentIndex = index
                        root.currentChanged(index)
                    }
                }
            }
        }
    }
}
