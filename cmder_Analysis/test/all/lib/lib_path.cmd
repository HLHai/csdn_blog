@echo off

:: 加载lib_base.cmd
call "%~dp0lib_base.cmd"
:: 这句也不知道在call啥，严重怀疑是不是多写了一个%
call "%%~dp0lib_console"
:: 设置lib_path为%~dp0lib_path.cmd
set lib_path=call "%~dp0lib_path.cmd"

:: 这里就和lib_base.cmd一样了
if "%~1" == "/h" (
    :: 这里直接对%lib_base%帮助文档的方案进行复用了！！！
    %lib_base% help "%~0"
) else if "%1" neq "" (
    call :%*
)

exit /b

:enhance_path
:::===============================================================================
:::enhance_path - Add a directory to the path env variable if required.
:::
:::include:
:::
:::  call "lib_path.cmd"
:::
:::usage:
:::
:::  %lib_path% enhance_path "[dir_path]" [append]
:::
:::required:
:::
:::  [dir_path] <in> Fully qualified directory path. Ex: "c:\bin"
:::
:::options:
:::
:::  append     <in> Append to the path env variable rather than pre-pend.
:::
:::output:
:::
:::  path       <out> Sets the path env variable if required.
:::-------------------------------------------------------------------------------
    :: 如果第一个变量不对空则对add_path进行赋值
    if "%~1" neq "" (
        set "add_path=%~1"
    ) else (
        %lib_console% show_error "You must specify a directory to add to the path!"
        exit 1
    )
    :: 如果第二个参数不为空，并且第二个参数为append则使position为第二个参数
    if "%~2" neq "" if /i "%~2" == "append" (
        set "position=%~2"
    ) else (
        set "position="
    )

    :: 如果fast_init参数为1，并且position为append则设置PATH变量为%PATH%;%add_path%
    :: 如果position不是append,就把此变量放在最前面
    :: 这里猜测是准备设置变量了。
    :: %PATH%获取环境变量的意思
    if "%fast_init%" == "1" (
      if "%position%" == "append" (
        set "PATH=%PATH%;%add_path%"
      ) else (
        set "PATH=%add_path%;%PATH%"
      )
    )

    :: 这里使用到了变量的替换，检测;;将其转化为;
    :: 可能是作者遇到过bug，这里为了防止bug
    set "PATH=%PATH:;;=;%"
    :: 如果fast_init==1则退出
    if "%fast_init%" == "1" (
      exit /b
    )

    rem setlocal enabledelayedexpansion

    :: 设置变量found=0
    set found=0
    :: find_query=%add_path%
    set "find_query=%add_path%"
    :: 将find_query中的\变为\\
    set "find_query=%find_query:\=\\%"
    :: 将find_query中的 变为\ 
    set "find_query=%find_query: =\ %"
    :: 如果CMDER_CONFIGURED==1
    :: 这里的作用就是判断要添加的变量是否在PATH中存在
    if "%CMDER_CONFIGURED%" == "1" (
      ::这里调用lib_console 的debug_output标签进行了一个log的打印
      %lib_console% debug_output  :enhance_path "Env Var - find_query=%find_query%"
      echo "path%"|%WINDIR%\System32\findstr >nul% /I /R ";%find_query%\"$"
      REM if "!ERRORLEVEL!" == "0" set found=1
      call :set_found
    )
    :: 日志打印found的值
    %lib_console% debug_output  :enhance_path "Env Var 1 - found=%found%"
    :: 如果found是0并且CMDER_CONFIGURED是1的话则跳转至set_found
    if "%found%" == "0" (
        if "%CMDER_CONFIGURED%" == "1" (
            echo "%path%"|%WINDIR%\System32\findstr >nul /i /r ";%find_query%;"
            REM if "!ERRORLEVEL!" == "0" set found=1
            call :set_found
        )
        :: 打印日志
        %lib_console% debug_output  :enhance_path "Env Var 2 - found=%found%"
    )
    :: 如果found是0，并且position为append，则添加path到最后
    :: 如果不是append则添加在最前
    if "%found%" == "0" (
        %lib_console% debug_output :enhance_path "BEFORE Env Var - PATH=%path%"
        if /i "%position%" == "append" (
            %lib_console% debug_output :enhance_path "Appending '%add_path%'"
            set "PATH=%PATH%;%add_path%"
        ) else (
            %lib_console% debug_output :enhance_path "Prepending '%add_path%'"
            set "PATH=%add_path%;%PATH%"
        )

        %lib_console% debug_output  :enhance_path "AFTER Env Var - PATH=%path%"
    )

    rem :end_enhance_path
    rem endlocal & set "PATH=%PATH:;;=;%"
    :: 查重
    set "PATH=%PATH:;;=;%"
    exit /b

:set_found
    if "!ERRORLEVEL!" == "0" set found=1
    exit /b

:enhance_path_recursive
:::===============================================================================
:::enhance_path_recursive - Add a directory and subs to the path env variable if
:::                         required.
:::.
:::include:
:::.
:::  call "$0"
:::.
:::usage:
:::.
:::  call "%~DP0lib_path" enhance_path_recursive "[dir_path]" [max_depth] [append]
:::.
:::required:
:::.
:::  [dir_path] <in> Fully qualified directory path. Ex: "c:\bin"
:::.
:::options:
:::.
:::  [max_depth] <in> Max recuse depth.  Default: 1
:::.
:::  append      <in> Append instead to path env variable rather than pre-pend.
:::.
:::output:
:::.
:::  path       <out> Sets the path env variable if required.
:::-------------------------------------------------------------------------------
    :: 如果输入参数不为空，则add_path为第一个参数
    if "%~1" neq "" (
        set "add_path=%~1"
    ) else (
        %lib_console% show_error "You must specify a directory to add to the path!"
        exit 1
    )
    :: 如果第二个参数>1
    :: 则max_depth为输入的值
    :: 否则max_depth为1
    if "%~2" gtr "1" (
        set "max_depth=%~2"
    ) else (
        set "max_depth=1"
    )
    ::如果第三个参数是append则position就是输入的值
    if "%~3" neq "" if /i "%~3" == "append" (
        set "position=%~3"
    ) else (
        set "position="
    )
    ::如果fast_init为1则调用enhance_path
    if "%fast_init%" == "1" (
      call :enhance_path "%add_path%" %position%
    )
    :: 对PATH去重
    set "PATH=%PATH:;;=;%"
    if "%fast_init%" == "1" (
      exit /b
    )

    rem setlocal enabledelayedexpansion
    :: 如果%depth%是空的话，则将depth置为0
    if "%depth%" == "" set depth=0
    :: 日志打印
    %lib_console% debug_output  :enhance_path_recursive "Env Var - add_path=%add_path%"
    %lib_console% debug_output  :enhance_path_recursive "Env Var - position=%position%"
    %lib_console% debug_output  :enhance_path_recursive "Env Var - max_depth=%max_depth%"
    :: 如果max_depth>depth
    if %max_depth% gtr %depth% (
        %lib_console% debug_output :enhance_path_recursive "Adding parent directory - '%add_path%'"
        :: 调用enhance_path标签
        call :enhance_path "%add_path%" %position%
        REM set /a "depth=!depth!+1"
        :: 让depth+1
        call :set_depth
        :: 调用loop_depth
        call :loop_depth
    )

    rem :end_enhance_path_recursive
    rem endlocal & set "PATH=%PATH%"
    set "PATH=%PATH%"
    exit /b

: set_depth
    set /a "depth=%depth%+1"
    exit /b

:loop_depth
    :: 这里实际上就是讲某add_path的目录下的内容全部加到path里面。
    for /d %%i in ("%add_path%\*") do (
        %lib_console% debug_output  :enhance_path_recursive "Env Var BEFORE - depth=%depth%"
        %lib_console% debug_output :enhance_path_recursive "Found Subdirectory - '%%~fi'"
        call :enhance_path_recursive "%%~fi" %max_depth% %position%
        %lib_console% debug_output  :enhance_path_recursive "Env Var AFTER- depth=%depth%"
    )
    exit /b

