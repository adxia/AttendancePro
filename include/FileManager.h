#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QVariant>
#include <QFile>
#include <QJsonDocument>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QCoreApplication>


class FileManager : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString themeColors READ themeColors WRITE setThemeColors NOTIFY themeColorsChanged)
public:
    enum ConfigType {
        GlobalSettings,
    };
    Q_ENUM(ConfigType)

    explicit FileManager(QObject *parent = nullptr):m_globalSettings()
    {
        loadConfig(GlobalSettings);
    }
    //读取主题
    QString themeColors() const {
        return m_globalSettings.value("themeColors").toString();
    }
    //保存主题
    void setThemeColors(const QString &color) {
          m_globalSettings["themeColors"] = color;
          saveConfig(GlobalSettings);
          emit themeColorsChanged(color);

    }



    Q_INVOKABLE bool loadConfig(ConfigType type = static_cast<ConfigType>(0)); // -1 表示读取所有
    Q_INVOKABLE bool saveConfig(ConfigType type = static_cast<ConfigType>(0));

    Q_INVOKABLE QVariant getValue(ConfigType type, const QString &key) const;
    Q_INVOKABLE void setValue(ConfigType type, const QString &key, const QVariant &value);

signals:
    void themeColorsChanged(const QString& color);
    void configChanged();

private:
    static FileManager* m_instance;
    QJsonObject m_globalSettings;


    QString configFolder(ConfigType type) const;
    QString configFile(ConfigType type) const;
    void createDefaultConfig(ConfigType type);
};

#endif // FILEMANAGER_H
