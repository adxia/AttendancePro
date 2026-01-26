#ifndef TEMPLATEMANAGER_H
#define TEMPLATEMANAGER_H

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include "DataManager.h"
#include "MessageCenter.h"


class TemplateManager : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QStringList templateNames READ templateNames NOTIFY templateChanged)
public:

    explicit TemplateManager(QObject* parent = nullptr);

    // 初始化读取所有模板
    void loadTemplates(DataManager* manager);

    // 返回模板名列表
    QStringList templateNames() const;

    // 根据模板名获取完整模板对象（JSON 或 QVariantMap）
    Q_INVOKABLE QVariantMap getTemplate(const QString& name) const;

    Q_INVOKABLE bool applayTemplate(bool isedit,const QVariantMap& tpl);

    Q_INVOKABLE bool deletetemplate(int id);

signals:
    void templatesUpdated();
    void templateChanged();

private:
    DataManager* m_dataManager = nullptr;
    QStringList m_templateName;
    QHash<QString,int> m_nameforid;

};


#endif // TEMPLATEMANAGER_H
