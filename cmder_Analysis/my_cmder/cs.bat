:: 不显示之后的运行命令
@echo off

:: set 设置变量
:: 这里的%~dp0是指获取当前文件夹
SET CMDER_ROOT=%~dp0

:: Remove Trailing '\'
:: %CMDER_ROOT:~-1%这一句的语法就是类似于python的切片操作
:: 判断该变量最后一个字符是不是\如果是则切除
@if "%CMDER_ROOT:~-1%" == "\" SET CMDER_ROOT=%CMDER_ROOT:~0,-1%

if exist "%~1" (
    start %~dp0/vendor/conemu-maximus5/ConEmu.exe /Icon "%CMDER_ROOT%\icons\cmder.ico" /Title Cmder /LoadCfgFile "%~1"
) else (
    start %~dp0/vendor/conemu-maximus5/ConEmu.exe /Icon "%CMDER_ROOT%\icons\cmder.ico" /Title WDDD /LoadCfgFile "%CMDER_ROOT%\config\user-ConEmu.xml"
)
