#include "Tablemodel.h"
#include "DataManager.h"
#include "QDateTime"
#include <QDebug>
#include "xlsxdocument.h"
#include "xlsxworksheet.h"
#include "MessageCenter.h"

using namespace QXlsx;


TableModel::TableModel(QObject *parent) : QAbstractTableModel(parent)
{
    //connect(MessageCenter::instance(), &MessageCenter::tabelchangemessage, this, &TableModel::tabFilter);
    //connect(MessageCenter::instance(), &MessageCenter::search, this, &TableModel::search);
    m_dataheader = {"规则名称","上班时间","下班时间","上班时长","迟到阈值","早退阈值"};
}

//读取数据/筛选匹配
void TableModel::loaddata(int id){
    m_data.clear();
    beginResetModel();
    QSqlQuery query;
    if(id != 0){
       query = m_dataManager->getRules(id);
    }
    else{
       query = m_dataManager->getRules();
    }

    // late_tolerance  INTEGER DEFAULT 0,
    // leaveearly_tolerance INTEGER DEFAULT 0,
    while (query.next() ) {
        Rules row;
        row.id = query.value("id").toLongLong();
        row.ruleName = (query.value("rule_name").toString());
        row.standardStart = (query.value("standard_start").toString());
        row.standardEnd = (query.value("standard_end").toString());
        row.standardHours = (query.value("standard_hours").toString());
        row.lunchStar = (query.value("lunch_star").toString());
        row.lunchEnd = (query.value("lunch_end").toString());
        row.latetolerance = query.value("late_tolerance").toLongLong();
        row.leaveEarlytolerance = query.value("leaveearly_tolerance").toLongLong();
        m_data.push_back(row);
    }
    endResetModel();
    m_ruleNames = m_dataManager->getRuleName();
    emit ruleNamesChanged();
    emit totalCountChanged();
}

//初始化数据库
void TableModel::init(DataManager* manager) {
    if (m_dataManager==nullptr)
        m_dataManager = manager;
    loaddata();
}

int TableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return static_cast<int>(m_data.size());

}

int TableModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_dataheader.size();

}


QVariant TableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};
    const auto &row = m_data[index.row()];
    if (role == Qt::DisplayRole) {
        switch (index.column()) {
        case 0: return row.ruleName;
        case 1: return row.standardStart;
        case 2: return row.standardEnd;
        case 3: return row.standardHours;
        case 4: return row.latetolerance;
        case 5: return row.leaveEarlytolerance;
        }
    }
    if (role == Qt::UserRole + 1)
        return row.id;
    return {};
}

QVariant TableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role == Qt::DisplayRole && orientation == Qt::Horizontal) {
        if (section >= 0 && section < m_dataheader.size())
            return m_dataheader.at(section);
    }
    return QVariant();
}


QHash<int, QByteArray> TableModel::roleNames() const
{
    return {
        {Qt::DisplayRole, "display"},
        {Qt::UserRole + 1, "id"}
    };
}


void TableModel::deleteRow(int row){

    if(m_data[row].ruleName == "general"){
        emit MessageCenter::instance()->erromessage("删除失败","通用规则不允许删除。");
        return;
    }
    if (row < 0 || row >= m_data.size())
        return;
    qint64 id = m_data[row].id;
    bool status = m_dataManager->RemoveRules(id);
    if (status){
        init(m_dataManager);
    }
    emit rulesChanged();
};

QVariantMap TableModel::getRow(int row) const
{
    const auto &r = m_data[row];
    return {
        {"id", r.id},
        {"ruleName", r.ruleName},
        {"standardStart", r.standardStart},
        {"standardEnd", r.standardEnd},
        {"standardHours", r.standardHours},
        {"lunchStar", r.lunchStar},
        {"lunchEnd", r.lunchEnd},
        {"latetolerance", r.latetolerance},
        {"leaveEarlytolerance", r.leaveEarlytolerance}
    };
}

void TableModel::adddata(){

    QChar letter = QChar('A' + groupIndex);
    QVariantMap order;
    order["rule_name"] = QString("Group %1").arg(letter);
    order["standard_start"] = "9:00";
    order["standard_end"] = "18:00";
    order["standard_hours"] = "8";
    order["tolerance"] = "5";
    m_dataManager->insertRules(order);
    groupIndex++;
    // 写入数据库
    init(m_dataManager);
    emit rulesChanged();
}

bool TableModel::applyRow(bool isedit,int row,const QVariantMap &form){

    bool isstar = TimeUtils::isValidTime(form.value("standardStart").toString());
    bool isend = TimeUtils::isValidTime(form.value("standardEnd").toString());
    if(!isstar){
        emit MessageCenter::instance()->erromessage("错误","上班时间格式错误。");
        return false;
    }
    if(!isend){
        emit MessageCenter::instance()->erromessage("错误","下班时间格式错误。");
        return false;
    }

    if(isedit){
        // if(form.value("ruleName")=="general"){
        //     emit MessageCenter::instance()->erromessage("通用规则不允许修改!");
        //     return false;
        // }
        int id = m_data[row].id;
        QVariantMap order;
        order["rule_name"] = form.value("ruleName");
        order["standard_start"] = form.value("standardStart");
        order["standard_end"] = form.value("standardEnd");
        order["lunch_star"] = form.value("lunchStar");
        order["lunch_end"] = form.value("lunchEnd");
        order["standard_hours"] = form.value("standardHours");
        order["late_tolerance"] = form.value("latetolerance");
        order["leaveearly_tolerance"] = form.value("leaveEarlytolerance");
        bool stauts = m_dataManager->updateRules(id,order);
        if(!stauts) return false;
        emit MessageCenter::instance()->successmessage("操作成功",form.value("ruleName").toString()+" 规则更新成功");
    }
    else{
        QVariantMap order;
        order["rule_name"] = form.value("ruleName");
        order["standard_start"] = form.value("standardStart");
        order["standard_end"] = form.value("standardEnd");
        order["lunch_star"] = form.value("lunchStar");
        order["lunch_end"] = form.value("lunchEnd");
        order["standard_hours"] = form.value("standardHours");
        order["late_tolerance"] = form.value("latetolerance");
        order["leaveearly_tolerance"] = form.value("leaveEarlytolerance");
        qint64 stauts = m_dataManager->insertRules(order);
        if(stauts<0) return false;
        emit MessageCenter::instance()->successmessage("操作成功",form.value("ruleName").toString()+" 规则新增成功");
    }
    init(m_dataManager);
    emit rulesChanged();
    return true;
}




