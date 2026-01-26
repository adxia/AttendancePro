#ifndef ATTENDANCEPIPELINE_H
#define ATTENDANCEPIPELINE_H

#include <QObject>
#include "Struct.h"
#include "ExcelIo.h"
#include "HolidayManager.h"
#include "AttendanceCalculator.h"
#include "RuleEngine.h"
#include <QFuture>

class AttendancePipeline : public QObject {
    Q_OBJECT
public:
    explicit AttendancePipeline(QObject* parent = nullptr);

    bool run(const QString &inputfilepath,const QString &outfilepath,const QString &serviceoutfilepath,const RuleEngine* ruleengine);

     Q_INVOKABLE void startRun(const QString &inputfilepath,const QString &formaloutfilepath,const QString &serviceoutfilepath,const RuleEngine* ruleengine);

    Q_INVOKABLE void preloadInputFile(const QString &inputfilepath, const HolidayManager* holiday,const RuleEngine* ruleengine);

    ~AttendancePipeline();

signals:
    void error(const QString& msg);
    void finished();
    void progress(int percent);

private:
    ExcelIO* m_currentExcel = nullptr;
    QVector<AttendanceRecord> m_records;
    bool m_isDataReady = false;

    QFuture<bool> m_preloadTask;
    QMutex m_dataMutex; // 保护 m_records 避免在加载时被 run 访问

};


#endif // ATTENDANCEPIPELINE_H
