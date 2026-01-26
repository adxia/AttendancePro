#include "TemplateManager.h"
#include "Struct.h"


TemplateManager::TemplateManager(QObject* parent){

};

// 初始化读取所有模板
void TemplateManager::loadTemplates(DataManager* manager){
    if (!m_dataManager)
        m_dataManager = manager;
    m_templateName.clear();
    QSqlQuery query = m_dataManager->getTemplate();
    while (query.next()) {
        int id = query.value("id").toLongLong();
        QString name = query.value("model_name").toString();
        m_templateName.append(name);
        m_nameforid.insert(name,id);
    }
    emit templateChanged();
};

// 返回模板名列表
QStringList TemplateManager::templateNames() const{
    return m_templateName;

};

// 根据模板名获取完整模板对象（JSON 或 QVariantMap）
QVariantMap TemplateManager::getTemplate(const QString& name) const{
    QVariantMap result;
    if (!m_dataManager){
        emit MessageCenter::instance()->erromessage("模板初始化错误","模板初始化数据库错误，请重启程序。");
        return result;
    }
    int id = m_nameforid.value(name,-1);
    if(id==-1){
        emit MessageCenter::instance()->erromessage("模板获取错误","不存在 "+ name+" 名字的模板。");
        return result;
    }
    QSqlQuery query = m_dataManager->getTemplate(id);

    if (!query.next()) {
        emit MessageCenter::instance()->erromessage(
            "模板获取错误",
            "模板 " + name + " 数据为空。"
            );
        return result;
    }

    QString jsonText = query.value("data").toString();
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(jsonText.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        emit MessageCenter::instance()->erromessage("JSON解析错误",parseError.errorString());
        return result; // 返回空 map
    }

    if (doc.isObject()) {
        result = doc.object().toVariantMap(); // 转成 QVariantMap
    } else {
        emit MessageCenter::instance()->erromessage("JSON解析错误","不是对象类型的 JSON");
    }
    result.insert("id",query.value("id").toInt());
    return result;

};

bool TemplateManager::applayTemplate(bool isedit,const QVariantMap& tpl){

    QVariantMap formCopy = tpl; // 先拷贝一份，避免修改原始对象
    formCopy.remove("id");

    QJsonObject jsonObj = QJsonObject::fromVariantMap(formCopy);
    QJsonDocument doc(jsonObj);
    QString data = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));

    QVariantMap order;
    order["model_name"] = tpl.value("modelName").toString();
    order["data"] = data;

    if(isedit){
        int id = tpl.value("id").toInt();

        bool stauts = m_dataManager->updateTemplate(id,order);

        if(!stauts) return false;
        if(m_templateName.indexOf(order["model_name"])>=0){
            emit templatesUpdated();
        }
        emit MessageCenter::instance()->successmessage("操作成功",tpl.value("modelName").toString()+" 模板更新成功");
    }
    else{
        bool stauts = m_dataManager->insertTemplate(order);
        if(!stauts) return false;
        emit MessageCenter::instance()->successmessage("操作成功",tpl.value("modelName").toString()+" 模板新增成功");
    }

    loadTemplates(m_dataManager);
    return true;

};

bool TemplateManager::deletetemplate(int id){
    bool stauts = m_dataManager->RemoveTemplate(id);
    if(stauts){
        emit MessageCenter::instance()->successmessage("删除成功","模板删除成功");
        loadTemplates(m_dataManager);
    }
    return stauts;

}

