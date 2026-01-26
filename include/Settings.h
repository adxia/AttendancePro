#ifndef SETTINGS_H
#define SETTINGS_H

#pragma once
#include <QObject>
#include <QSettings>
#include <QtQml/qqmlregistration.h>
#include <QUrl>

class Settings : public QObject {
    Q_OBJECT
    QML_ELEMENT
    //Q_PROPERTY(int pageSize READ pageSize WRITE setPageSize NOTIFY pageSizeChanged)
    Q_PROPERTY(QString savePath READ savePath WRITE setSavePath NOTIFY savePathChanged)
    Q_PROPERTY(int fileSize READ fileSize WRITE setFileSize NOTIFY fileSizeChanged)
    Q_PROPERTY(QString apiPath READ apiPath WRITE setApiPath NOTIFY apiPathChanged)
    Q_PROPERTY(QString outTime READ outTime WRITE setOutTime NOTIFY outTimeChanged)
    Q_PROPERTY(QString modelName READ modelName WRITE setModelName NOTIFY modelNameChanged)

public:
    explicit Settings(QObject* parent = nullptr);

    QString savePath() const{
        return m_settings.value("savePath", "").toString();
    };

    void setSavePath(const QString &path){

        if (path == savePath())
            return;
        QString localPath = QUrl(path).toLocalFile();

        m_settings.setValue("savePath", localPath);
        emit savePathChanged();
    };

    int fileSize(){
        return m_settings.value("fileSize", 5).toInt();
    }
    void setFileSize(int size){
        if (size == fileSize())
            return;
        m_settings.setValue("fileSize", size);
        emit fileSizeChanged();
    }

    QString apiPath() const{
        return m_settings.value("apiPath", "").toString();
    };

    void setApiPath(const QString &path){

        if (path == apiPath())
            return;
        m_settings.setValue("apiPath", path);
        emit apiPathChanged();
    };

    QString outTime() const{
        return m_settings.value("outTime","2000").toString();
    };

    void setOutTime(QString time){
        if (time== outTime())
            return;
        m_settings.setValue("outTime", time);
        emit outTimeChanged();
    };

    QString modelName() const{
        return m_settings.value("modelName","").toString();
    };

    void setModelName(QString name){
        if (name== modelName())
            return;
        m_settings.setValue("modelName", name);
        emit modelNameChanged();
    };

signals:
    void savePathChanged();
    void fileSizeChanged();
    void apiPathChanged();
    void outTimeChanged();
    void modelNameChanged();

private:
    QSettings m_settings;
};


#endif // SETTINGS_H
