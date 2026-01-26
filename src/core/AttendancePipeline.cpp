#include "AttendancePipeline.h"
#include <QtConcurrent/QtConcurrentRun>

AttendancePipeline::AttendancePipeline (QObject* parent): QObject(parent){

}

void AttendancePipeline::preloadInputFile(const QString &inputfilepath, const HolidayManager* holiday,const RuleEngine* ruleengine)
{
    if (!holiday) {
        emit MessageCenter::instance()->erromessage("节假日配置错误","请重启程序。",false);
        return;
    }
    if (!ruleengine) {
        emit MessageCenter::instance()->erromessage("规则配置错误","请重启程序。",false);
        return;
    }

    if (m_preloadTask.isRunning()) {
        m_preloadTask.waitForFinished();
    }
    m_isDataReady = false;
    QString path = QUrl(inputfilepath).toLocalFile();
    const QVariantMap& excelMap = ruleengine->getExcelMap();
    if(excelMap.isEmpty()){
        emit MessageCenter::instance()->erromessage("映射模板获取失败","请先增加Excel映射模板。",false);
        return;
    }
    if(m_currentExcel) {
        delete m_currentExcel;
        m_currentExcel = nullptr;
    }
    m_currentExcel = new ExcelIO(m_records, excelMap);
    m_records.clear();
    // 使用 Lambda 表达式异步执行
    m_preloadTask = QtConcurrent::run([this, path,holiday,ruleengine]() {
        if (m_currentExcel->openFile(path) && m_currentExcel->loadData()) {
            holiday->applayWorkdayRule(m_records);
             ruleengine->apply(m_records);
            m_isDataReady = true;
            return true;
        }
        return false;
    });
}

void AttendancePipeline::startRun(const QString &inputfilepath,const QString &formaloutfilepath,const QString &serviceoutfilepath,const RuleEngine* ruleengine)
{
    auto future = QtConcurrent::run([this, inputfilepath,formaloutfilepath,serviceoutfilepath,ruleengine]() {
        return run(inputfilepath,formaloutfilepath,serviceoutfilepath,ruleengine);
    });
}

bool AttendancePipeline::run(const QString &inputfilepath,const QString &formaloutfilepath,const QString &serviceoutfilepath,const RuleEngine* ruleengine){
    QElapsedTimer timer;
    timer.start();
    if (m_preloadTask.isRunning()) {
        // 强制等待预加载完成，防止 m_records 还是空的
        m_preloadTask.waitForFinished();
    }

    if (!m_isDataReady || !m_currentExcel) {
        emit MessageCenter::instance()->erromessage("错误", "数据解析失败，请重新选择打卡记录。", false);
        return false;
    }

    QString formalOutPath = QUrl(formaloutfilepath).toLocalFile();
    QString serviceOutPath = QUrl(serviceoutfilepath).toLocalFile();

    QString savefolder = ruleengine->getsavepath() + "/";

    if(formaloutfilepath.isEmpty() && serviceoutfilepath.isEmpty()){
        emit MessageCenter::instance()->erromessage("错误","请至少选择一个输出文件。",false);
        return false;
    }

    bool formal = true;bool service=true;
    if(!formaloutfilepath.isEmpty()){
        if(!m_currentExcel->saveAs(formalOutPath,Formal,savefolder)){
            formal = false;
        }
    }
    if(!serviceoutfilepath.isEmpty()){
        if(! m_currentExcel->saveAs(serviceOutPath,Service,savefolder)){
            service = false;
        }
    }

    qint64 elapsedMs = timer.elapsed(); // 毫秒
    if(formal && service){
        emit MessageCenter::instance()->successmessage("操作成功","任务已完成,用时 "+QString::number(elapsedMs)+" ms",false);
    }
    else if(!formal && service){
        emit MessageCenter::instance()->warningmessage("输出失败","正式工表输出失败。",false);
    }
    else if(formal && !service){
        emit MessageCenter::instance()->warningmessage("输出失败","劳务工表输出失败。",false);
    }
    else if(!formal && !service){
        emit MessageCenter::instance()->erromessage("执行错误","无法输出结果，请确认数据正确",false);
    }
    return true;
}

AttendancePipeline::~AttendancePipeline() {
    if (m_preloadTask.isRunning()) {
        m_preloadTask.waitForFinished();
    }

    if (m_currentExcel) {
        delete m_currentExcel;
        m_currentExcel = nullptr;
    }
}
