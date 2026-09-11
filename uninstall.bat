@echo off
setlocal
title 卸载 MPV 协议关联

echo 正在注销协议...

reg delete "HKCU\Software\Classes\mpv" /f >nul 2>nul
reg delete "HKCU\Software\Classes\mpvplay" /f >nul 2>nul
reg delete "HKCU\Software\Classes\mpv-handler" /f >nul 2>nul
reg delete "HKCU\Software\Classes\mpv-handler-debug" /f >nul 2>nul

reg delete "HKCR\mpv" /f >nul 2>nul
reg delete "HKCR\mpvplay" /f >nul 2>nul
reg delete "HKCR\mpv-handler" /f >nul 2>nul
reg delete "HKCR\mpv-handler-debug" /f >nul 2>nul

echo.
echo ================================================================
echo  [卸载成功]
echo  已从系统注册表中注销全部 MPV 协议！
echo ================================================================
echo.
pause