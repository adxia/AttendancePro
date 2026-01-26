#include "Enablewindowshadow.h"

WNDPROC enableWindowShadow::originalWndProc = nullptr;
enableWindowShadow::enableWindowShadow(HWND hwnd):hwnd(hwnd) {


}

 //启用dwm阴影
bool enableWindowShadow::enableShadow(const QWindow *window){
    HWND hwnd = reinterpret_cast<HWND>(window->winId());
    if (!hwnd) return false;

    // 检查 DWM 组合是否启用
    BOOL compositionEnabled = FALSE;
    HRESULT hr = DwmIsCompositionEnabled(&compositionEnabled);
    if (FAILED(hr) || !compositionEnabled) {
        qWarning("DWM Composition is not enabled. Shadow effects will not work.");
        return false;
    }

    // 设置窗口样式
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    SetWindowLong(hwnd, GWL_STYLE, style | WS_CAPTION | WS_MINIMIZEBOX | WS_MAXIMIZEBOX );

    // 启用 DWM 阴影
    DWMNCRENDERINGPOLICY policy = DWMNCRP_ENABLED;
    DwmSetWindowAttribute(hwnd, DWMWA_NCRENDERING_POLICY, &policy, sizeof(policy));

    // 扩展窗口框架到客户区
    MARGINS margins = {-1, -1, -1, -1};
    DwmExtendFrameIntoClientArea(hwnd, &margins);

    // 保存原始窗口过程并替换为自定义窗口过程
    originalWndProc = reinterpret_cast<WNDPROC>(GetWindowLongPtr(hwnd, GWLP_WNDPROC));
    SetWindowLongPtr(hwnd, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(CustomWndProc));
    // enableMica(hwnd);

    // 强制触发窗口更新，确保应用 DWM 样式
    SetWindowPos(hwnd, nullptr, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    // SetWindowLong(hwnd, GWL_STYLE, style | WS_VISIBLE);
    UpdateWindow(hwnd);
    return true;

};

//自定义客户区
LRESULT CALLBACK enableWindowShadow::CustomWndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam){
    switch (uMsg) {

    case WM_NCCALCSIZE:
        if (wParam) {
            NCCALCSIZE_PARAMS* params = reinterpret_cast<NCCALCSIZE_PARAMS*>(lParam);
            if (IsZoomed(hwnd)) {
                // 最大化时，Windows 会额外加 4px 边框，我们把它抹掉
                LRESULT result = DefWindowProc(hwnd, WM_NCCALCSIZE, wParam, lParam);
                NCCALCSIZE_PARAMS* params = reinterpret_cast<NCCALCSIZE_PARAMS*>(lParam);
                /*RECT calculated = params->rgrc[0];
                QMargins taskbarMargins = calculateTaskBarMargins(hwnd);
                params->rgrc[0].top += taskbarMargins.top()-50;*/
                QMargins taskbarMargins = calculateTaskBarMargins(hwnd);

                // 去掉默认的标题栏高度（这里直接覆盖 top）
                int captionHeight = GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYFRAME);
                params->rgrc[0].top -= captionHeight;

                //return 0;
            }
            return 0;
            }
        break;
    case WM_SYSCOMMAND:
        // 保留最大化、最小化和还原动画
        if ((wParam & 0xFFF0) == SC_MAXIMIZE || (wParam & 0xFFF0) == SC_MINIMIZE || (wParam & 0xFFF0) == SC_RESTORE){
            return DefWindowProc(hwnd, uMsg, wParam, lParam);
        }
        break;

    case WM_ERASEBKGND:
        return true;

    case WM_NCHITTEST: {
        // 获取鼠标位置
        POINT cursorPos = {GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam)};
        ScreenToClient(hwnd, &cursorPos);

        RECT winRect;
        GetClientRect(hwnd, &winRect);

        const int borderWidth = 4; // 调整边框宽度
        if (cursorPos.x < borderWidth && cursorPos.y < borderWidth)
            return HTTOPLEFT;
        if (cursorPos.x > winRect.right - borderWidth && cursorPos.y < borderWidth)
            return HTTOPRIGHT;
        if (cursorPos.x < borderWidth && cursorPos.y > winRect.bottom - borderWidth)
            return HTBOTTOMLEFT;
        if (cursorPos.x > winRect.right - borderWidth && cursorPos.y > winRect.bottom - borderWidth)
            return HTBOTTOMRIGHT;
        if (cursorPos.x < borderWidth)
            return HTLEFT;
        if (cursorPos.x > winRect.right - borderWidth)
            return HTRIGHT;
        if (cursorPos.y < borderWidth)
            return HTTOP;
        if (cursorPos.y > winRect.bottom - borderWidth)
            return HTBOTTOM;

        // 如果鼠标位于客户区顶部中央区域（模拟标题栏），支持拖动
        // const int dragHeight = 80; // 可拖动区域高度
        // if (cursorPos.y < dragHeight && cursorPos.x > 10 && cursorPos.x<winRect.right) {
        //     return HTCAPTION;
        // }
        return HTCLIENT;
    }

    default:
        break;
    }
    // 调用原始窗口过程处理未处理的消息
    if (originalWndProc) {
        return CallWindowProc(originalWndProc, hwnd, uMsg, wParam, lParam);
    } else {
        return DefWindowProc(hwnd, uMsg, wParam, lParam);
    }

};
QMargins enableWindowShadow::calculateTaskBarMargins(HWND hwnd){
    APPBARDATA appBarData = {};
    appBarData.cbSize = sizeof(APPBARDATA);
    HWND taskbarHandle = FindWindow(L"Shell_TrayWnd", nullptr); // 找到任务栏窗口句柄
    if (taskbarHandle == nullptr) {
        // 找不到任务栏时，返回零边距
        return QMargins(0, 0, 0, 0);
    }

    // 获取任务栏位置
    if (SHAppBarMessage(ABM_GETTASKBARPOS, &appBarData)) {
        RECT taskBarRect = appBarData.rc;
        RECT windowRect;
        GetWindowRect(hwnd, &windowRect);

        int leftMargin = 0, topMargin = 0, rightMargin = 0, bottomMargin = 0;

        // 根据任务栏的边界位置计算边距
        switch (appBarData.uEdge) {
        case ABE_LEFT:
            leftMargin = taskBarRect.right - taskBarRect.left;
            break;
        case ABE_TOP:
            topMargin = taskBarRect.bottom - taskBarRect.top;
            break;
        case ABE_RIGHT:
            rightMargin = taskBarRect.right - taskBarRect.left;
            break;
        case ABE_BOTTOM:
            bottomMargin = taskBarRect.bottom - taskBarRect.top;
            break;
        }

        return QMargins(leftMargin, topMargin, rightMargin, bottomMargin);
    }

    // 如果无法获取任务WM_NCCALCSIZE栏信息，返回零边距
    return QMargins(0, 0, 0, 0);
}
void enableWindowShadow::enableMica(HWND hwnd) {
    // 启用 Mica
    const DWORD DWMWA_SYSTEMBACKDROP_TYPE = 38;
    const DWORD DWMWCP_MICA = 2;
    BOOL useDarkMode = TRUE;
    const DWORD DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &DWMWCP_MICA, sizeof(DWMWCP_MICA));
    // 设置沉浸式暗模式
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &useDarkMode, sizeof(useDarkMode));
}

