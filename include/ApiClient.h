#pragma once
#ifndef APICLIENT_H
#define APICLIENT_H_H
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTimer>
#include <QUrlQuery>

class ApiClient : public QObject {

public:
    explicit ApiClient(QObject *parent = nullptr);
    ~ApiClient();

    void getHoliday(const QString& apipath,int timeout,std::function<void(QByteArray)> callback);
    void test(const QString& apipath,int timeout);

private:
    // QNetworkRequest makeRequest(const QString &path);
    // void handleReply(QNetworkReply *reply);
    QNetworkAccessManager m_nam;
    QString m_baseUrl = "http://192.168.1.16";
    QString m_port = "8015";
    QString m_token;
    QByteArray m_data;
    QString m_lastError;
    QString m_agentheader = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0";
    int m_defaultTimeoutMs = 15000; // 15s
};
#endif
