#ifndef HOLIDAYMANAGER_H
#define HOLIDAYMANAGER_H
#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QDate>
#include <QDir>
#include "MessageCenter.h"
#include "Settings.h"
#include "Struct.h"
#include "ApiClient.h"

class HolidayManager : public QObject {
    Q_OBJECT

public:
    explicit HolidayManager(Settings* settings,QObject* parent = nullptr);
    bool isOffDay(const QDate& date) const;
    bool isWorkday(const QDate& date) const;
    QString holidayName(const QDate& date) const;
    Q_INVOKABLE void loadPatch();
    bool writeHoliday(QByteArray data);

    void applayWorkdayRule(QVector<AttendanceRecord>& records) const;
    Q_INVOKABLE void updateFromApi();
    Q_INVOKABLE void test();

private:
    Settings m_setting;
    QHash<QDate,HolidayPatch> m_patch;
};


#endif // HOLIDAYMANAGER_H
