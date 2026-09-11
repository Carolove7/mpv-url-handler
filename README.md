# mpv-url-handler

> 🚀 极速、零黑框、全兼容的 Windows MPV 协议唤起助手

[![Build and Release](https://github.com/Carolove7/mpv-url-handler/actions/workflows/build.yml/badge.svg)](https://github.com/Carolove7/mpv-url-handler/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6.svg?logo=windows)]()
[![Rust](https://img.shields.io/badge/Language-Rust-orange.svg?logo=rust)]()

基于 Rust 编写的高性能 Windows 自定义 URL 协议处理器。支持通过网页或油猴脚本（Tampermonkey）一键唤起本地 MPV 播放器。

---

## ✨ 核心特性

- **⚡ 极致性能**：基于纯 Rust 编写，零外部运行时依赖，微秒级极速响应（启动开销 `< 1ms`）。
- **🪟 彻底无黑框**：纯 Win32 GUI 子系统进程，无任何 CMD 控制台黑色弹窗。
- **🚀 窗口秒弹**：内置 `--force-window=immediate`，消除等待网络流探测时的界面盲等。
- **💨 直链优化**：常见媒体直链（`.mp4`、`.m3u8`、`.flv` 等）自动跳过 `yt-dlp` 冷启动探测（节省 1.5 ~ 3 秒）。
- **🧩 全协议兼容**：
  - 支持 `mpv://`、`mpvplay://`、`mpv-handler://`、`mpv-handler-debug://`
  - 原生支持 **Base64** 与 **URL-Safe Base64** 自动解码（兼容 `mpv-handler://play/[BASE64_URL]`）
  - 自动解析并透传参数：`referrer`、`v_title`、`subfile`、`startat`、`cookies`、`profile`
- **🛡️ 绿色安全**：写入当前用户注册表空间（`HKCU`），无需管理员权限即可一键安装与卸载。

---

## 📁 目录结构

```text
handler/
├── mpv-handler.exe    # 原生可执行程序（开箱即用）
├── install.bat        # 一键安装注册脚本
├── uninstall.bat      # 一键卸载注销脚本
├── test.bat           # 快速测试脚本
├── src/main.rs        # Rust 源码
├── Cargo.toml         # Cargo 配置
└── README.md          # 项目文档
```

---

## 🚀 使用方法

### 1. 放置位置
建议将本文件夹置于 MPV 目录下（作为 `handler` 子目录）：
```text
mpv-folder/
├── mpv.exe
└── handler/
    ├── mpv-handler.exe
    ├── install.bat
    └── ...
```
*启动器会自动优先检测上级目录的 `..\mpv.exe`，其次检测同级目录。*

### 2. 安装与使用
- **一键安装**：双击运行 `install.bat` 即可完成全部协议的注册关联。
- **测试验证**：双击运行 `test.bat` 或在浏览器中点击任意 `mpv://` / `mpv-handler://` 链接。
- **一键卸载**：双击运行 `uninstall.bat` 即可完全注销所有关联。

---

## 🛠️ 构建

如果你需要自行编译源码：

```bash
cargo build --release
```

编译产物位于 `target/release/mpv-handler.exe`，也可以直接从 [Actions 页面](https://github.com/Carolove7/mpv-url-handler/actions) 下载预编译安装包。

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。