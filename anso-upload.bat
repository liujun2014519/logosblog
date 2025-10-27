@echo off
:: 设置本地路径和远程路径
set LOCAL_PATH=D:\obsidian\blog\public\
set REMOTE_USER=root
set REMOTE_HOST=47.107.104.169
set REMOTE_PATH=/home/user/stellar/public/

:: 设置临时脚本路径
set SCRIPT_FILE=%TEMP%\winscp_script.txt

:: 生成 WinSCP 脚本文件内容
echo open sftp://%REMOTE_USER%@%REMOTE_HOST%/ > %SCRIPT_FILE%
echo option transfer binary >> %SCRIPT_FILE%
echo put "%LOCAL_PATH%"* "%REMOTE_PATH%" >> %SCRIPT_FILE%
echo exit >> %SCRIPT_FILE%

:: 执行 WinSCP 脚本
winscp.com /script=%SCRIPT_FILE%

:: 删除临时脚本文件
del %SCRIPT_FILE%

echo Upload completed.
pause