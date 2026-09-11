@echo off
chcp 65001 >nul
title 卸载 MPV 协议关联

echo 正在注销协议...

set PROTO_LIST=mpv mpvplay mpv-handler mpv-handler-debug

for %%P in (%PROTO_LIST%) do (
    reg delete "HKCU\Software\Classes\%%P" /f >nul 2>nul
    reg delete "HKCR\%%P" /f >nul 2>nul
)

echo.
echo ================================================================
echo  [卸载成功]
echo  已从系统注册表中注销 mpv:// 、 mpvplay:// 、 mpv-handler:// 协议！
echo ================================================================
echo.
pause