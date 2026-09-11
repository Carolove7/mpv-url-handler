@echo off
chcp 65001 >nul
title 安装 MPV 极速协议关联

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "HANDLER_EXE=%SCRIPT_DIR%\mpv-handler.exe"
set "HANDLER_VBS=%SCRIPT_DIR%\mpv-handler.vbs"
set "MPV_EXE=%SCRIPT_DIR%\..\mpv.exe"

echo 正在检查必要文件...

if exist "%HANDLER_EXE%" (
    set "LAUNCHER=\"%HANDLER_EXE%\" \"%%1\""
    echo [模式] 启用原生极速启动器: %HANDLER_EXE%
) else if exist "%HANDLER_VBS%" (
    set "LAUNCHER=wscript.exe \"%HANDLER_VBS%\" \"%%1\""
    echo [模式] 启用脚本启动器: %HANDLER_VBS%
) else (
    echo [错误] 未找到启动器文件！
    pause
    exit /b 1
)

if exist "%MPV_EXE%" (
    echo [确认] 找到 MPV 主程序: "%MPV_EXE%"
) else (
    echo [提示] 未在上级目录检测到 mpv.exe，请确认 mpv 所在路径。
)

echo.
echo 正在注册协议到系统...

set PROTO_LIST=mpv mpvplay mpv-handler mpv-handler-debug

for %%P in (%PROTO_LIST%) do (
    reg add "HKCU\Software\Classes\%%P" /ve /d "URL:%%P Protocol" /f >nul
    reg add "HKCU\Software\Classes\%%P" /v "URL Protocol" /d "" /f >nul
    reg add "HKCU\Software\Classes\%%P\DefaultIcon" /ve /d "\"%MPV_EXE%\",0" /f >nul
    reg add "HKCU\Software\Classes\%%P\shell\open\command" /ve /d "%LAUNCHER%" /f >nul
)

echo.
echo ================================================================
echo  [安装成功 - 已支持全部协议]
echo  - 协议已注册: mpv:// 、 mpvplay:// 、 mpv-handler://
echo  - 启动引擎:   原生 Win32 GUI 架构（无黑框、毫秒级响应）
echo  - 协议兼容:   原生支持 Base64 / URL-Safe Base64 解析
echo                支持 referrer / title / subfile / start 参数
echo  - 速度优化:   启用 --force-window=immediate (窗口秒出)
echo                直链媒体自动跳过 yt-dlp 探测 (避免数秒卡顿)
echo ================================================================
echo.
pause