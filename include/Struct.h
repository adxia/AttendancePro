#ifndef STRUCT_H
#define STRUCT_H
#include <QObject>
#include <QDate>

enum Roles {
    DisplayRole = Qt::DisplayRole,
    IdRole = Qt::UserRole + 1
};

enum TemplateType{
    Formal,
    Service
};

struct PersonRuleRow {
    qint64 id;          // 不显示
    QString userName;  // 显示
    QString userID;   // 显示
    QString userDepartment;
    QString ruleName;   // 显示
};

struct Rules {
    qint64 id;          // 不显示
    QString ruleName;  // 显示
    QString standardStart;   // 显示
    QString standardEnd;   // 显示
    QString standardHours;
    QString lunchStar;
    QString lunchEnd;
    int latetolerance;
    int leaveEarlytolerance;
};
struct RulePool {
    QTime standardStart;
    QTime standardEnd;
    QTime lunchStar;
    QTime lunchEnd;
    double standardHours;
    int latetolerance;
    int leaveEarlytolerance;
    double compensationHours = 0.0;
};

struct HolidayPatch{
    QDate date;
    bool isOffDay;   // true = 放假, false = 调休上班
    QString name;
};

struct AttendanceRecord {
    QString name;
    QDate date;
    QTime start;
    QTime end;
    bool isWorkday;
    double workHours;
    QString workDetail;
    QString note;
};

struct TempTime{
    QString name;
    QDate date;
    QVector<QTime> times;
};

struct WriteMap {
    int row;
    int col;
};

struct ExcelColumnMapping {
    int name = 1;
    int date = 2;
    int star = 3;
    int end = 4;
};



#endif // STRUCT_H
