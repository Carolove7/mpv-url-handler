@echo off
setlocal
title 安装 MPV 极速协议关联

set "HANDLER_DIR=%~dp0"
if "%HANDLER_DIR:~-1%"=="\" set "HANDLER_DIR=%HANDLER_DIR:~0,-1%"

set "HANDLER_EXE=%HANDLER_DIR%\mpv-handler.exe"
set "MPV_EXE=%HANDLER_DIR%\..\mpv.exe"

if not exist "%HANDLER_EXE%" (
    echo [错误] 未找到 mpv-handler.exe！
    pause
    exit /b 1
)

echo 正在注册协议到当前用户系统...

reg add "HKCU\Software\Classes\mpv" /ve /d "URL:mpv Protocol" /f >nul
reg add "HKCU\Software\Classes\mpv" /v "URL Protocol" /d "" /f >nul
reg add "HKCU\Software\Classes\mpv\DefaultIcon" /ve /d "\"%MPV_EXE%\",0" /f >nul
reg add "HKCU\Software\Classes\mpv\shell\open\command" /ve /d "\"%HANDLER_EXE%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\mpvplay" /ve /d "URL:mpvplay Protocol" /f >nul
reg add "HKCU\Software\Classes\mpvplay" /v "URL Protocol" /d "" /f >nul
reg add "HKCU\Software\Classes\mpvplay\DefaultIcon" /ve /d "\"%MPV_EXE%\",0" /f >nul
reg add "HKCU\Software\Classes\mpvplay\shell\open\command" /ve /d "\"%HANDLER_EXE%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\mpv-handler" /ve /d "URL:mpv-handler Protocol" /f >nul
reg add "HKCU\Software\Classes\mpv-handler" /v "URL Protocol" /d "" /f >nul
reg add "HKCU\Software\Classes\mpv-handler\DefaultIcon" /ve /d "\"%MPV_EXE%\",0" /f >nul
reg add "HKCU\Software\Classes\mpv-handler\shell\open\command" /ve /d "\"%HANDLER_EXE%\" \"%%1\"" /f >nul

reg add "HKCU\Software\Classes\mpv-handler-debug" /ve /d "URL:mpv-handler-debug Protocol" /f >nul
reg add "HKCU\Software\Classes\mpv-handler-debug" /v "URL Protocol" /d "" /f >nul
reg add "HKCU\Software\Classes\mpv-handler-debug\DefaultIcon" /ve /d "\"%MPV_EXE%\",0" /f >nul
reg add "HKCU\Software\Classes\mpv-handler-debug\shell\open\command" /ve /d "\"%HANDLER_EXE%\" \"%%1\"" /f >nul

echo.
echo ================================================================
echo  [安装成功]
echo  - 已注册协议: mpv://, mpvplay://, mpv-handler://
echo  - 启动程序:   %HANDLER_EXE%
echo  - 唤起引擎:   Rust 原生 Win32 GUI 架构【零黑框闪烁】
echo ================================================================
echo.
pause