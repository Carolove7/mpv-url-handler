# mpv-url-handler (Rust Edition)

> 🚀 极速、零黑框、全兼容的 Windows MPV 协议唤起助手，现已完全基于 **Rust** 重构！

[![Build and Release](https://github.com/Carolove7/mpv-url-handler/actions/workflows/build.yml/badge.svg)](https://github.com/Carolove7/mpv-url-handler/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows-0078D6.svg?logo=windows)]()
[![Rust](https://img.shields.io/badge/Language-Rust-orange.svg?logo=rust)]()

一个轻量、极致性能的 Windows 自定义 URL 协议处理器。支持通过浏览器网页或油猴脚本（Tampermonkey）直接一键唤起本地 MPV 播放器。

---

## ✨ 核心特性

- **🦀 纯 Rust 重构**：
  - 零外部运行时依赖（Zero External Runtime Dependencies）。
  - 通过 `#![windows_subsystem = "windows"]` 声明，从系统底层彻底消除命令行 CMD 黑色弹窗。
  - 极致微秒级启动：程序初始化并派发播放进程仅需不到 **1ms**。
- **🚀 播放窗口秒级弹出**：内置 `--force-window=immediate`，消除等待网络流探测时的界面盲等迟钝感。
- **💨 直链免卡顿优化**：自动识别常见媒体直链（`.mp4`、`.m3u8`、`.flv`、`.ts`、`.mkv` 等），自动追加 `--ytdl=no`，跳过 `yt-dlp` 的 Python 冷启动探测（节省 1.5 ~ 3 秒）。
- **🧩 协议规范深度全兼容**：
  - 支持 `mpv://`
  - 支持 `mpvplay://`
  - 支持 `mpv-handler://`
  - 支持 `mpv-handler-debug://`
  - 内置高性能 **Base64** 与 **URL-Safe Base64** 自动解码器（完美兼容官方 `mpv-handler://play/[BASE64_URL]` 规范）。
  - 自动解析并向 MPV 透传扩展参数：`referrer`、`v_title`、`subfile`、`startat`、`cookies`、`profile` 等。
- **☁️ GitHub Actions 云端自动编译**：通过 GitHub CI 自动化构建，随时下载最新 Windows x86_64 预编译安装包。
- **🛡️ 绿色免提权**：写入当前用户注册表空间（`HKCU`），无需管理员权限即可一键安装与卸载。

---

## 📁 目录结构

```text
handler/
├── src/
│   └── main.rs         # 核心 Rust 源码 (纯标准库、高性能 Base64/URL 解码与进程调度)
├── Cargo.toml          # Cargo 项目配置
├── .github/workflows/
│   └── build.yml       # GitHub Actions 自动化编译工作流
├── install.bat         # 一键安装注册脚本
├── uninstall.bat       # 一键卸载注销脚本
├── test.bat            # 协议唤起快速测试脚本
└── README.md           # 项目文档
```

---

## 🚀 快速上手

### 1. 获取预编译二进制
通过 GitHub 仓库的 [Actions 页面](https://github.com/Carolove7/mpv-url-handler/actions) 或 Releases 下载最新生成的 `mpv-url-handler-windows-x86_64.zip`，解压到 MPV 的 `handler` 子目录下。

### 2. 部署目录层级
```text
mpv-folder/
├── mpv.exe
└── handler/
    ├── mpv-handler.exe
    ├── install.bat
    └── ...
```
*启动器会自动优先检测上级目录 `..\mpv.exe`，其次检测同级目录 `mpv.exe`。*

### 3. 一键安装
双击运行 **`install.bat`** 即可自动完成全部协议的注册关联。

### 4. 测试与验证
- **本地测试**：双击 **`test.bat`** 即可验证是否能成功静默拉起 MPV。
- **浏览器测试**：在浏览器中访问任意 `mpv://` 或 `mpv-handler://` 链接。

### 5. 卸载
双击运行 **`uninstall.bat`** 即可完全从注册表中清理所有相关项。

---

## 🛠️ 本地编译（开发者）

如果你本地安装了 Rust 工具链，可在根目录下直接执行：

```bash
cargo build --release
```

编译产物位于 `target/release/mpv-handler.exe`。

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。