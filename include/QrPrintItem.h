#pragma once
#include <QQuickPaintedItem>
#include <QPainter>
#include "QrCodeGenerator.h"
#include <QDateTime>

class QrPrintItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap text READ text WRITE setText NOTIFY textChanged)

public:
    explicit QrPrintItem(QQuickItem* parent = nullptr)
        : QQuickPaintedItem(parent)
    {
        setFlag(ItemHasContents, true);
    }

    QVariantMap text() const { return rowData;}

    void setText(const QVariantMap& t) {
        if (rowData != t) {
            rowData = t;
            update(); // 触发重绘
            emit textChanged();
        }
    }
    void paint(QPainter* painter)
    {
        if (!painter) return;
        if (rowData.isEmpty()) return;

        painter->setRenderHint(QPainter::Antialiasing, true);
        painter->setRenderHint(QPainter::TextAntialiasing, true);

        // 设计稿尺寸
        const qreal DESIGN_WIDTH = 2480;
        const qreal DESIGN_HEIGHT = 3508;

        // 打印机页面尺寸（pt 单位）
        QRectF pageRect = painter->viewport(); // 或 QPrinter::pageRect(QPrinter::Point)
        qreal pageWidth  = pageRect.width();
        qreal pageHeight = pageRect.height();

        // 缩放比例
        qreal scaleX = pageWidth / DESIGN_WIDTH;
        qreal scaleY = pageHeight / DESIGN_HEIGHT;

        // 背景
        painter->fillRect(pageRect, Qt::white);

        // 缩放整个画布
        painter->save();
        painter->scale(scaleX, scaleY);

        QFont font;
        QPen pen;

        // ---------- 表头 ----------
        font.setWeight(QFont::Normal);
        font.setPointSizeF(7);
        painter->setFont(font);
        painter->setPen(QColor(60, 60, 60));

        // "血型卡抽检单"
        painter->drawText(QRectF(140, 130, DESIGN_WIDTH/2 - 60, 100),
                          Qt::AlignLeft | Qt::AlignTop,
                          "血型卡抽检单");

        // "运单号"
        painter->drawText(QRectF(DESIGN_WIDTH/2 + 10, 130, DESIGN_WIDTH/2 - 140, 100),
                          Qt::AlignRight | Qt::AlignTop,
                          "运单号：" + rowData["awb"].toString());

        // 虚线
        pen.setColor(QColor(120, 120, 120));
        pen.setWidthF(4);
        pen.setStyle(Qt::DashLine);
        painter->setPen(pen);
        painter->drawLine(QPointF(130, 230), QPointF(DESIGN_WIDTH - 130, 230));

        // ---------- 字段头----------
        font.setPointSizeF(9);
        painter->setFont(font);
        painter->setPen(QColor(100, 100, 100));
        painter->drawText(QRectF(340, 500, 400, 200), Qt::AlignLeft | Qt::AlignTop, "CID");
        painter->drawText(QRectF(340, 850, 400, 200), Qt::AlignLeft | Qt::AlignTop, "SKU");
        painter->drawText(QRectF(340, 1200, 400, 200), Qt::AlignLeft | Qt::AlignTop, "批号");
        painter->drawText(QRectF(DESIGN_WIDTH - 700, 500, 400, 200), Qt::AlignLeft | Qt::AlignTop, "托盘数量");
        painter->drawText(QRectF(DESIGN_WIDTH - 700, 850, 600, 200), Qt::AlignLeft | Qt::AlignTop, "抽检数量");
        painter->drawText(QRectF(DESIGN_WIDTH - 700, 1200, 600, 200), Qt::AlignLeft | Qt::AlignTop, "抽检位置");

        // ---------- 字段值 ----------
        painter->setPen(QColor(30, 30, 30));
        painter->drawText(QRectF(340, 650, 1500, 200), Qt::AlignLeft | Qt::AlignTop, rowData["cid"].toString());
        painter->drawText(QRectF(340, 1000, 1200, 200), Qt::AlignLeft | Qt::AlignTop, rowData["sku"].toString());
        painter->drawText(QRectF(340, 1350, 1200, 200), Qt::AlignLeft | Qt::AlignTop, rowData["batch"].toString());
        painter->drawText(QRectF(DESIGN_WIDTH - 700, 650, 1000, 200), Qt::AlignLeft | Qt::AlignTop, rowData["quantity"].toString());
        painter->drawText(QRectF(DESIGN_WIDTH - 700, 1000, 500, 200), Qt::AlignLeft | Qt::AlignTop, rowData["sample_num"].toString());
        painter->drawText(QRectF(DESIGN_WIDTH - 700, 1350, 1000, 200), Qt::AlignLeft | Qt::AlignTop, "1-3层中");


        // ---------- 二维码 ----------
        QrCodeGenerator generator;
        QString qrtext = rowData["cid"].toString() + "|" + rowData["sku"].toString() + "|" +
                         rowData["batch"].toString() + "|" + rowData["pallet"].toString();
        QImage qrImage = generator.generateQr(qrtext);
        int qrSize = DESIGN_WIDTH * 0.28;
        qrImage = qrImage.scaled(qrSize, qrSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        QPointF qrPos((DESIGN_WIDTH - qrImage.width())/2, DESIGN_HEIGHT/2 + 100);
        painter->drawImage(qrPos, qrImage);

        //托盘号
        font.setPointSizeF(11);
        painter->setFont(font);
        painter->setPen(QColor(30, 30, 30));
        painter->drawText(QRectF((DESIGN_WIDTH - qrImage.width())/2, DESIGN_HEIGHT/2 + 60 + qrImage.height(), qrImage.width(), 200), Qt::AlignHCenter | Qt::AlignVCenter, "托盘号："+rowData["pallet"].toString());

        // 虚线
        pen.setColor(QColor(120, 120, 120));
        pen.setWidthF(4);
        pen.setStyle(Qt::DashLine);
        painter->setPen(pen);
        painter->drawLine(QPointF(130, DESIGN_HEIGHT - 230), QPointF(DESIGN_WIDTH - 130, DESIGN_HEIGHT - 230));

        // ---------- 底部说明 ----------
        font.setPointSizeF(6);
        painter->setFont(font);
        painter->setPen(QColor(120, 120, 120));
        QDateTime now = QDateTime::currentDateTime();
        QString dateTimeStr = rowData["creatdate"].toString();

        painter->drawText(QRectF(140, DESIGN_HEIGHT - 210, DESIGN_WIDTH, 120),
                          Qt::AlignLeft | Qt::AlignTop,
                          "本单据由系统自动生成，仅用于内部管理使用");

        painter->drawText(QRectF(DESIGN_WIDTH/2, DESIGN_HEIGHT - 210, DESIGN_WIDTH/2 - 140, 120),
                          Qt::AlignRight | Qt::AlignTop,
                          "生成时间：" + dateTimeStr);

        painter->restore();
    }

signals:
    void textChanged();

private:
    QVariantMap rowData ;
};
