#ifndef WINDOWUTIL_H
#define WINDOWUTIL_H

#include <QtQml/qqmlregistration.h>
#include <QObject>
#include <QWindow>
#include <QtQuick/QQuickWindow>
#include <windows.h>
#include <QDebug>
#include <dwmapi.h>
#include <QOperatingSystemVersion>
#include "Enablewindowshadow.h"
#pragma comment(lib, "dwmapi.lib")

class WindowUtil : public QObject {
    Q_OBJECT
    QML_ELEMENT

private:
    FILETIME m_prevIdle, m_prevKernel, m_prevUser;
public:
    Q_INVOKABLE void changewindowstate(QWindow* window, const QString& action);
    Q_INVOKABLE QString getMemoryUsage();
    Q_INVOKABLE QString getcpuUsage();
    Q_INVOKABLE void enableMica(QQuickWindow *,int);
    Q_INVOKABLE bool isSystemDarkMode();
    Q_INVOKABLE void enbleshadow(QWindow* window);
    bool isWindows10();
    bool enableBlur(HWND hwnd);
};
#endif
