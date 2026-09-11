========================================================================
       MPV 协议极速静默唤起助手 (MPV URL Protocol Handler)
========================================================================

【支持协议】
- mpv://
- mpvplay://
- mpv-handler://
- mpv-handler-debug://

【高级特性】
1. 完整兼容官方 mpv-handler 协议格式：
   - 支持 Base64 及 URL-Safe Base64 自动识别解码
   - 格式支持：mpv-handler://play/[BASE64_URL]/?params...
   - 格式支持：mpv-handler://[URL]
   - 自动解析并传递附加参数：
     --referrer=[URL]
     --force-media-title=[TITLE]
     --sub-file=[SUBTITLE]
     --start=[START_TIME]
     --cookies-file=[COOKIES]
     --profile=[PROFILE]
2. 毫秒级极速响应：Win32 GUI 原生架构（无黑框闪烁，启动开销 < 5ms）。
3. 窗口秒弹：启用 --force-window=immediate 消除点击迟滞感。
4. 直链媒体免卡顿：常见媒体格式 (.mp4, .m3u8, .flv, .ts 等) 自动绕过 yt-dlp 避免冷启动卡顿。

【文件清单】
- install.bat       : 一键注册所有协议（mpv / mpvplay / mpv-handler）
- uninstall.bat     : 一键从注册表中注销所有关联
- test.bat          : 测试唤起 mpv-handler:// 协议
- mpv-handler.exe   : 原生极速启动器
- Program.cs        : 启动器开源源代码