#pragma once
#ifndef TABLEMODEL_H
#define TABLEMODEL_H
#include <qobject.h>
#include <QAbstractTableModel>
#include <QVector>
#include <QtQml/qqmlregistration.h>
#include "DataManager.h"
#include <QFile>
#include <QString>
#include <QVector>
#include <QDate>
#include <QtConcurrent/QtConcurrentRun>
//#include "ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "Struct.h"
#include "TimeUtils.h"

class TableModel : public QAbstractTableModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int totalCount READ rowCount NOTIFY totalCountChanged);
    Q_PROPERTY(QStringList ruleNames READ ruleNames NOTIFY ruleNamesChanged)
signals:
    void rulesChanged();
    void ruleNamesChanged();
    void totalCountChanged();
    void dataReady(QJsonObject response);

public:
    explicit TableModel(QObject *parent = nullptr);

    QStringList ruleNames() const { return m_ruleNames;}

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    void init(DataManager* manager);
    void loaddata(int id=0);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE void adddata();
    //Q_INVOKABLE bool importFromExcel(const QString &filePath);
    //Q_INVOKABLE void getDataAsync();
   // void tabFilter(const QString &msg);
    Q_INVOKABLE void deleteRow(int index);
    Q_INVOKABLE QVariantMap getRow(int row) const;

    Q_INVOKABLE bool applyRow(bool isedit,int row,const QVariantMap &form);
    //void search(const QString &msg);


private:
    QStringList m_ruleNames;
    QString m_search="";
    QString m_filterstauts="allstauts";
    QString m_importmsg;
    QVector<Rules> m_data;
    QVector<QString> m_dataheader;
    DataManager* m_dataManager = nullptr;
    QMutex printMutex;
    int groupIndex = 0;

};

#endif // TABLEMODEL_H
