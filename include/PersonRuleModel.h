#ifndef PERSONRULEMODEL_H
#define PERSONRULEMODEL_H

#include <QAbstractListModel>
#include <QFile>
#include <QtQml/qqmlregistration.h>
#include "DataManager.h"
#include "Struct.h"


class PersonRule : public QAbstractTableModel
{
    Q_OBJECT
    QML_ELEMENT


public:
    explicit PersonRule(QObject *parent = nullptr);



    int rowCount(const QModelIndex &parent=QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE void init(DataManager* dataManager=nullptr);
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    Q_INVOKABLE void deleteRow(int index);
    Q_INVOKABLE bool importFromExcel(const QString &filePath);
    Q_INVOKABLE QVariantMap getRow(int row) const;
    Q_INVOKABLE bool applyRow(bool isedit,int row,const QVariantMap &form);

private:

    QVector<QString> m_dataheader;
    QVector<PersonRuleRow> m_data;
    DataManager* m_dataManager = nullptr;

signals:
    void personChanged();


};

#endif // PERSONRULEMODEL_H
