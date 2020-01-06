@echo off

:: 如果fast_init为1，则退出
if "%fast_init%" == "1" exit /b

:: 加载lib_base
call "%~dp0lib_base.cmd"

:: 设置lib_console
set lib_console=call "%~dp0lib_console.cmd"

:: 调用lib_base的help调用机制
if "%~1" == "/h" (
    %lib_base% help "%~0"
) else if "%1" neq "" (
    call :%*
)

exit /b

:debug_output
:::===============================================================================
:::debug_output - Output a debug message to the console.
:::.
:::include:
:::.
:::  call "lib_console.cmd"
:::.
:::usage:
:::.
:::  %lib_console% debug_output [caller] [message]
:::.
:::required:
:::.
:::  [caller]  <in> Script/sub routine name calling debug_output
:::.
:::  [message] <in> Message text to display.
:::.
:::-------------------------------------------------------------------------------
	:: gtr表示大于0
	:: 如果debug_output大于0则DEBUG(%~1): %~2 并且换行
    if %debug_output% gtr 0 echo DEBUG(%~1): %~2 & echo.
    exit /b

:verbose_output
:::===============================================================================
:::verbose_output - Output a debug message to the console.
:::.
:::include:
:::.
:::  call "$0"
:::.
:::usage:
:::.
:::  %lib_console% verbose_output "[message]"
:::.
:::required:
:::.
:::  [message] <in> Message text to display.
:::.
:::-------------------------------------------------------------------------------
	:: 如果verbose_output大于0则输出第一个参数
    if %verbose_output% gtr 0 echo %~1
    exit /b

:show_error
:::===============================================================================
:::show_error - Output an error message to the console.
:::.
:::include:
:::.
:::  call "$0"
:::.
:::usage:
:::.
:::  %lib_console% show_error "[message]"
:::.
:::required:
:::.
:::  [message] <in> Message text to display.
:::.
:::-------------------------------------------------------------------------------
	:: 输出ERROR
    echo ERROR: %~1
    exit /b
