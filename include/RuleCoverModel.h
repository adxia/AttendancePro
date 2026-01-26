#ifndef RULECOVERMODEL_H
#define RULECOVERMODEL_H

#include <QAbstractListModel>
#include <QtQml/qqmlregistration.h>
#include <QJsonObject>
#include <QDebug>
#include <QJsonArray>


class RuleCoverModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit RuleCoverModel(QObject *parent = nullptr);

    // QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // Public method to update the model data
    void updateData(const QJsonObject &jsonObject);
    void removeData(int &index);
    void insertData(const QJsonObject &item, int row = -1);
    void searh(const QString &keyword,QJsonObject jsonObject);

private:
    // A QJsonArray to hold the list data
    QJsonArray m_data;

    enum RuleCoverRoles {
        NameRole = Qt::UserRole + 1,
        UUIDRole,
        DescriptionRole,
        IconRole,
    };
};

#endif // RULECOVERMODEL_H
