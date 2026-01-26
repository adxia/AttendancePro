#include "PersonRuleModel.h"
#include <QDebug>
#include "xlsxdocument.h"
#include "xlsxworksheet.h"
#include "MessageCenter.h"

PersonRule::PersonRule( QObject *parent): QAbstractTableModel(parent)
{
    m_dataheader = {"姓名","工号","项目/部门","使用规则"};
}
Q_INVOKABLE void PersonRule::init(DataManager* dataManager) {
    if (!m_dataManager)
        m_dataManager = dataManager;
    beginResetModel();
    m_data.clear();
    QSqlQuery query = m_dataManager->getPersonRules();
    while (query.next()) {
        PersonRuleRow row;
        row.id = query.value("id").toLongLong();
        row.userName = query.value("user_name").toString();
        row.userID = query.value("user_id").toString();
        row.userDepartment = query.value("user_department").toString();
        row.ruleName = query.value("rule_name").toString();
        m_data.append(row);
    }
    endResetModel();

}

void PersonRule::deleteRow(int row){

    if (row < 0 || row >= m_data.size())
        return;

    qint64 id = m_data[row].id;
    bool stauts = m_dataManager->RemovePersonRuleMap(id);
    if(stauts){
        beginRemoveRows(QModelIndex(), row, row);
        m_data.removeAt(row);
        endRemoveRows();
    }
    emit personChanged();
};


QVariant PersonRule::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role == Qt::DisplayRole && orientation == Qt::Horizontal) {
        if (section >= 0 && section < m_dataheader.size())
            return m_dataheader.at(section);
    }
    return QVariant();
}

int PersonRule::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_dataheader.size();

}

int PersonRule::rowCount(const QModelIndex &parent)const {
    if (parent.isValid())  // 避免递归
        return 0;
    return m_data.size();
}


QHash<int, QByteArray> PersonRule::roleNames() const
{
    return {
        {Qt::DisplayRole, "display"},
        {Qt::UserRole + 1, "id"}
    };
}

QVariant PersonRule::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};


    const auto &row = m_data[index.row()];
    if (role == Qt::DisplayRole) {
        switch (index.column()) {
        case 0: return row.userName;
        case 1: return row.userID;
        case 2: return row.userDepartment;
        case 3: return row.ruleName;

        }
    }
    if (role == Qt::UserRole + 1)
        return row.id;
    return {};
}


bool PersonRule::importFromExcel(const QString &filePath1){

        if(filePath1.isEmpty())
        {
            emit MessageCenter::instance()->erromessage(
            "导入错误", "没有选择任何文件。"
                );
            return false;
        }

        QString filePath = QUrl(filePath1).toLocalFile();
        if (!QFile::exists(filePath)) {
            emit MessageCenter::instance()->erromessage(
               "导入错误", "文件不存在，请检查路径。"
                );
            return false;
        }
        QFileInfo fileInfo(filePath);
        if (!fileInfo.exists()) {
            emit MessageCenter::instance()->erromessage("导入错误","文件不存在！");
            return false;
        }

        qint64 fileSize = fileInfo.size();
        const qint64 maxSize = 8 * 1024 * 1024; // 10 MB

        if (fileSize > maxSize) {
            emit MessageCenter::instance()->erromessage(
                "导入错误","文件过大（" + QString::number(fileSize / 1024.0 / 1024.0, 'f', 2) + " MB），支持的单个文件最大容量为 8 MB，请分次导入！");
            return false;
        }
        QXlsx::Document xlsx(filePath);
        //选择第一个sheet
        auto sheets = xlsx.sheetNames();
        if (!sheets.isEmpty())
            xlsx.selectSheet(sheets.first());

        QXlsx::Worksheet* sheet = dynamic_cast<QXlsx::Worksheet*>(xlsx.currentWorksheet());
        if (!sheet) {
            emit MessageCenter::instance()->erromessage(
                "导入错误",
                "无法访问源表。"
                );
            return false;
        }
        int lastRow = sheet->dimension().lastRow();
        int lastColumn = sheet->dimension().lastColumn();

        QVector<QString> header={"姓名","工号","项目","规则"};
        if(lastColumn!=header.size()){
            emit MessageCenter::instance()->erromessage(
                "模板错误",
                "表格模板不对，选择表列数："+ QString::number(lastColumn) +"；期望值："+QString::number(header.size())
                );
            return false;
        }
        for (int col = 1;col <= lastColumn;col++)
        {
            if(sheet->read(1, col).toString().trimmed().toUpper() != header[col-1])
            {
                emit MessageCenter::instance()->erromessage(
                    "模板错误",
                    "表格模板有误，请确认模板准确"
                    );
                return false;
            }
        }
        QSqlDatabase db = QSqlDatabase::database(m_dataManager->connectionName());
        //QSqlDatabase db = m_dataManager->getdatabase();
        if (!db.isValid() || !db.isOpen()) {
            emit MessageCenter::instance()->erromessage("数据库错误","数据库连接失败");
            return false;
        }
        if (!db.transaction()) {
            emit MessageCenter::instance()->erromessage(
                "数据库错误","事务开启失败"
                );
            return false;
        }
        for (int row = 2; row <= lastRow; ++row) {
            QVariantMap rec;
            qint64 id = m_dataManager->getRuleIdByName(sheet->read(row, 4).toString().trimmed());
            if(id<0){
                id = m_dataManager->getRuleIdByName("general");
                emit MessageCenter::instance()->warningmessage(
                    "警告",QString("第 %1 行计算规则未查询到，已回退到 general 规则").arg(row)
                    );
                //db.rollback();
                //return false;
            }
            rec["user_name"] = sheet->read(row, 1).toString().trimmed();
            rec["user_id"] = sheet->read(row, 2).toString().trimmed();
            rec["user_department"] = sheet->read(row, 3).toString().trimmed();
            rec["rule_id"] = id;
            qint64 result = m_dataManager->insertPersonRules(rec);
            if (result == -1) {
                // 重复数据（业务错误）
                emit MessageCenter::instance()->warningmessage(
                    "警告",QString("第 %1 行数据已存在，请检查数据").arg(row)
                    );
                db.rollback();
                return false;   // 或记录下来
            }
            if (result == -2) {
                // 系统错误
                db.rollback();
                emit MessageCenter::instance()->erromessage(
                    "数据库错误",QString("第 %1 行数据插入失败").arg(row)
                    );
                db.rollback();
                return false;
            }
        }
        if (!db.commit()) {
            emit MessageCenter::instance()->erromessage( "数据库错误","提交事务失败");
            return false;
        }
        // emit MessageCenter::instance()->successmessage(
        //     "导入成功，总计有 " + QString::number(lastRow-1) + " 条数据导入"
        //     );
        init();
        emit personChanged();
        return true;
}

QVariantMap PersonRule::getRow(int row) const
{
    const auto &r = m_data[row];
    return {
        {"id", r.id},
        {"userName", r.userName},
        {"userID", r.userID},
        {"userDepartment", r.userDepartment},
        {"ruleName", r.ruleName},
    };
}

bool PersonRule::applyRow(bool isedit,int row,const QVariantMap &form){

    if(isedit){
        int id = m_data[row].id;
        qint64 rule_id= m_dataManager -> getRuleIdByName(form.value("ruleName").toString());
        if (rule_id <= 0) {
            emit MessageCenter::instance()->erromessage("编辑失败","选择规则不存在");
            return false;
        }
        QVariantMap order;
        order["user_name"] = form.value("userName");
        order["user_id"] = form.value("userID");
        order["user_department"] = form.value("userDepartment");
        order["rule_id"] = rule_id;
        bool stauts = m_dataManager->updatePerson(id,order);
        if(!stauts) return false;
        emit MessageCenter::instance()->successmessage("操作成功",form.value("userName").toString()+" 信息更新成功");
    }
    else{
        QVariantMap order;
        qint64 rule_id= 1;
        //qint64 rule_id= m_dataManager -> getRuleIdByName(form.value("ruleName").toString());
        if (rule_id <= 0) {
            emit MessageCenter::instance()->erromessage("新增失败","规则不存在");
            return false;
        }
        order["user_name"] = form.value("userName");
        order["user_id"] = form.value("userID");
        order["user_department"] = form.value("userDepartment");
        order["rule_id"] = rule_id;
        qint64 stauts = m_dataManager->insertPersonRules(order);
        if(stauts<0) return false;
        emit MessageCenter::instance()->successmessage("操作成功",form.value("userName").toString()+" 信息添加成功");
    }

    init();
    emit personChanged();
    return true;
}


