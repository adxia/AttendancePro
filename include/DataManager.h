#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QVariant>
#include <QString>
#include <QDir>
#include <QFile>

class DataManager : public QObject
{
    Q_OBJECT
public:
    explicit DataManager(QObject* parent = nullptr);

    QString connectionName() const {
        return m_connectionName;
    }
    // 初始化数据库
    bool initDatabase(const QString& dbPath = "./Database/attendance_data.db");

    //计算规则
    QSqlQuery getRules(int id=0);
    QStringList getRuleName();
    qint64 insertRules(const QVariantMap &rule);
    qint64 getRuleIdByName(const QString& ruleName);
    bool updateRules(int id,const QVariantMap &rule);
    bool RemoveRules(int id);

    //员工
    qint64 getPersonIdByRule(int id);
    qint64 insertPersonRules(const QVariantMap &rule);
    bool updatePerson(int id,const QVariantMap &rule);
    bool RemovePersonRuleMap(int id);

    //员工与规则
    QSqlQuery getPersonRules(int id=0,const QString& name="");

    //excel映射模板
    bool insertTemplate(const QVariantMap &rule);
    bool updateTemplate(int id, const QVariantMap &rule);
    QSqlQuery getTemplate(int id=0);
    bool RemoveTemplate(int id);



private:
    bool createTables(QSqlQuery& query);
    bool ensureGeneralRule();



private:
    QSqlDatabase db;
    QString m_connectionName;
};
