#include <QTimer>
#include "Enablewindowshadow.h"
#include <QFontDatabase>
#include <QQmlContext>
#include <QFont>
#include <QSharedMemory>
#include <QQmlApplicationEngine>
#include "FileManager.h"
#include "Tablemodel.h"
#include "DataManager.h"
#include "PersonRuleModel.h"
#include "ClipboardHelper.h"
#include "MessageCenter.h"
#include "Settings.h"
#include "HolidayManager.h"
#include "AttendancePipeline.h"
#include "RuleEngine.h"
#include <ShellScalingApi.h>
#include "TemplateManager.h"
#pragma comment(lib, "Shcore.lib")


int main(int argc, char *argv[]) {

    float systemScale = 1.0f;
    int physWidth = 1920;

    #ifdef Q_OS_WIN
    // 关键：强制让当前进程感知 DPI，否则系统会给假数据
    // 注意：这必须在所有 GUI 操作之前调用
    if (!SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)) {
        SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE);
    }
    HDC hdc = GetDC(NULL);
    int dpiX = GetDeviceCaps(hdc, LOGPIXELSX); // 此时应该能拿到 144, 192 等
    physWidth = GetDeviceCaps(hdc, DESKTOPHORZRES);
    ReleaseDC(NULL, hdc);
    systemScale = dpiX / 96.0f;
    #endif
    float targetScale;
    // 逻辑计算
    if (physWidth <= 2200) {
        targetScale = 1.0f;
    } else if (physWidth <= 2800) {
        targetScale = qMin(systemScale, 1.25f);
    } else {
        targetScale = qMin(systemScale, 2.15f); // 4K 压制到 2.0
    }

    // 计算校准值：你想达到的目标 / 系统已经给你的
    // 比如 4K 系统给 3.0，你想 2.0，那么 calibration = 0.666
    float calibration = targetScale / systemScale;

    qputenv("QT_SCALE_FACTOR", QByteArray::number(calibration, 'f', 2));

    #if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
        QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
        QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    #endif
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QCoreApplication::setOrganizationName("Attendance");
    QCoreApplication::setApplicationName("Attendance 1.0");

    QGuiApplication app(argc, argv);
    int fontId = QFontDatabase::addApplicationFont(":/font/Font Awesome 7 Brands-Regular-400.otf");
    int fontId2 = QFontDatabase::addApplicationFont(":/font/Font Awesome 7 Free-Solid-900.otf");
    int fontId3 = QFontDatabase::addApplicationFont(":/font/bootstrap-icons.otf");
    int fontId4 = QFontDatabase::addApplicationFont(":/font/InterVariable.ttf");
    int fontId6 = QFontDatabase::addApplicationFont(":/font/HarmonyOS_Sans_SC_Medium.ttf");
    int fontId7 = QFontDatabase::addApplicationFont(":/font/HarmonyOS_Sans_SC_Regular.ttf");
    int fontId8 = QFontDatabase::addApplicationFont(":/font/HarmonyOS_Sans_SC_Bold.ttf");

    QStringList fontFamilies4 = QFontDatabase::applicationFontFamilies(fontId4);
    app.setWindowIcon(QIcon(":/images/ico.ico"));
    QString family = fontFamilies4.at(0) +",HarmonyOS Sans SC";
    QFont font(family);
    app.setFont(font);
    QSurfaceFormat fmt;
    fmt.setSwapInterval(1); // 1 表示开启VSync（等待一个刷新周期）
    QSurfaceFormat::setDefaultFormat(fmt);
    QQmlApplicationEngine engine;
    FileManager* filemanager = new FileManager();
    filemanager->setParent(&engine);
    filemanager->loadConfig();

    DataManager dataManager;
    dataManager.initDatabase();

    TableModel* tableModel = new TableModel();
    tableModel->setParent(&engine);

    PersonRule* personModel = new PersonRule();
    personModel->setParent(&engine);

    ClipboardHelper clipboardHelper;

    AttendancePipeline pipeline;
    engine.rootContext()->setContextProperty("pipeline", &pipeline);

    Settings* settings = new Settings;
    settings->setParent(&engine);
    engine.rootContext()->setContextProperty("settings", settings);

    HolidayManager holidayserver(settings);
    engine.rootContext()->setContextProperty("holidayserver",&holidayserver);

    TemplateManager* templatemanager = new TemplateManager;
    templatemanager->setParent(&engine);
    templatemanager->loadTemplates(&dataManager);
    engine.rootContext()->setContextProperty("templatemanager",templatemanager);

    RuleEngine ruleserver(&dataManager,settings,templatemanager);

    ruleserver.load();
    engine.rootContext()->setContextProperty("ruleserver", &ruleserver);

    QObject::connect(templatemanager, &TemplateManager::templatesUpdated,
                     &ruleserver, &RuleEngine::loadExcelMap);

    QObject::connect(settings, &Settings::modelNameChanged,
                    &ruleserver, &RuleEngine::loadExcelMap);

    QObject::connect(personModel, &PersonRule::personChanged,
                     &ruleserver, &RuleEngine::loadPerson);

    QObject::connect(tableModel, &TableModel::rulesChanged,
                     &ruleserver, &RuleEngine::loadRule);

    engine.rootContext()->setContextProperty("messagecenter", MessageCenter::instance());
    engine.rootContext()->setContextProperty("fileManager", filemanager);
    engine.rootContext()->setContextProperty("clipboardHelper", &clipboardHelper);
    engine.rootContext()->setContextProperty("tableModel", tableModel);
    engine.rootContext()->setContextProperty("personModel", personModel);
    tableModel->init(&dataManager);
    personModel->init(&dataManager);


    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1);},
        Qt::QueuedConnection);
    // QCoreApplication::setAttribute(Qt::AA_UseDesktopOpenGL)



    QSharedMemory shared("AttendanceUniqueKey");
    if (!shared.create(1)) {
        return 0;
    }
    engine.loadFromModule("Attendance" , "Main");

    #ifdef Q_OS_WIN
        auto rootObjects = engine.rootObjects();
        if (!rootObjects.isEmpty()) {

            auto *window = qobject_cast<QQuickWindow *>(rootObjects.first());
            if (window) {
                HWND hwnd = reinterpret_cast<HWND>(window->winId());
                //engine.rootContext()->setContextProperty("mainWindow", window1);
                if (hwnd) {
                    enableWindowShadow windows{hwnd};
                    windows.enableShadow(window);

                }
            }
        }
    #endif
    return app.exec();
    

}
