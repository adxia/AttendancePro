#pragma once
#ifndef MESSAGECENTER_H
#define MESSAGECENTER_H
#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include <QCoreApplication>

class MessageCenter:public QObject
{
    Q_OBJECT
signals:
    void warningmessage(QString const &title,QString const &msg,bool stauts = true);
    void erromessage(QString const &title,QString const &msg,bool stauts = true);
    void successmessage(QString const &title,QString const &msg,bool stauts = true);
    void tabelchangemessage(const QString &msg);
    void search(const QString &msg);
    void datanull(const QString &msg);

public slots:

public:

    static MessageCenter* instance();
    explicit MessageCenter(QObject* parent = nullptr);
private:

    static MessageCenter* m_instance;

};
#endif // MESSAGECENTER_H
