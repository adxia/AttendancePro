#ifndef RULEENGINE_H
#define RULEENGINE_H
#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QDate>
#include "Struct.h"
#include "DataManager.h"
#include "Settings.h"
#include "TemplateManager.h"
#include "TimeUtils.h"


class RuleEngine:public QObject {
        Q_OBJECT
public:
    explicit RuleEngine(DataManager* dataManager=nullptr,Settings* setting=nullptr,TemplateManager* m_templateManager = nullptr);

    double calcStartOffset(QTime& star,const RulePool &rule) const;
    double calcEndOffset(QTime& end,const RulePool &rule) const;
    void apply(QVector<AttendanceRecord>& records) const;

    void loadPerson();

    QString getsavepath() const{
        if(m_setting){
           return m_setting->savePath();
        }
        return "";
    };

    void loadRule();

    const QVariantMap& getExcelMap() const;

    void loadExcelMap();
    void load();
private:
    QHash<QString, RulePool> m_rulePool;
    QHash<QString, QString> m_personRule;
    QVariantMap m_excelMap;
    DataManager* m_dataManager = nullptr;
    Settings* m_setting =nullptr;
    TemplateManager* m_templateManager = nullptr;
};


#endif // RULEENGINE_H
