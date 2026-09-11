# mpv-url-handler

> 🚀 Windows 下极速、零黑框、全兼容的 MPV 协议唤起助手 (URL Protocol Handler)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6.svg?logo=windows)]()

一个轻量、极致性能的 Windows 自定义协议处理器。支持通过网页或油猴脚本（Tampermonkey）直接一键唤起本地 MPV 播放器。

---

## ✨ 核心特性

- **⚡ 毫秒级原生极速响应**：基于纯 Win32 GUI 原生 C# 编译，由 Windows 内核直连调用，执行开销 `< 5ms`。
- **🪟 彻底无黑框闪烁**：纯 GUI 子系统进程，没有任何 CMD 控制台黑色窗口弹窗。
- **🚀 播放窗口秒级弹出**：内置 `--force-window=immediate`，消除等待网络流探测时的界面盲等迟钝感。
- **💨 直链免卡顿优化**：自动识别常见媒体直链（`.mp4`、`.m3u8`、`.flv`、`.ts` 等），自动追加 `--ytdl=no`，跳过 `yt-dlp` 的 Python 冷启动探测（节省 1.5 ~ 3 秒）。
- **🧩 全协议与 Base64 深度兼容**：
  - 支持 `mpv://`
  - 支持 `mpvplay://`
  - 支持 `mpv-handler://`
  - 支持 `mpv-handler-debug://`
  - 原生支持 **Base64** 与 **URL-Safe Base64** 自动解码（兼容 `mpv-handler://play/[BASE64_URL]` 规范）。
  - 自动解析并向 MPV 透传扩展参数：`referrer`、`v_title`、`subfile`、`startat`、`cookies`、`profile` 等。
- **🛡️ 绿色无需提权**：注册表写入当前用户空间（`HKCU`），无需管理员权限即可一键安装与卸载。

---

## 📁 目录结构

```text
handler/
├── mpv-handler.exe    # 编译完成的原生极速启动器（推荐）
├── Program.cs         # 启动器 C# 源代码
├── install.bat        # 一键安装注册脚本
├── uninstall.bat      # 一键卸载注销脚本
├── test.bat           # 协议唤起快速测试脚本
├── mpv-handler.vbs    # 纯 VBScript 备用启动器
└── README.md          # 项目文档
```

---

## 🚀 快速上手

### 1. 部署位置
建议将本仓库文件夹置于 MPV 播放器根目录下作为 `handler` 子目录，例如：
```text
mpv-folder/
├── mpv.exe
└── handler/
    ├── mpv-handler.exe
    ├── install.bat
    └── ...
```
*注：启动器会自动优先检测上级目录 `..\mpv.exe`，其次检测同级目录 `mpv.exe`。*

### 2. 一键安装
双击运行 **`install.bat`** 即可自动完成全部协议的注册关联。

### 3. 测试与使用
- **本地测试**：双击 **`test.bat`** 即可验证是否能成功静默拉起 MPV。
- **浏览器测试**：在浏览器地址栏或网页链接中点击：
  ```text
  mpv-handler://play/aHR0cHM6Ly9jb21tb25kYXRhc3RvcmFnZS5nb29nbGVhcGlzLmNvbS9ndHYtdmlkZW9zLWJ1Y2tldC9zYW1wbGUvQmlnQnVja0J1bm55Lm1wNA
  ```
  或者直链：
  ```text
  mpv://https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
  ```

### 4. 卸载
如需注销协议关联，双击运行 **`uninstall.bat`** 即可完全从注册表中清理所有相关项。

---

## 🛠️ 自行编译源码

如果你需要修改逻辑并自行编译，可直接使用 Windows 自带的 .NET C# 编译器（无需安装大型 IDE）：

```cmd
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /optimize+ /r:System.Windows.Forms.dll /out:mpv-handler.exe Program.cs
```

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。