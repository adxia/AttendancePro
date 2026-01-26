#include "RuleEngine.h"

RuleEngine::RuleEngine(DataManager* dataManager,Settings* setting,TemplateManager* templateManager):m_dataManager(dataManager),m_setting(setting),m_templateManager(templateManager)
{

}

void  RuleEngine::load(){
    loadRule();
    loadPerson();
    loadExcelMap();
};

const QVariantMap& RuleEngine::getExcelMap() const{
    return m_excelMap;
};

void RuleEngine::loadExcelMap(){
    if(m_templateManager && m_setting){
        QString name = m_setting->modelName();
        if(name != "")
        {
            m_excelMap = m_templateManager->getTemplate(name);
        }
    }
};

void  RuleEngine::loadRule(){
    m_rulePool.clear();
    QSqlQuery ruleQuery = m_dataManager->getRules();
    while (ruleQuery.next()) {
        RulePool pool;
        pool.standardStart = TimeUtils::parseTime(ruleQuery.value("standard_start").toString());
        pool.standardEnd = TimeUtils::parseTime(ruleQuery.value("standard_end").toString());
        pool.lunchStar = TimeUtils::parseTime(ruleQuery.value("lunch_star").toString());
        pool.lunchEnd = TimeUtils::parseTime(ruleQuery.value("lunch_end").toString());
        pool.standardHours = ruleQuery.value("standard_hours").toDouble();
        pool.latetolerance = ruleQuery.value("late_tolerance").toInt();
        pool.leaveEarlytolerance  = ruleQuery.value("leaveearly_tolerance").toInt();
        double actualWorkDuration = (pool.standardStart.secsTo(pool.standardEnd) / 3600.0)
                                    - (pool.lunchStar.secsTo(pool.lunchEnd) / 3600.0) - pool.standardHours;
        pool.compensationHours = actualWorkDuration < 0?actualWorkDuration:0;
        m_rulePool.insert(ruleQuery.value("rule_name").toString(), pool);
    }
};

void  RuleEngine::loadPerson(){
    m_personRule.clear();
    QSqlQuery query = m_dataManager->getPersonRules();
    while (query.next()) {
        QString userName = query.value("user_name").toString();
        QString ruleName = query.value("rule_name").toString();

        m_personRule.insert(userName, ruleName);
    }
};

double RuleEngine::calcStartOffset(QTime &star,const RulePool &rule) const{
    if (!star.isValid() || star.isNull()) {
        return -99.0; //漏打卡
    }
    double starOffsetMin = 0.0;
    double morningWorkMin =
        rule.standardStart.secsTo(rule.lunchStar) / 60;
    if(star>=rule.lunchEnd){
        //下午到：按实际时间计算
        int lunchtime = rule.lunchStar.secsTo(rule.lunchEnd)/60;
        int late = star.secsTo(rule.standardStart)/60;
        late = late + lunchtime;
        int units = qCeil((-late)/30.0);
        starOffsetMin = -( units * 0.5) + rule.compensationHours;
    }
    else if(star >= rule.lunchStar && star< rule.lunchEnd){
         // 上午缺勤：上午时间全扣除
        int late = rule.lunchStar.secsTo(rule.standardStart)/60.0;
        starOffsetMin = (late / 60.0) + rule.compensationHours;
    }

    else if(star < rule.lunchStar && star >= rule.standardStart){
        // 上午迟到：超过阈值按 30 分钟向上进位扣除

        int lateMin = rule.standardStart.secsTo(star) / 60;
        // 永远先扣除容忍时间

        int effectiveLateMin = lateMin - rule.latetolerance;

        if(effectiveLateMin > 0){
            int units = qCeil(effectiveLateMin / 30.0);
            starOffsetMin = -(units * 0.5);
            if (int(qAbs(starOffsetMin)) == morningWorkMin/60) {
                starOffsetMin += rule.compensationHours;
            }
        }
        else{
            starOffsetMin = 0.0;
        }
    }
    return starOffsetMin;
};


double RuleEngine::calcEndOffset(QTime &end,const RulePool &rule) const{
    if (!end.isValid() || end.isNull() ) {
        return -99.0; //漏打卡
    }
    double endOffsetMin=0.0;

    if(end < rule.lunchEnd && end > rule.lunchStar){
        //上半天下班
        endOffsetMin = rule.standardEnd.secsTo(rule.lunchEnd)/3600.0;
    }
    else if(end < rule.lunchStar && end > rule.standardStart){
        // 上午早退
        double afternoonLost = rule.lunchEnd.secsTo(rule.standardEnd) / 3600.0; // 4.5

        int earlyMorningMin = end.secsTo(rule.lunchStar) / 60;

        if (earlyMorningMin > rule.leaveEarlytolerance) {
            // 只要超过容差，就按30分钟阶梯扣
            int units = qCeil(earlyMorningMin / 30.0);

            // 最终偏移 = -下午全部 - 上午早退单元 - 补偿(因为没上满上午)
            endOffsetMin = -afternoonLost - (units * 0.5) - rule.compensationHours;
        } else {
            endOffsetMin = -afternoonLost;
        }
    }
    else if(end < rule.standardEnd && end > rule.lunchEnd){
        //下午早退
        int earlyMorningMin = end.secsTo(rule.standardEnd) / 60;

        if (earlyMorningMin > rule.leaveEarlytolerance) {

            int units = qCeil((earlyMorningMin+rule.leaveEarlytolerance) / 30.0);

            endOffsetMin = - (units * 0.5);
        }
    }
    else if(end > rule.standardEnd){
        //加班
        int earlyMorningMin = rule.standardEnd.secsTo(end) / 60;

        int units = (earlyMorningMin + rule.leaveEarlytolerance) / 30;

        endOffsetMin = units * 0.5;
    }
    return endOffsetMin;
};

void  RuleEngine::apply(QVector<AttendanceRecord>& records) const{
    for(auto &item:records){
        const QString ruleName = m_personRule.value(item.name);
        const RulePool &rule = m_rulePool.value(ruleName, m_rulePool.value("general"));
        double starOffsetMin = calcStartOffset(item.start,rule);
        double endOffsetMin = calcEndOffset(item.end,rule);
        if(item.isWorkday){
            if(starOffsetMin + endOffsetMin > -120 && starOffsetMin + endOffsetMin< -20){
                item.workHours = -100;
                item.note = "漏打卡";
            }
            else if(starOffsetMin + endOffsetMin < -180){
                item.workHours = -200;
                item.note = "缺勤";
            }
            else if(starOffsetMin + endOffsetMin < 20 && starOffsetMin + endOffsetMin >-12){

                item.workHours = starOffsetMin + endOffsetMin;

            }
            if(item.note.isEmpty() && starOffsetMin != 0.0){
                // 只有上班迟到/早退且不是漏打卡或缺勤才记录
                QString sign = (endOffsetMin >= 0) ? "+" : "";
                item.workDetail = QString("%1%2%3")
                                      .arg(starOffsetMin, 0, 'f', 1)
                                      .arg(sign)
                                      .arg(endOffsetMin, 0, 'f', 1);
            }
        }
        else{
            if(starOffsetMin + endOffsetMin > -120 && starOffsetMin + endOffsetMin< -20){
                item.workHours = -100;
                item.note = "漏打卡";
            }
            else if(starOffsetMin + endOffsetMin < -180){
                item.workHours = 0;
                item.note = "休息";
            }
            else if(starOffsetMin + endOffsetMin < 20 && starOffsetMin + endOffsetMin >-12){

                item.workHours = starOffsetMin + endOffsetMin + rule.standardHours;

            }
        }

    }
};
