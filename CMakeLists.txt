cmake_minimum_required(VERSION 3.3)

project(AttendancePro VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

# 启用 MSVC 优化
if (MSVC)
    add_compile_options(/Zc:__cplusplus /utf-8 /bigobj)
endif()

# 1. 查找 Qt6
find_package(Qt6 REQUIRED COMPONENTS Sql Quick)
qt_standard_project_setup(REQUIRES 6.9)

# 2. 定义路径变量
set(APP_ICON_RESOURCE_WINDOWS "${CMAKE_CURRENT_SOURCE_DIR}/resources/app.rc")

# 3. 创建执行文件
qt_add_executable(AttendancePro
    src/main.cpp
    ${APP_ICON_RESOURCE_WINDOWS}
)

# 4. 设置单例 QML 属性
set_source_files_properties(
    resources/Themes/Theme.qml
    resources/qml/common/AttendanceTemplateRules.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# 5. 核心模块
qt_add_qml_module(AttendancePro
    URI Attendance
    VERSION 1.0
    QML_FILES
    # 这里的路径必须是相对于 CMakeLists.txt 的真实物理路径
            resources/Main.qml
            resources/Themes/Theme.qml
            #qml
            resources/qml/common/AlertPopup.qml
            resources/qml/common/Card.qml
            resources/qml/common/CardTitle.qml
            resources/qml/common/CardToolBar.qml
            resources/qml/common/FileSelectInput.qml
            resources/qml/common/Footbar.qml
            resources/qml/common/AttendanceTemplateRules.qml
            resources/qml/common/InputModelAddWindow.qml
            resources/qml/common/LButton.qml
            resources/qml/common/LComboBox.qml
            resources/qml/common/LTabs.qml
            resources/qml/common/MainView.qml
            resources/qml/common/MessagePopup.qml
            resources/qml/common/MyCheckBox.qml
            resources/qml/common/Paginator.qml
            resources/qml/common/PersonAddWindow.qml
            resources/qml/common/PrintPage.qml

            resources/qml/common/RuleAddWindow.qml
            resources/qml/common/Search.qml
            resources/qml/common/Smenu.qml
            resources/qml/common/TableViews.qml
            resources/qml/common/Title.qml

            resources/qml/homepage/HomeView.qml
            resources/qml/rulepage/RuleView.qml
            resources/qml/settingpage/SettingView.qml

            # 图像组件
            resources/images/Closeimg.qml
            resources/images/Max.qml
            resources/images/Minize.qml
            resources/images/MaxActive.qml
    RESOURCES
        #资源文件
        resources/resource.qrc
    SOURCES
        # 核心：头文件
        include/Struct.h
        include/ExcelIO.h
        include/AttendancePipeline.h

        include/DataManager.h
        include/HolidayManager.h
        include/RuleEngine.h
        include/Settings.h
        include/TemplateManager.h
        include/Tablemodel.h
        include/PersonRuleModel.h
        include/FileManager.h
        include/MessageCenter.h
        include/ApiClient.h
        include/Enablewindowshadow.h
        include/WindowUtil.h
        include/ClipboardHelper.h

        # 实现
        src/core/AttendancePipeline.cpp
        src/core/DataManager.cpp
        src/core/HolidayManager.cpp
        src/core/RuleEngine.cpp
        src/core/Settings.cpp
        src/core/TemplateManager.cpp
        
        src/datamodel/PersonRuleModel.cpp
        src/datamodel/Tablemodel.cpp
        
        src/utils/ApiClient.cpp
        src/utils/Enablewindowshadow.cpp
        src/utils/ExcelIo.cpp
        src/utils/FileManager.cpp
        src/utils/MessageCenter.cpp
        src/utils/TimeUtils.cpp
        src/utils/WindowUtil.cpp
    RESOURCES resources/frag/background.frag
    RESOURCES resources/frag/reveal.frag
)

#头文件
target_include_directories(AttendancePro PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/libxl/include
    ${CMAKE_CURRENT_SOURCE_DIR}/3rdparty/qxlsx
)

# 链接依赖库
target_link_libraries(AttendancePro
    PRIVATE 
    Qt6::Quick
    Qt6::Sql
    dwmapi     # Windows 窗口阴影需要
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/libxl.lib
    ${CMAKE_CURRENT_SOURCE_DIR}/libs/QXlsx.lib
)

#复制内置节假日json配置
add_custom_command(TARGET AttendancePro POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
            $<TARGET_FILE_DIR:AttendancePro>/setting
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/config/holiday_Patch.json
        $<TARGET_FILE_DIR:AttendancePro>/setting/holiday_Patch.json
)

# 窗口属性设置
set_target_properties(AttendancePro PROPERTIES
    WIN32_EXECUTABLE TRUE
)
