#include "FileManager.h"


FileManager* FileManager::m_instance = nullptr;

// 获取目录
QString FileManager::configFolder(ConfigType type) const {
    QString base = QCoreApplication::applicationDirPath();
    switch (type) {
    case GlobalSettings:
        return base + "/setting";
    }
    return base;
}
// 获取完整路径
QString FileManager::configFile(ConfigType type) const {
    QString folder = configFolder(type);
    QDir dir(folder);
    if (!dir.exists()) dir.mkpath(".");
    switch (type) {
    case GlobalSettings: return dir.filePath("global_settings.json");
    }
    return "";
}

// 加载配置
bool FileManager::loadConfig(ConfigType type) {

    QString path = configFile(type);
    QFile file(path);
    if (!file.exists()) {
        createDefaultConfig(type);
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot open config file:" << path;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error:" << err.errorString();
        return false;
    }

    QJsonObject obj = doc.object();
    switch (type) {
    case GlobalSettings: m_globalSettings = obj; break;
    }

    emit configChanged();
    return true;
}

// 保存配置
bool FileManager::saveConfig(ConfigType type) {

    QString path = configFile(type);
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qDebug() << "Cannot write config file:" << path;
        return false;
    }

    QJsonDocument doc;
    switch (type) {
    case GlobalSettings: doc.setObject(m_globalSettings); break;
    }

    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

// 获取值
QVariant FileManager::getValue(ConfigType type, const QString &key) const {
    switch (type) {
    case GlobalSettings: return m_globalSettings.value(key).toVariant();
    }
    return {};
}

// 设置值
void FileManager::setValue(ConfigType type, const QString &key, const QVariant &value) {
    switch (type) {
    case GlobalSettings: m_globalSettings[key] = QJsonValue::fromVariant(value); break;
    }
    emit configChanged();
}

void FileManager::createDefaultConfig(ConfigType type) {
    QJsonObject obj;
    switch (type) {

    case GlobalSettings:
        obj["themeColors"] = "lightTheme";
        break;
    }

    // 保存到对应的文件
    QString path = configFile(type);
    QFile file(path);
    QDir dir = QFileInfo(file).dir();
    if (!dir.exists()) dir.mkpath(".");  // 先确保目录存在
    if (file.open(QIODevice::WriteOnly)) {
        QJsonDocument doc(obj);
        file.write(doc.toJson(QJsonDocument::Indented));
        file.close();
    }

    // 保存到内存
    switch (type) {
    case GlobalSettings: m_globalSettings = obj; break;
    }
}
