@echo off
setlocal
title 测试唤起协议

echo 正在测试唤起 mpv-handler:// ...
echo.

start "" "mpv-handler://play/aHR0cHM6Ly9jb21tb25kYXRhc3RvcmFnZS5nb29nbGVhcGlzLmNvbS9ndHYtdmlkZW9zLWJ1Y2tldC9zYW1wbGUvQmlnQnVja0J1bm55Lm1wNA"

echo 已发送唤起命令。如果 MPV 成功播放且无黑框，则代表配置成功！
echo.
pause