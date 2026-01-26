import QtQuick
import QtQuick.Controls

Row {
    id: root
    spacing: 8
    property int totalCount: 0          // 数据总条数
    property int pageSize: 10           // 每页显示条数
    property int currentPage: 1
    property int windowStart: 1
    property int windowSize: 3

    signal pageChanged(int page)        // 页码变化信号

    readonly property int totalPages: Math.ceil(totalCount / pageSize)

    function visiblePages() {
           let pages = []
           if (totalPages <= windowSize + 2) { // 总页数少于窗口+首尾
               for (let i = 1; i <= totalPages; i++)
                   pages.push(i)
           } else {
               // 左右固定
               if (windowStart > 1) pages.push("...") // 左侧 ...
               for (let i = 0; i < windowSize; i++) {
                   let p = windowStart + i
                   if (p <= totalPages) pages.push(p)
               }
               if (windowStart + windowSize - 1 < totalPages) pages.push("...") // 右侧 ...
           }
           return pages
       }


    LButton{
        property bool first:root.currentPage===1
        id:left
        implicitHeight:32
        implicitWidth: 38
        lcontent:false
        lcolor:Theme[fileManager.themeColors].backgroundPrimary
        lborder:1
        lbordercolor:first?Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.25):(lhovered?Theme[fileManager.themeColors].primaryColor:Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.2))
        prefixComponent: Component {
            Text{
                property bool hovered
                property bool first:root.currentPage===1
                id:refersh
                font.family: "Font Awesome 7 Free"
                text:"\uf053"
                color:first?Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.25):(hovered?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].textSecondary)
                font.pointSize: 8
                font.weight: 600
            }
        }
        Behavior on lbordercolor{
            ColorAnimation{
                duration: 200
            }
        }
        onClick: {
            if (root.currentPage > 1) {
                root.currentPage--
                root.pageChanged(root.currentPage)
            }
        }

    }

    // 页码区
    Repeater {
        model: visiblePages()
        delegate: Item {
            width: 40
            height: 34
            LButton{
                property bool check: currentPage === modelData
                // visible: modelData !== "..."
                implicitHeight:32
                implicitWidth: 38
                lcontent:true
                lcolor:check?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].backgroundPrimary
                lborder:check?0:1
                lbordercolor:lhovered?Theme[fileManager.themeColors].primaryColor:Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.2)
                ltext:modelData
                lfontsize: 10
                lfontcolor:check? "#fefefe":Theme[fileManager.themeColors].textSecondary
                Behavior on lbordercolor{
                    ColorAnimation{
                        duration: 200
                    }
                }
                onClick: {
                        if (modelData === "...") {
                            // 点击 ... 只是滑动窗口
                            let idx = index
                            if(idx === 0) windowStart = Math.max(1, windowStart - windowSize)       // 左侧 ...
                            else windowStart = Math.min(totalPages - windowSize + 1, windowStart + windowSize) // 右侧 ...
                        } else {
                            // 点击页码才切换 currentPage
                            if(currentPage !== modelData) {
                                currentPage = modelData
                                root.pageChanged(currentPage)
                                // 同时可以调整 windowStart 保证 currentPage 始终在窗口内
                                if(currentPage < windowStart) windowStart = currentPage
                                if(currentPage >= windowStart + windowSize) windowStart = currentPage - windowSize + 1
                            }
                        }
                    }




            }


        }
    }


    LButton{
        property bool last:root.currentPage===root.totalPages
        id:right
        enabled: root.currentPage < root.totalPages
        implicitHeight:32
        implicitWidth: 38
        lcontent:false
        lcolor:Theme[fileManager.themeColors].backgroundPrimary
        lborder:1
        lbordercolor:last?Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.25):(lhovered?Theme[fileManager.themeColors].primaryColor:Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.2))
        prefixComponent: Component {
            Text{
                property bool hovered
                property bool last:root.currentPage===root.totalPages
                id:refersh
                font.family: "Font Awesome 7 Free"
                text:"\uf054"
                color:last?Qt.lighter(Theme[fileManager.themeColors].textTertiary,1.25):(hovered?Theme[fileManager.themeColors].primaryColor:Theme[fileManager.themeColors].textSecondary)
                font.pointSize: 8
                font.weight: 600
            }
        }
        Behavior on lbordercolor{
            ColorAnimation{
                duration: 200
            }
        }
        onClick: {
            if (root.currentPage < totalPages) {
                root.currentPage++
                root.pageChanged(root.currentPage)
            }
        }

    }

    // Text {
    //     anchors.verticalCenter: parent.verticalCenter
    //     text: `   共 ${root.totalPages} 页/当前第 ${root.currentPage} 页`
    //     color: "#666"
    //     font.pointSize: 12
    //     font.letterSpacing: 1.4
    //     verticalAlignment: Text.AlignVCenter
    // }
}
