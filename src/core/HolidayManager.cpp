#include "HolidayManager.h"

HolidayManager::HolidayManager(Settings* setting,QObject* parent)
    : QObject(parent),m_setting(setting)
{

}

bool HolidayManager::isOffDay(const QDate& date) const{
    if (!date.isValid()){
        return false;
    }
    // 1. patch 优先
    auto it = m_patch.constFind(date);
    if (it != m_patch.constEnd()) {
        return it->isOffDay;
    }

    // 2. 默认规则：周末放假
    int dayOfWeek = date.dayOfWeek(); // 1=Mon ... 7=Sun
    return dayOfWeek == 6 || dayOfWeek == 7;
}

bool HolidayManager::isWorkday(const QDate& date) const{
    if (!date.isValid())
    {
        return false;
    }

    // 1. patch 优先
    auto it = m_patch.constFind(date);
    if (it != m_patch.constEnd()) {
        return !(it->isOffDay);
    }
    // 2. 默认规则：周末放假
    int dayOfWeek = date.dayOfWeek(); // 1=Mon ... 7=Sun
    return dayOfWeek >= 1 && dayOfWeek <= 5;

}

QString HolidayManager::holidayName(const QDate& date) const{
    if (!date.isValid())
    {
        return "";
    }
    // 1. patch 优先
    auto it = m_patch.constFind(date);
    if (it != m_patch.constEnd()) {
        return it->name;
    }

    return "";
}

void HolidayManager::loadPatch(){
    QString base = QCoreApplication::applicationDirPath();
    QDir dir(base+"/setting");
    if (!dir.exists()) {
        emit MessageCenter::instance()->erromessage("节假日配置读取错误","配置文件不存在");
        return;
    };
    QFile file(dir.filePath("holiday_Patch.json"));
    if (!file.exists()) {
        emit MessageCenter::instance()->erromessage("节假日配置读取错误" ,"未查找到节假日配置文件，程序异常，请联系it。");
        return;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        emit MessageCenter::instance()->erromessage("节假日配置读取错误","节假日配置文件被异常占用，请退出占用后重启程序。");
        return;
    }
    QByteArray data = file.readAll();
    file.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError) {
        emit MessageCenter::instance()->erromessage("节假日配置文件解析错误",err.errorString());
        return;
    }
    m_patch.clear();
    QJsonObject obj = doc.object();
    QJsonArray patchArray = obj.value("patch").toArray();
    for (int i = 0; i < patchArray.size(); ++i) {
         const QJsonObject item = patchArray.at(i).toObject();
        HolidayPatch patch;

        QString dateStr = item.value("date").toString();
        QDate date = QDate::fromString(item.value("date").toString(),Qt::ISODate);

        if (!date.isValid()) {
            date = QDate::fromString(dateStr, "yyyy/M/d");
        }
        if (!date.isValid()) {
            date = QDate::fromString(dateStr, "yyyy/MM/dd");
        }
        if (!date.isValid()) {
            emit MessageCenter::instance()->erromessage("无法识别的日期格式", dateStr);
            continue;
        }
        patch.date =date;
        patch.isOffDay = item.value("isOffDay").toBool();
        patch.name = item.value("name").toString();
        m_patch.insert(date, patch);
    }
}

void HolidayManager::applayWorkdayRule(QVector<AttendanceRecord>& records) const{
    for(AttendanceRecord &item:records){
        if(item.date.isValid()){
            bool flag = isWorkday(item.date);
            item.isWorkday = flag;
        }
    }
};


bool HolidayManager::writeHoliday(QByteArray data){
    QJsonParseError err;
    auto doc = QJsonDocument::fromJson(data, &err);

    if (err.error != QJsonParseError::NoError) {
        emit MessageCenter::instance()->erromessage( "节假日数据错误",
                                                    "JSON 解析失败：" + err.errorString());
        return false;
    }
    if (doc.isNull() || doc.isEmpty()) {
        emit MessageCenter::instance()->erromessage(
            "节假日数据错误",
            "返回数据为空"
            );
        return false;
    }
    if (!doc.isObject()) {
        emit MessageCenter::instance()->erromessage(
            "节假日数据错误",
            "返回的JSON根节点不是对象"
            );
        return false;
    }
    QJsonObject root = doc.object();
    if (!root.contains("version") ||!root.contains("patch") || !root.value("patch").isArray()) {
        emit MessageCenter::instance()->erromessage(
            "节假日数据错误",
            "缺少 patch 字段"
            );
        return false;
    }

    QString base = QCoreApplication::applicationDirPath();
    QDir dir(base+"/setting");
    if (!dir.exists()) {
        bool ok = dir.mkpath(".");
        if(!ok){
            emit MessageCenter::instance()->erromessage("创建文件夹失败" ,"无法创建文件夹，请检查权限。");
            return false;
        }
    }

    QFile file(dir.filePath("holiday_Patch.json"));

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        emit MessageCenter::instance()->erromessage("节假日配置读取错误" ,"无法创建节假日文件，请检查权限");
        return false;
    }

    qint64 bytesWritten = file.write(data);
    file.close();

    if (bytesWritten != data.size()) {
        emit MessageCenter::instance()->erromessage(
            "节假日写入失败",
            "写入文件不完整，请检查磁盘空间或权限"
            );
        return false;
    }

    loadPatch();
    return true;
};

void HolidayManager::updateFromApi(){
    QString url = m_setting.apiPath();
    ApiClient api;
    int outtime = m_setting.outTime().toInt()>0?m_setting.outTime().toInt():500;
    api.getHoliday(url,outtime,[this](QByteArray data){
        bool ok = this->writeHoliday(data);
        if(ok){
            emit MessageCenter::instance()->successmessage("更新成功","节假日数据已更新。");
        }
    });
}
void HolidayManager::test(){
    QString url = m_setting.apiPath();
    ApiClient api;
    int outtime = m_setting.outTime().toInt()>0?m_setting.outTime().toInt():500;
    api.test(url,outtime);
}

