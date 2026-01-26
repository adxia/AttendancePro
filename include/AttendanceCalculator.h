#ifndef ATTENDANCECALCULATOR_H
#define ATTENDANCECALCULATOR_H
#include <QObject>
#include <QDate>
#include "ExcelIo.h"
#include "HolidayManager.h"
#include "Struct.h"


class AttendanceCalculator {
public:
    AttendanceCalculator(ExcelIO* excel, HolidayManager* holiday)
        : m_excel(excel), m_holiday(holiday) {}

    void process(QString &filepath) {
        m_excel->openFile(filepath); // 返回 QList<AttendanceRaw>
        auto rawData = m_excel->loadData();
        //QVector<AttendanceResult> results;

        // for (const auto& rec : rawData) {
        //     AttendanceResult res;
        //     res.name = rec.name;
        //     res.date = rec.date;
        //     res.start = rec.start;
        //     res.end = rec.end;
        //     res.isWorkday = m_holiday->isWorkday(rec.date);
        //     res.workHours = calculateHours(rec.start, rec.end, res.isWorkday);

        //     res.note = res.isWorkday ? "正常" : "休息";
        //     results.append(res);
        // }
        // m_excel->writeResults(results);
    }

private:
    double calculateHours(const QTime& start, const QTime& end, bool isWorkday) {
        if (!isWorkday) return 0.0;
        return start.secsTo(end) / 3600.0; // 转小时
    }

    ExcelIO* m_excel;
    HolidayManager* m_holiday;
};

#endif // ATTENDANCECALCULATOR_H
