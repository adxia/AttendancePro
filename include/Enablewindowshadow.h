#ifndef ENABLEWINDOWSHADOW_H
#define ENABLEWINDOWSHADOW_H
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuick/QQuickWindow>
#include <dwmapi.h>
#include <QMargins>
#include <windows.h>
#define GET_X_LPARAM(lp) ((int)(short)LOWORD(lp))
#define GET_Y_LPARAM(lp) ((int)(short)HIWORD(lp))
#pragma comment(lib, "dwmapi.lib")

class enableWindowShadow
{
private:
    // 全局变量，用于保存原始窗口过程
    static WNDPROC originalWndProc;
    HWND hwnd;
public:
    enableWindowShadow(HWND hwnd);
    //启用dwm阴影
    bool enableShadow(const QWindow *window);
    //自定义客户区
    static LRESULT CALLBACK CustomWndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

    static QMargins calculateTaskBarMargins(HWND hwnd);

    void enableMica(HWND hwnd);
};


#endif // ENABLEWINDOWSHADOW_H
