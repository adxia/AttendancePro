#include "DataManager.h"
#include <QDebug>
#include <QSqlError>
#include "MessageCenter.h"

DataManager::DataManager(QObject* parent)
    : QObject(parent)
{
}

// 初始化数据库
bool DataManager::initDatabase(const QString& dbPath)
{
    // 确保目录存在
    QFile file(dbPath);
    QDir dir = QFileInfo(file).dir();
    if (!dir.exists()) dir.mkpath(".");


    m_connectionName = QString("DataManager_%1").arg(reinterpret_cast<quintptr>(this));

    // 如果连接已存在，先用现有连接
    QSqlDatabase db;
    if (QSqlDatabase::contains(m_connectionName)) {
        db = QSqlDatabase::database(m_connectionName);
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
        db.setDatabaseName(dbPath);
        if (!db.open()) {
            emit MessageCenter::instance()->erromessage("数据库错误","无法打开数据库");
            return false;
        }
    }
    // 创建表
    QSqlQuery query(db);
    if (!createTables(query)) {
        emit MessageCenter::instance()->erromessage("数据库错误","数据库表创建失败");
        return false;
    }
    if (!ensureGeneralRule()) {
        emit MessageCenter::instance()->erromessage("数据库错误","创建默认规则失败");
        return false;
    }

    return true;
}

QSqlQuery DataManager::getRules(int id)
{
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    QString sql = "SELECT  DISTINCT * FROM Rules  WHERE Rules.is_delete = 0 AND 1=1";
    if (id!=0)   sql += " AND Rules.id = :id";
    query.prepare(sql);
    if (id != 0) {
        query.bindValue(":id", id);
    }
    if (!query.exec()) {
        qWarning() << "getRules failed:" << query.lastError().text();
    }
    return query;
}


QStringList DataManager::getRuleName()
{
    QStringList result;
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    QString sql = "SELECT  DISTINCT Rules.rule_name  FROM Rules";

    query.prepare(sql);

    if (!query.exec()) {
        emit MessageCenter::instance()->erromessage("规则名查询错误", query.lastError().text());
        return result;
    }
    while (query.next()) {
        result << query.value(0).toString();
    }
    return result;
}

qint64 DataManager::getRuleIdByName(const QString& ruleName)
{
    if (ruleName.isEmpty()) {
        qWarning() << "getRuleIdByName called with empty ruleName";
        return -1;
    }
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(
        SELECT id
        FROM Rules
        WHERE rule_name = :ruleName
          AND is_delete = 0
        LIMIT 1
    )");

    query.bindValue(":ruleName", ruleName);

    if (!query.exec()) {
        qWarning() << "getRuleIdByName failed:" << query.lastError().text();
        return -1;
    }
    if (query.next()) {
        return query.value(0).toLongLong();
    }
    // 未找到
     return -1;
}
qint64 DataManager::getPersonIdByRule(int id){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare("select UserRuleMap.id from UserRuleMap where UserRuleMap.rule_id=:id");
    query.bindValue(":id", id);
    if (!query.exec()) {
        qWarning() << "getPersonIdByRule failed:" << query.lastError().text();
        return -1;
    }
    if (query.next()) {
        return query.value(0).toLongLong();
    }
    return -1;
}

QSqlQuery DataManager::getPersonRules(int id,const QString &name)
{
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    QString sql = "SELECT  DISTINCT UserRuleMap.id,UserRuleMap.user_name, UserRuleMap.user_id,UserRuleMap.user_department, Rules.rule_name  FROM UserRuleMap Left Join Rules on UserRuleMap.rule_id = Rules.id where  1=1";
    if (id!=0)   sql += " AND UserRuleMap.id = :id";
    if(!name.isEmpty())  sql += " AND UserRuleMap.user_name = :user_name";
    query.prepare(sql);
    if (id != 0) {
        query.bindValue(":id", id);
    }
    if (!name.isEmpty()) {
        query.bindValue(":user_name", name);
    }

    if (!query.exec()) {
        qWarning() << "getPersonRules failed:" << query.lastError().text();
    }
    return query;
}

bool DataManager::updateRules(int id,const QVariantMap &rule){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(UPDATE Rules
    SET rule_name = :rule_name,
        standard_start = :standard_start,
        standard_end = :standard_end,
        lunch_star = :lunchStar,
        lunch_end = :lunchEnd,
        standard_hours = :standard_hours,
        late_tolerance = :late_tolerance,
        leaveearly_tolerance = :leaveearly_tolerance

    WHERE id = :id
    )");
    query.bindValue(":rule_name", rule.value("rule_name"));
    query.bindValue(":standard_start", rule.value("standard_start"));
    query.bindValue(":standard_end", rule.value("standard_end"));
    query.bindValue(":lunchStar", rule.value("lunch_star"));
    query.bindValue(":lunchEnd", rule.value("lunch_end"));
    query.bindValue(":standard_hours", rule.value("standard_hours"));
    query.bindValue(":late_tolerance", rule.value("late_tolerance"));
    query.bindValue(":leaveearly_tolerance", rule.value("leaveearly_tolerance"));
    query.bindValue(":id", id);
    if (!query.exec()) {
        QString errText = query.lastError().text();
        if (errText.contains("UNIQUE constraint failed", Qt::CaseInsensitive)) {
            emit MessageCenter::instance()->erromessage("规则名不能重复",  errText);
        }
        else{
            emit MessageCenter::instance()->erromessage("编辑失败了", errText);
        }
        return false;
    }
    return true;
}

// ExcelData CRUD
qint64 DataManager::insertRules(const QVariantMap &rule)
{
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(
        INSERT INTO Rules (rule_name, standard_start, standard_end,lunch_star,lunch_end, standard_hours, late_tolerance,leaveearly_tolerance)
        VALUES (:rule_name, :standard_start, :standard_end,:lunch_star,:lunch_end, :standard_hours, :late_tolerance,:leaveearly_tolerance)
    )");
    query.bindValue(":rule_name", rule.value("rule_name"));
    query.bindValue(":standard_start", rule.value("standard_start"));
    query.bindValue(":standard_end", rule.value("standard_end"));
    query.bindValue(":lunch_star", rule.value("lunch_star"));
    query.bindValue(":lunch_end", rule.value("lunch_end"));
    query.bindValue(":standard_hours", rule.value("standard_hours"));
    query.bindValue(":late_tolerance", rule.value("late_tolerance"));
    query.bindValue(":leaveearly_tolerance", rule.value("leaveearly_tolerance"));
    if (!query.exec()) {
        QString errText = query.lastError().text();
        if (errText.contains("UNIQUE constraint failed", Qt::CaseInsensitive)) {
            emit MessageCenter::instance()->erromessage("规则名不能重复", errText);
            return -1;  // 重复
        } else {
            emit MessageCenter::instance()->erromessage("新增失败了", errText);
            return -2;  // 其他错误
        }
    }
    return query.lastInsertId().toLongLong();
}


qint64 DataManager::insertPersonRules(const QVariantMap &rule)
{
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(
        INSERT INTO UserRuleMap (user_name,user_id,user_department,rule_id)
        VALUES (:user_name,:user_id,:user_department,:rule_id)
    )");
    query.bindValue(":user_name", rule.value("user_name"));
    query.bindValue(":user_id", rule.value("user_id"));
    query.bindValue(":user_department", rule.value("user_department"));
    query.bindValue(":rule_id", rule.value("rule_id"));

    if (!query.exec()) {
        QString errText = query.lastError().text();
        if (errText.contains("UNIQUE constraint failed", Qt::CaseInsensitive)) {
            return -1;  // 重复
        } else {
            return -2;  // 其他错误
        }
    }
    return query.lastInsertId().toLongLong();
}


bool DataManager::insertTemplate(const QVariantMap &data)
{
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(
        INSERT INTO template_config (model_name,data)
        VALUES (:model_name,:data)
    )");
    query.bindValue(":model_name", data.value("model_name"));
    query.bindValue(":data", data.value("data"));

    if (!query.exec()) {
        QString errText = query.lastError().text();
        if (errText.contains("UNIQUE constraint failed", Qt::CaseInsensitive)) {
            emit MessageCenter::instance()->erromessage("新增失败","模型名称不允许重复，请修改名称。");
            return false;  // 重复
        } else {
            emit MessageCenter::instance()->erromessage("新增失败",errText);
            return false;  // 其他错误
        }
    }
    return true;
}

bool DataManager::updateTemplate(int id,const QVariantMap &data){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(UPDATE template_config
    SET model_name = :model_name,
        data = :data
    WHERE id = :id
    )");
    query.bindValue(":id", id);
    query.bindValue(":model_name", data.value("model_name"));
    query.bindValue(":data", data.value("data"));

    if (!query.exec()) {
        QString errText = query.lastError().text();
        if (errText.contains("UNIQUE constraint failed", Qt::CaseInsensitive)) {
            emit MessageCenter::instance()->erromessage("更新失败",  "模型名称不允许重复，请修改名称。");
        }
        else{
            emit MessageCenter::instance()->erromessage("更新失败", errText);
        }
        return false;
    }
    return true;
};
QSqlQuery DataManager::getTemplate(int id){

    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    QString sql = "SELECT  DISTINCT template_config.id,template_config.model_name,template_config.data  FROM template_config where  1=1";
    if (id!=0)   sql += " AND template_config.id = :id";

    query.prepare(sql);
    if (id != 0) {
        query.bindValue(":id", id);
    }
    if (!query.exec()) {
        emit MessageCenter::instance()->erromessage("映射模型获取失败", query.lastError().text());
    }
    return query;

};

bool DataManager::RemoveTemplate(int id){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    QString sql = "DELETE FROM template_config where id = :id";
    query.prepare(sql);
    query.bindValue(":id",id);
    if (!query.exec()) {
        emit MessageCenter::instance()->erromessage("删除失败", query.lastError().text());
        return false;
    }
    return true;
}

bool DataManager::updatePerson(int id,const QVariantMap &rule){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare(R"(UPDATE UserRuleMap
    SET user_name = :user_name,
        user_id = :user_id,
        user_department = :user_department,
        rule_id = :rule_id
    WHERE id = :id
    )");
    query.bindValue(":user_name", rule.value("user_name"));
    query.bindValue(":user_id", rule.value("user_id"));
    query.bindValue(":user_department", rule.value("user_department"));
    query.bindValue(":rule_id", rule.value("rule_id"));
    query.bindValue(":id", id);
    if (!query.exec()) {
        QString errText = query.lastError().text();
        if (errText.contains("UNIQUE constraint failed", Qt::CaseInsensitive)) {
            emit MessageCenter::instance()->erromessage("员工名和工号不能同时重复", errText);
        }
        else{
            emit MessageCenter::instance()->erromessage("编辑失败了", errText);
        }
        return false;
    }
    return true;
}

bool  DataManager::RemovePersonRuleMap(int id){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    QString sql = "DELETE FROM UserRuleMap where id = :id";
    query.prepare(sql);
    query.bindValue(":id",id);
    if (!query.exec()) {
        emit MessageCenter::instance()->erromessage("删除失败", query.lastError().text());
        return false;
    }
    return true;
}

bool  DataManager::RemoveRules(int id){
    QSqlQuery query(QSqlDatabase::database(m_connectionName));
    query.prepare("SELECT COUNT(*) FROM UserRuleMap WHERE rule_id = :id");
    query.bindValue(":id", id);

    if (!query.exec() || !query.next()) {
        emit MessageCenter::instance()->erromessage("规则删除失败","未查询到该规则，请刷新数据。");
        return false;
    }

    if (query.value(0).toInt() > 0) {
        emit MessageCenter::instance()->erromessage("规则删除失败","无法删除该规则，有人员正在使用");
        return false;
    }

    QString sql = "DELETE FROM Rules where id = :id";
    query.prepare(sql);
    query.bindValue(":id",id);
    if (!query.exec()) {
        emit MessageCenter::instance()->erromessage("规则删除失败", query.lastError().text());
        return false;
    }
    emit MessageCenter::instance()->successmessage("规则删除成功","规则已成功删除");
    return true;
}

bool DataManager::ensureGeneralRule()
{
    // 获取数据库连接
    QSqlQuery query(QSqlDatabase::database(m_connectionName));

    // 检查 general 规则是否存在
    query.prepare("SELECT COUNT(*) FROM Rules WHERE rule_name = :ruleName");
    query.bindValue(":ruleName", "general");
    if (!query.exec()) {
        qWarning() << "check general rule failed:" << query.lastError().text();
        return false;
    }

    if (query.next()) {
        int count = query.value(0).toInt();
        if (count == 0) {
            // 不存在就插入
            query.prepare(R"(
                INSERT INTO Rules (rule_name, standard_start, standard_end,lunch_star,lunch_end, standard_hours, late_tolerance,leaveearly_tolerance)
                VALUES (:ruleName, :start, :end,:lunchstar,:lunchend, :hours, :latetolerance,:leaveearlytolerance)
            )");
            query.bindValue(":ruleName", "general");
            query.bindValue(":start", "08:30");
            query.bindValue(":end", "17:00");
            query.bindValue(":lunchstar", "11:30");
            query.bindValue(":lunchend", "12:30");
            query.bindValue(":hours", "8");
            query.bindValue(":latetolerance", 15);
            query.bindValue(":leaveearlytolerance", 5);
            if (!query.exec()) {
                qWarning() << "insert general rule failed:" << query.lastError().text();
                return false;
            }
        }
    }
    return true;
}

// 创建表
bool DataManager::createTables(QSqlQuery& query)
{
    if (!query.exec(R"(
        CREATE TABLE IF NOT EXISTS Rules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rule_name TEXT NOT NULL,
            standard_start   TEXT NOT NULL,
            standard_end TEXT NOT NULL,
            lunch_star TEXT NOT NULL,
            lunch_end TEXT NOT NULL,
            standard_hours TEXT,
            late_tolerance  INTEGER DEFAULT 0,
            leaveearly_tolerance INTEGER DEFAULT 0,
            is_delete INTEGER DEFAULT 0,
            create_time DATETIME DEFAULT (datetime('now','localtime')),
            update_time DATETIME CURRENT_TIMESTAMP,
            extra TEXT,
            UNIQUE(rule_name)
        )
    )")) return false;

    if (!query.exec(R"(
       CREATE TABLE IF NOT EXISTS UserRuleMap (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rule_id INTEGER NOT NULL,
            user_name Text NOT NULL,
            user_id Text,
            user_department Text,
            is_delete INTEGER DEFAULT 0,
            create_time DATETIME DEFAULT (datetime('now','localtime')),
            update_time DATETIME CURRENT_TIMESTAMP,
            extra TEXT,
            FOREIGN KEY(rule_id) REFERENCES Rules(id),
            UNIQUE(user_name,user_id)
        )
    )")) return false;

    if (!query.exec(R"(
        CREATE TABLE template_config (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            model_name TEXT UNIQUE NOT NULL,
            data TEXT NOT NULL,
            UNIQUE(model_name)
        )
    )")) return false;

    return true;
}
