#include "WindowUtil.h"
#include <QObject>

#ifdef Q_OS_WIN
#include <windows.h>
#endif
inline ULONGLONG fileTimeToInt(const FILETIME &ft) {
    return ((ULONGLONG)ft.dwHighDateTime << 32) | ft.dwLowDateTime;
}
void WindowUtil::changewindowstate(QWindow* window, const QString& action)
{
    #ifdef Q_OS_WIN
        if (!window) return;
        HWND hwnd = reinterpret_cast<HWND>(window->winId());

        if (action == "minimize") {
            ShowWindow(hwnd, SW_MINIMIZE);
        }
        else if (action == "maximize") {
            ShowWindow(hwnd, SW_MAXIMIZE);
        }
        else {
            ShowWindow(hwnd, SW_SHOWNORMAL);
        }
    #elif defined(Q_OS_MAC)
        return;
    #endif
}
QString WindowUtil::getcpuUsage(){
    FILETIME idleTime, kernelTime, userTime;
    if (!GetSystemTimes(&idleTime, &kernelTime, &userTime)) {
        return QString("-1%");
    }

    ULONGLONG idle = fileTimeToInt(idleTime);
    ULONGLONG kernel = fileTimeToInt(kernelTime);
    ULONGLONG user = fileTimeToInt(userTime);

    ULONGLONG prevIdle = fileTimeToInt(m_prevIdle);
    ULONGLONG prevKernel = fileTimeToInt(m_prevKernel);
    ULONGLONG prevUser = fileTimeToInt(m_prevUser);

    ULONGLONG idleDiff = idle - prevIdle;
    ULONGLONG kernelDiff = kernel - prevKernel;
    ULONGLONG userDiff = user - prevUser;

    ULONGLONG total = kernelDiff + userDiff;
    double cpuUsage = (total - idleDiff) * 100.0 / total;

    m_prevIdle = idleTime;
    m_prevKernel = kernelTime;
    m_prevUser = userTime;

    double v =  std::round(cpuUsage * 10.0) / 10.0;
    return QString::number(v,'f',2)+"%";

}
QString WindowUtil::getMemoryUsage(){
    MEMORYSTATUSEX statex;
    statex.dwLength = sizeof(statex);
    GlobalMemoryStatusEx(&statex);
    DWORDLONG totalPhys = statex.ullTotalPhys / (1024 * 1024);
    DWORDLONG usedPhys = (statex.ullTotalPhys - statex.ullAvailPhys) / (1024 * 1024);
    return QString("%1 / %2 MB").arg(usedPhys).arg(totalPhys);
}
void WindowUtil::enableMica(QQuickWindow *window,int e) {

    HWND hwnd = (HWND)window->winId();
    bool win10 = isWindows10();
    if(win10){

       bool isenble =  enableBlur(hwnd);
       qDebug() << isenble;
    }
    else{
    // 启用 Mica
    const DWORD DWMWA_SYSTEMBACKDROP_TYPE = 38;
    const DWORD DWMWCP_MICA = e;
    BOOL useDarkMode = TRUE;
    const DWORD DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &DWMWCP_MICA, sizeof(DWMWCP_MICA));

    // 设置沉浸式暗模式
    bool a = isSystemDarkMode();
    if(a)
    {
       DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &useDarkMode, sizeof(useDarkMode));
    }
    }
}
bool WindowUtil::isSystemDarkMode()
{
    DWORD value = 1; // 默认浅色
    DWORD size = sizeof(DWORD);
    HKEY hKey = nullptr;
    if (RegOpenKeyExW(HKEY_CURRENT_USER,
                      L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
                      0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        if (RegQueryValueExW(hKey, L"AppsUseLightTheme", nullptr, nullptr, (LPBYTE)&value, &size) != ERROR_SUCCESS) {
            value = 1; // 读取失败，默认浅色
        }
        RegCloseKey(hKey);
    }
    return (value == 0); // 0=暗模式，1=浅色模式
}
bool WindowUtil::isWindows10()
{
    auto os = QOperatingSystemVersion::current();
    if(os.microVersion()<22000)

    {
        return true;
    }
    else{
        return false;
    }
}
bool WindowUtil::enableBlur(HWND hwnd)
{
    if (!hwnd) return false;

    DWM_BLURBEHIND bb = {};
    bb.dwFlags = DWM_BB_ENABLE;
    bb.fEnable = TRUE;
    bb.hRgnBlur = nullptr; // 全窗口模糊

    HRESULT hr = DwmEnableBlurBehindWindow(hwnd, &bb);
    return SUCCEEDED(hr);
}
void WindowUtil::enbleshadow(QWindow* window){
    HWND hwnd = (HWND)window->winId();
    enableWindowShadow windows{hwnd};
    windows.enableShadow(window);

}




