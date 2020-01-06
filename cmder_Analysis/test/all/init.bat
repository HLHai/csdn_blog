@echo off

set CMDER_INIT_START=%time%

:: Init Script for cmd.exe
:: Created as part of cmder project

:: !!! THIS FILE IS OVERWRITTEN WHEN CMDER IS UPDATED
:: !!! Use "%CMDER_ROOT%\config\user_profile.cmd" to add your own startup commands

:: Use /v command line arg or set to > 0 for verbose output to aid in debugging.
set verbose_output=0
set debug_output=0
set time_init=0
set fast_init=0
set max_depth=1
:: Add *nix tools to end of path. 0 turns off *nix tools.
set nix_tools=1
set "CMDER_USER_FLAGS= "

:: Find root dir
if not defined CMDER_ROOT (
    if defined ConEmuDir (
        for /f "delims=" %%i in ("%ConEmuDir%\..\..") do (
            set "CMDER_ROOT=%%~fi"
        )
    ) else (
        for /f "delims=" %%i in ("%~dp0\..") do (
            set "CMDER_ROOT=%%~fi"
        )
    )
)

:: Remove trailing '\' from %CMDER_ROOT%
if "%CMDER_ROOT:~-1%" == "\" SET "CMDER_ROOT=%CMDER_ROOT:~0,-1%"

call "%cmder_root%\vendor\bin\cexec.cmd" /setpath
call "%cmder_root%\vendor\lib\lib_base"
call "%cmder_root%\vendor\lib\lib_path"
call "%cmder_root%\vendor\lib\lib_console"
call "%cmder_root%\vendor\lib\lib_git"
call "%cmder_root%\vendor\lib\lib_profile"

:var_loop
    :: 判断如果第一个参数是空，则这里就跳转到start
    if "%~1" == "" (
        goto :start
    ) else if /i "%1" == "/f" (
        :: 设置fast_init=1
        set fast_init=1
    ) else if /i "%1" == "/t" (
        :: 设置time_init为1
        set time_init=1
    ) else if /i "%1"=="/v" (
        :: 设置verbose_output=1
        set verbose_output=1
    ) else if /i "%1"=="/d" (
        :: 设置debug_output的开关
        set debug_output=1
    ) else if /i "%1" == "/max_depth" (
        :: 如果第一个参数为max_depth，并且%~2在1~5之前
        if "%~2" geq "1" if "%~2" leq "5" (
            :: 则设置max_depth为%~2
            set "max_depth=%~2"
            :: 左移变量
            shift
        ) else (
            :: 报错
            %lib_console% show_error "'/max_depth' requires a number between 1 and 5!"
            exit /b
        )
    ) else if /i "%1" == "/c" (
        if exist "%~2" (
            :: 如果不存在则创建
            if not exist "%~2\bin" mkdir "%~2\bin"
            :: 设置bin
            set "cmder_user_bin=%~2\bin"
            :: 如果profile.d不存在则创建profile.d
            if not exist "%~2\config\profile.d" mkdir "%~2\config\profile.d"
            set "cmder_user_config=%~2\config"
            shift
        )
    ) else if /i "%1" == "/user_aliases" (
        if exist "%~2" (
            :: 设置user_aliases
            :: 这里实际上就可以对user_aliases进行设置
            set "user_aliases=%~2"
            shift
        )
    ) else if /i "%1" == "/git_install_root" (
        if exist "%~2" (
            :: 这里应该是设置自定义的git
            set "GIT_INSTALL_ROOT=%~2"
            shift
        ) else (
            %lib_console% show_error "The Git install root folder "%~2", you specified does not exist!"
            exit /b
        )
    ) else if /i "%1"=="/nix_tools" (
        if "%2" equ "0" (
            :: nix_tools=0
            REM Do not add *nix tools to path
            set nix_tools=0
            shift
        ) else if "%2" equ "1" (
            REM Add *nix tools to end of path
            :: nix_tools=1
            set nix_tools=1
            shift
        ) else if "%2" equ "2" (
            REM Add *nix tools to front of path
            :: nix_tools=2
            set nix_tools=2
            shift
        )
    ) else if /i "%1" == "/home" (
        if exist "%~2" (
            :: HOME=第二个参数
            set "HOME=%~2"
            shift
        ) else (
            %lib_console% show_error The home folder "%2", you specified does not exist!
            exit /b
        )
    ) else if /i "%1" == "/svn_ssh" (
        :: 设置SVN_SSH
        set SVN_SSH=%2
        shift
    ) else (
      set "CMDER_USER_FLAGS=%1 %CMDER_USER_FLAGS%"
    )
    shift
goto var_loop

:start
:: Sets CMDER_SHELL, CMDER_CLINK, CMDER_ALIASES
:: 调用cmder_shell，这里一般默认会调用cmder_shell
:: CMDER_SHELL=cmd
:: comspec=C:\Windows\system32\cmd.exe
:: set CMDER_CLINK=1
:: CMDER_ALIASES=1
%lib_base% cmder_shell
:: 测试
%lib_console% debug_output init.bat "Env Var - CMDER_ROOT=%CMDER_ROOT%"
%lib_console% debug_output init.bat "Env Var - debug_output=%debug_output%"
:: 如果CMDER_USER_CONFIG这个配置不存在，则进行debug，但是要开启DEBUG
if defined CMDER_USER_CONFIG (
    %lib_console% debug_output init.bat "CMDER IS ALSO USING INDIVIDUAL USER CONFIG FROM '%CMDER_USER_CONFIG%'!"
)

:: Pick right version of clink
:: %PROCESSOR_ARCHITECTURE%判断内核
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
    set architecture_bits=32
) else (
    set architecture=64
    set architecture_bits=64
)
::这里是在lib_bat中进行了设置
if "%CMDER_CLINK%" == "1" (
  :: debug
  %lib_console% verbose_output "Injecting Clink!"

  :: Run clink
  :: 如果这里CMDER_USER_CONFIG存在则继续向下
  :: 这里的CMDER_USER_CONFIG实际上也是在指定history的存留位置
  if defined CMDER_USER_CONFIG (
    :: 文件不存在则
    if not exist "%CMDER_USER_CONFIG%\settings" (
      :: 打印
      echo Generating clink initial settings in "%CMDER_USER_CONFIG%\settings"
      :: 复制default文件
      copy "%CMDER_ROOT%\vendor\clink_settings.default" "%CMDER_USER_CONFIG%\settings"
      echo Additional *.lua files in "%CMDER_USER_CONFIG%" are loaded on startup.\
    )
    :: 这里调用了clink_x%architecture%.exe
    :: profile history地址
    :: scripts 加载脚本
    :: scripts
    "%CMDER_ROOT%\vendor\clink\clink_x%architecture%.exe" inject --quiet --profile "%CMDER_USER_CONFIG%" --scripts "%CMDER_ROOT%\vendor" --nolog
  ) else (
    :: 文件不存在则使用默认的%CMDER_ROOT%\config\settings
    if not exist "%CMDER_ROOT%\config\settings" (
      echo Generating clink initial settings in "%CMDER_ROOT%\config\settings"
      copy "%CMDER_ROOT%\vendor\clink_settings.default" "%CMDER_ROOT%\config\settings"
      echo Additional *.lua files in "%CMDER_ROOT%\config" are loaded on startup.
    )
    "%CMDER_ROOT%\vendor\clink\clink_x%architecture%.exe" inject --quiet --profile "%CMDER_ROOT%\config" --scripts "%CMDER_ROOT%\vendor" --nolog
  )
) else (
  %lib_console% verbose_output "WARNING: Incompatible 'ComSpec/Shell' Detetected Skipping Clink Injection!"
)

:: Prepare for git-for-windows

:: I do not even know, copypasted from their .bat
:: 设置PLINK_PROTOCOL为ssh
set PLINK_PROTOCOL=ssh
:: 如果没有TERM这个变量则TERM为cygwin
if not defined TERM set TERM=cygwin

:: The idea:
:: * if the users points as to a specific git, use that
:: * test if a git is in path and if yes, use that
:: * last, use our vendored git
:: also check that we have a recent enough version of git by examining the version string
:: 如果GIT_INSTALL_ROOT存在，则使用自定义的GIT_INSTALL_ROOT目录
if defined GIT_INSTALL_ROOT (
    :: 如果文件存在则跳转去SPECIFIED_GIT
    if exist "%GIT_INSTALL_ROOT%\cmd\git.exe" goto :SPECIFIED_GIT
) else if "%fast_init%" == "1" (
    :: 如果fast_init==1则，调用vendor下自带的git.exe，并且跳转到VENDORED_GIT
    if exist "%CMDER_ROOT%\vendor\git-for-windows\cmd\git.exe" (
      %lib_console% debug_output "Skipping Git Auto-Detect!"
      goto :VENDORED_GIT
    )
)

%lib_console% debug_output init.bat "Looking for Git install root..."

:: get the version information for vendored git binary
%lib_git% read_version VENDORED "%CMDER_ROOT%\vendor\git-for-windows\cmd"
%lib_git% validate_version VENDORED %GIT_VERSION_VENDORED%

:: check if git is in path...
for /F "delims=" %%F in ('where git.exe 2^>nul') do (
    :: get the absolute path to the user provided git binary
    call :is_git_shim "%%~dpF"
    call :get_user_git_version
    call :compare_git_versions
)

:: our last hope: our own git...
:VENDORED_GIT
if exist "%CMDER_ROOT%\vendor\git-for-windows" (
    set "GIT_INSTALL_ROOT=%CMDER_ROOT%\vendor\git-for-windows"
    goto :CONFIGURE_GIT
) else (
    goto :NO_GIT
)

:SPECIFIED_GIT
%lib_console% debug_output "Using /GIT_INSTALL_ROOT from '%GIT_INSTALL_ROOT%..."
goto :CONFIGURE_GIT

:FOUND_GIT
%lib_console% debug_output "Using found Git '%GIT_VERSION_USER%' from '%GIT_INSTALL_ROOT%..."
goto :CONFIGURE_GIT

:CONFIGURE_GIT
:: Add git to the path
rem add the unix commands at the end to not shadow windows commands like more
:: 判断nix_tools的值设置path_position的值
if %nix_tools% equ 1 (
    %lib_console% debug_output init.bat "Preferring Windows commands"
    set "path_position=append"
) else (
    %lib_console% debug_output init.bat "Preferring *nix commands"
    set "path_position="
)
:: 如果git.exe存在则将真个cmd都添加都path中去
if exist "%GIT_INSTALL_ROOT%\cmd\git.exe" %lib_path% enhance_path "%GIT_INSTALL_ROOT%\cmd" %path_position%
:: 如果设置目录下存在mingw32则同时添加mingw32\bin，如果是mingw64则添加64
if exist "%GIT_INSTALL_ROOT%\mingw32" (
    %lib_path% enhance_path "%GIT_INSTALL_ROOT%\mingw32\bin" %path_position%
) else if exist "%GIT_INSTALL_ROOT%\mingw64" (
    %lib_path% enhance_path "%GIT_INSTALL_ROOT%\mingw64\bin" %path_position%
)
:: 如果大于1则添加usr bin
if %nix_tools% geq 1 (
    %lib_path% enhance_path "%GIT_INSTALL_ROOT%\usr\bin" %path_position%
)

:: define SVN_SSH so we can use git svn with ssh svn repositories
:: 设置ssh
if not defined SVN_SSH set "SVN_SSH=%GIT_INSTALL_ROOT:\=\\%\\bin\\ssh.exe"

:: Find locale.exe: From the git install root, from the path, using the git installed env, or fallback using the env from the path.
:: 设置locale.exe
if not defined git_locale if exist "%GIT_INSTALL_ROOT%\usr\bin\locale.exe" set git_locale="%GIT_INSTALL_ROOT%\usr\bin\locale.exe"
if not defined git_locale for /F "delims=" %%F in ('where locale.exe 2^>nul') do (if not defined git_locale  set git_locale="%%F")
if not defined git_locale if exist "%GIT_INSTALL_ROOT%\usr\bin\env.exe" set git_locale="%GIT_INSTALL_ROOT%\usr\bin\env.exe" /usr/bin/locale
if not defined git_locale set git_locale=env /usr/bin/locale

%lib_console% debug_output init.bat "Env Var - git_locale=%git_locale%"
:: 设置编码
if not defined LANG (
    for /F "delims=" %%F in ('%git_locale% -uU 2') do (
        set "LANG=%%F"
    )
)

%lib_console% debug_output init.bat "Env Var - GIT_INSTALL_ROOT=%GIT_INSTALL_ROOT%"
%lib_console% debug_output init.bat "Found Git in: '%GIT_INSTALL_ROOT%'"
:: 跳转到PATH_ENHANCE
goto :PATH_ENHANCE

:NO_GIT
:: Skip this if GIT WAS FOUND else we did 'endlocal' above!
endlocal

:PATH_ENHANCE
:: 设置变量vender\bin
%lib_path% enhance_path "%CMDER_ROOT%\vendor\bin"
:: 设置变量bin
%lib_path% enhance_path_recursive "%CMDER_ROOT%\bin" %max_depth%
:: 这里应该是设置用户的bin,自定义可以从这里下手
if defined CMDER_USER_BIN (
  %lib_path% enhance_path_recursive "%CMDER_USER_BIN%" %max_depth%
)
:: 这里添加CMDER_ROOT目录
%lib_path% enhance_path "%CMDER_ROOT%" append

:: Drop *.bat and *.cmd files into "%CMDER_ROOT%\config\profile.d"
:: to run them at startup.
:: 运行config中的profile.d下的所有bat
%lib_profile% run_profile_d "%CMDER_ROOT%\config\profile.d"
:: 如果存在CMDER_USER_CONFIG则调用CMDER_USER_CONFIG的profile.d
if defined CMDER_USER_CONFIG (
  %lib_profile% run_profile_d "%CMDER_USER_CONFIG%\profile.d"
)

:: Allows user to override default aliases store using profile.d
:: scripts run above by setting the 'aliases' env variable.
::
:: Note: If overriding default aliases store file the aliases
:: must also be self executing, see '.\user_aliases.cmd.default',
:: and be in profile.d folder.
:: 如果user_aliases不存在，则判断CMDER_USER_CONFIG(自定义)
:: 最后则调用config\user_aliases.cmd
if not defined user_aliases (
  if defined CMDER_USER_CONFIG (
     set "user_aliases=%CMDER_USER_CONFIG%\user_aliases.cmd"
  ) else (
     set "user_aliases=%CMDER_ROOT%\config\user_aliases.cmd"
  )
)
:: CMDER_ALIASES出现了 
if "%CMDER_ALIASES%" == "1" (
  REM The aliases environment variable is used by alias.bat to id
  REM the default file to store new aliases in.
  :: 如果aliases不存在则设置aliases为user_aliases
  if not defined aliases (
    set "aliases=%user_aliases%"
  )

  REM Make sure we have a self-extracting user_aliases.cmd file
  :: 如果user_aliases不存在，将user_aliases.cmd.defaultcopy过去....
  if not exist "%user_aliases%" (
      echo Creating initial user_aliases store in "%user_aliases%"...
      copy "%CMDER_ROOT%\vendor\user_aliases.cmd.default" "%user_aliases%"
  ) else (
    :: 校验user_aliases
    %lib_base% update_legacy_aliases
  )

  :: Update old 'user_aliases' to new self executing 'user_aliases.cmd'
  :: 如果此文件存在，将aliases移动到user_aliases并且删除aliases
  :: 这里是向上进行兼容，并且还强制更新了，如果在意这里注释这里的del
  if exist "%CMDER_ROOT%\config\aliases" (
    echo Updating old "%CMDER_ROOT%\config\aliases" to new format...
    type "%CMDER_ROOT%\config\aliases" >> "%user_aliases%"
    del "%CMDER_ROOT%\config\aliases"
  ) else if exist "%user_aliases%.old_format" (
    echo Updating old "%user_aliases%" to new format...
    type "%user_aliases%.old_format" >> "%user_aliases%"
    del "%user_aliases%.old_format"
  )
)

:: Add aliases to the environment
:: 运行user_aliases，这里可能又要暂停一段时间了。
call "%user_aliases%"

:: See vendor\git-for-windows\README.portable for why we do this
:: Basically we need to execute this post-install.bat because we are
:: manually extracting the archive rather than executing the 7z sfx
:: 判断post-install.bat的存在
if exist "%GIT_INSTALL_ROOT%\post-install.bat" (
    echo Running Git for Windows one time Post Install....
    :: 更改目录
    pushd "%GIT_INSTALL_ROOT%\"
    :: 运行post-install.bat
    "%GIT_INSTALL_ROOT%\git-cmd.exe" --no-needs-console --no-cd --command=post-install.bat
    popd
)

:: Set home path
:: HOME获取到初始目录
if not defined HOME set "HOME=%USERPROFILE%"
%lib_console% debug_output init.bat "Env Var - HOME=%HOME%"
:: initialConfig为user_profile.cmd
set "initialConfig=%CMDER_ROOT%\config\user_profile.cmd"
:: 判断是否存在
if exist "%CMDER_ROOT%\config\user_profile.cmd" (
    REM Create this file and place your own command in there
    %lib_console% debug_output init.bat "Calling - %CMDER_ROOT%\config\user_profile.cmd"
    :: 存在则进行执行
    call "%CMDER_ROOT%\config\user_profile.cmd"
)
:: 自定义的user_profile
if defined CMDER_USER_CONFIG (
  set "initialConfig=%CMDER_USER_CONFIG%\user_profile.cmd"
  if exist "%CMDER_USER_CONFIG%\user_profile.cmd" (
      REM Create this file and place your own command in there
      %lib_console% debug_output init.bat "Calling - %CMDER_USER_CONFIG%\user_profile.cmd"
      call "%CMDER_USER_CONFIG%\user_profile.cmd"
  )
)

:: 如果initialConfig不存在则进行复制
if not exist "%initialConfig%" (
    echo Creating user startup file: "%initialConfig%"
    copy "%CMDER_ROOT%\vendor\user_profile.cmd.default" "%initialConfig%"
)
:: 同时满足这三个条件，则提示，这里预计是对版本要求
if "%CMDER_ALIASES%" == "1" 
  if exist "%CMDER_ROOT%\bin\alias.bat" 
    if exist "%CMDER_ROOT%\vendor\bin\alias.cmd" (
    echo Cmder's 'alias' command has been moved into "%CMDER_ROOT%\vendor\bin\alias.cmd"
    echo to get rid of this message either:
    echo.
    echo Delete the file "%CMDER_ROOT%\bin\alias.bat"
    echo.
    echo or
    echo.
    echo If you have customized it and want to continue using it instead of the included version
    echo   * Rename "%CMDER_ROOT%\bin\alias.bat" to "%CMDER_ROOT%\bin\alias.cmd".
    echo   * Search for 'user-aliases' and replace it with 'user_aliases'.
)

set initialConfig=
set CMDER_CONFIGURED=1

set CMDER_INIT_END=%time%

if %time_init% gtr 0 (
  "%cmder_root%\vendor\bin\timer.cmd" %CMDER_INIT_START% %CMDER_INIT_END%
)
exit /b

:is_git_shim
    pushd "%~1"
    :: check if there's shim - and if yes follow the path
    setlocal enabledelayedexpansion
    if exist git.shim (
        for /F "tokens=2 delims== " %%I in (git.shim) do (
            pushd %%~dpI
            set "test_dir=!CD!"
            popd
        )
    ) else (
        set "test_dir=!CD!"
    )
    endlocal & set "test_dir=%test_dir%"

    popd
    exit /b

:compare_git_versions
    if %errorlevel% geq 0 (
        :: compare the user git version against the vendored version
        %lib_git% compare_versions USER VENDORED

        :: use the user provided git if its version is greater than, or equal to the vendored git
        if %errorlevel% geq 0 if exist "%test_dir:~0,-4%\cmd\git.exe" (
            set "GIT_INSTALL_ROOT=%test_dir:~0,-4%"
            set test_dir=
            goto :FOUND_GIT
        ) else if %errorlevel% geq 0 (
            set "GIT_INSTALL_ROOT=%test_dir%"
            set test_dir=
            goto :FOUND_GIT
        ) else (
            call :verbose_output Found old %GIT_VERSION_USER% in "%test_dir%", but not using...
            set test_dir=
        )
    ) else (
        :: if the user provided git executable is not found
        if %errorlevel% equ -255 (
            call :verbose_output No git at "%git_executable%" found.
            set test_dir=
        )
    )
    exit /b

:get_user_git_version

    :: get the version information for the user provided git binary
    %lib_git% read_version USER "%test_dir%"
    %lib_git% validate_version USER %GIT_VERSION_USER%
    exit  /b

