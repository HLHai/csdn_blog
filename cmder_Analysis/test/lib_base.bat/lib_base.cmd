@echo off

:: 设置lib_base变量为call %~dp0lib_base.cmd
set lib_base=call "%~dp0lib_base.cmd"

:: 如果第一个命令行变量为/h
if "%~1" == "/h" (
    :: 相当于执行lib_base.cmd help lib_base.cmd
    %lib_base% help "%~0"
) else if "%1" neq "" (
    ::如果%1不为空的话，则将输入的参数作为标签名进行调用
    call :%*
)

exit /b

:help
:::===============================================================================
:::show_subs - shows all sub routines in a .bat/.cmd file with documentation
:::.
:::include:
:::.
:::       call "lib_base.cmd"
:::.
:::usage:
:::.
:::       %lib_base% show_subs "file"
:::.
:::options:
:::.
:::       file <in> full path to file containing lib_routines to display
:::.
:::-------------------------------------------------------------------------------
    :: 这里就是使用win下的findstr来对:::的内容进行搜索，然后使用tokens=*去除空格
    for /f "tokens=* delims=:" %%a in ('type "%~1" ^| %WINDIR%\System32\findstr /i /r "^:::"') do (
    :: 这里脚本的作者可能是为了想用.来代替换行的感觉
        if "%%a"=="." (
            echo.
        ) else if /i "%%a" == "usage" (
            echo %%a:
        ) else if /i "%%a" == "options" (
            echo %%a:
        ) else if not "%%a" == "" (
            echo %%a
        )
    )

    pause
    exit /b

:cmder_shell
:::===============================================================================
:::show_subs - shows all sub routines in a .bat/.cmd file with documentation
:::.
:::include:
:::.
:::       call "lib_base.cmd"
:::.
:::usage:
:::.
:::       %lib_base% cmder_shell
:::.
:::options:
:::.
:::       file <in> full path to file containing lib_routines to display
:::.
:::-------------------------------------------------------------------------------
    :: 1.这里有一个知识点可以学习，利用|管道进行赋值 
    echo %comspec% | %WINDIR%\System32\find /i "\cmd.exe" > nul && set "CMDER_SHELL=cmd"
    echo %comspec% | %WINDIR%\System32\find /i "\tcc.exe" > nul && set "CMDER_SHELL=tcc"
    echo %comspec% | %WINDIR%\System32\find /i "\tccle" > nul && set "CMDER_SHELL=tccle"
    :: 如果CMDER_CLINK不存在则是CMDER_CLINK=1
    if not defined CMDER_CLINK (
        set CMDER_CLINK=1
        :: 如果CMDER_SHELL是tcc以及tccle则CMDER_CLINK变为0
        if "%CMDER_SHELL%" equ "tcc" set CMDER_CLINK变为0=0
        if "%CMDER_SHELL%" equ "tccle" set CMDER_CLINK=0
    )
    :: 如果CMDER_ALIASES不存在则CMDER_ALIASES置为1
    if not defined CMDER_ALIASES (
        set CMDER_ALIASES=1
        :: 如果CMDER_ALIASES是tcc以及tccle则CMDER_CLINK变为0
        if "%CMDER_SHELL%" equ "tcc" set CMDER_ALIASES=0
        if "%CMDER_SHELL%" equ "tccle" set CMDER_ALIASES=0
    )

    exit /b

:update_legacy_aliases
    :: 这里其实就是判断文件是否有;=
    type "%user_aliases%" | %WINDIR%\System32\findstr /i ";= Add aliases below here" >nul
    :: 如果不存在errorlevel==1
    if "%errorlevel%" == "1" (
        :: 打印
        echo Creating initial user_aliases store in "%user_aliases%"...
        :: 判断CMDER_USER_CONFIG是否存在
        if defined CMDER_USER_CONFIG (
            :: 备份当前的 aliases,且将user_aliases.cmd.default复制为新的aliases
            copy "%user_aliases%" "%user_aliases%.old_format"
            copy "%CMDER_ROOT%\vendor\user_aliases.cmd.default" "%user_aliases%"
        ) else (
            copy "%user_aliases%" "%user_aliases%.old_format"
            copy "%CMDER_ROOT%\vendor\user_aliases.cmd.default" "%user_aliases%"
        )
    )
    exit /b
