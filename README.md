# AttendancePro

## 🚀 UI展示
<details>
<summary>📸 界面预览</summary>
![AttendancePro Main UI](screenshots/image.png)
![AttendancePro Rule UI](screenshots/image-1.png)
![AttendancePro Setting UI](screenshots/image-2.png)
</details>

AttendancePro 是一款基于 **Qt 6.9 + C++** 开发的高性能桌面端考勤数据处理工具。  
它专注于解析异构 Excel 考勤报表，通过内置引擎进行自动化分析，并精准写入预设的模板表中。

> **重要说明**  
> 本项目目前深度集成 **LibXL 商业库** 以实现高性能 Excel 读写。  
> 编译前需确保本地已正确配置相关授权文件。

---

## 🚀 核心特性

- **极致性能**  
  原生 C++ 计算内核，800ms 内完成万级考勤记录的解析与统计。

- **规则解耦**  
  考勤逻辑与数据格式分离，支持灵活配置异构报表模板。

- **现代化 UI**  
  基于 QML 构建，完美支持 Windows 高分屏（DPI）自适应。

- **原生体验**  
  自定义标题栏，支持 Windows 原生阴影效果。

---

## 🛠️ 技术栈

- **语言**：C++20  
- **框架**：Qt 6.9（Qt Quick / QML / SQL）  
- **构建系统**：CMake ≥ 3.16  
- **开发环境**：Windows（MSVC 2022）

---

## 📦 环境配置（LibXL）

由于 **LibXL 为商业库**，本仓库 **不包含其二进制文件**。  
编译前需完成以下配置：

### 1️⃣ 获取库文件

- 将 `libxl.lib` 放置于项目根目录下的 `libs/` 目录

### 2️⃣ 授权配置

- 打开文件：ExcelIO
- 在 `resetBook` 方法中填入您申请到的 **LibXL 授权 name 和 key**

### 3️⃣ 运行时依赖

- 编译完成后，请将 `libxl.dll` 放置在生成的 `.exe` 同级目录下

---

## 🏗️ 构建与运行

### 推荐方式：Qt Creator

1. 使用 Qt Creator 打开 `CMakeLists.txt`
2. 配置 Kit 为 **Qt 6.9.x MSVC2022 64-bit**
3. 等待 CMake 配置完成
4. 点击 **Build**（快捷键 `Ctrl + B`）进行构建

