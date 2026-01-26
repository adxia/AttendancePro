#include "ApiClient.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QElapsedTimer>
#include <QTimer>
#include "MessageCenter.h"


ApiClient::ApiClient(QObject *parent) : QObject(parent) {
    // nothing special
}

ApiClient::~ApiClient() {
    // cleanup if needed
}

void ApiClient::test(const QString& apipath,int timeout){
    QUrl url(apipath + "/test");
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=utf-8");
    req.setTransferTimeout(timeout);

    QNetworkAccessManager* mgr = new QNetworkAccessManager;
    QNetworkReply* reply = mgr->get(req);

    auto cleanup = [reply, mgr]() {
        reply->deleteLater();
        mgr->deleteLater();
    };

    QObject::connect(reply, &QNetworkReply::finished, reply, [reply, cleanup]() {
        if (reply->error() == QNetworkReply::NoError) {
            emit MessageCenter::instance()->successmessage("连接成功", "测试连接成功");
        } else {
            QString errorMsg = (reply->error() == QNetworkReply::TimeoutError) ? "请求超时" : reply->errorString();
            emit MessageCenter::instance()->erromessage("连接失败", errorMsg);
        }
        cleanup();
    });

}

void ApiClient::getHoliday(const QString& apipath,int timeout,std::function<void(QByteArray)> callback){

    QUrl url(apipath + "/attendance/holiday.json");
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json;charset=utf-8");
    req.setTransferTimeout(timeout);

    QNetworkAccessManager* mgr = new QNetworkAccessManager;
    QNetworkReply* reply = mgr->get(req);


    // 统一资源清理函数
    auto cleanup = [reply, mgr]() {
        reply->deleteLater();
        mgr->deleteLater();
    };

    QObject::connect(reply, &QNetworkReply::finished, reply, [reply, callback, cleanup]() {
        if (reply->error() == QNetworkReply::NoError) {
            callback(reply->readAll());
        } else {
            QString errorMsg = (reply->error() == QNetworkReply::TimeoutError) ? "请求超时" : reply->errorString();
            emit MessageCenter::instance()->erromessage("获取节假日失败", errorMsg);
           // callback(QByteArray());
        }
        cleanup();
    });
}
