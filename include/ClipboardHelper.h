#pragma once
#include <QObject>
#include <QClipboard>
#include <QGuiApplication>

class ClipboardHelper : public QObject
{
    Q_OBJECT
public:
    explicit ClipboardHelper(QObject *parent = nullptr) : QObject(parent) {}

    // ✅ QML 可直接调用
    Q_INVOKABLE void setText(const QString &text) {
        QClipboard *clipboard = QGuiApplication::clipboard();
        if (clipboard)
            clipboard->setText(text, QClipboard::Clipboard);
    }

    Q_INVOKABLE QString text() const {
        QClipboard *clipboard = QGuiApplication::clipboard();
        return clipboard ? clipboard->text(QClipboard::Clipboard) : QString();
    }
};
