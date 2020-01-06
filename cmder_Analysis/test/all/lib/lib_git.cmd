@echo off

:: 加载lib_base
call "%~dp0lib_base.cmd"
:: 加载lib_console
call "%%~dp0lib_console.cmd"
:: 设置自己的call
set lib_git=call "%~dp0lib_git.cmd"

if "%~1" == "/h" (
    %lib_base% help "%~0"
) else if "%1" neq "" (
    call :%*
)

exit /b

:read_version
:::===============================================================================
:::read_version - Get the git.exe verion
:::.
:::include:
:::.
:::  call "lib_git.cmd"
:::.
:::usage:
:::.
:::  %lib_git% read_version "[dir_path]"
:::.
:::required:
:::.
:::  [GIT SCOPE]   <in> USER | VENDORED
:::  [GIT PATH]    <in> Fully qualified path to the Git command root.
:::.
:::output:
:::.
:::  GIT_VERSION_[GIT SCOPE] <out> Env variable containing Git semantic version string
:::-------------------------------------------------------------------------------

    :: clear the variables
    :: 设置GIT_VERSION_%~1变量
    set GIT_VERSION_%~1=

    :: set the executable path
    :: 设置git_executable变量为git的目录
    set "git_executable=%~2\git.exe"
    :: 打印
    %lib_console% debug_output :read_version "Env Var - git_executable=%git_executable%"

    :: check if the executable actually exists
    :: 如果git_executable不存在则返回错误信息
    if not exist "%git_executable%" (
        %lib_console% debug_output :read_version "%git_executable% does not exist."
        exit /b -255
    )

    :: get the git version in the provided directory
    :: 执行git_executable --version,并且将结果放到temp
    "%git_executable%" --version > "%temp%\git_version.txt"
    :: 直到出现匹配的 endlocal 命令，无论 setlocal 命令之前的设置如何
    setlocal enabledelayedexpansion
    :: 读取文件中的内容
    for /F "tokens=1,2,3 usebackq" %%A in (`type "%temp%\git_version.txt" 2^>nul`) do (
        :: 如果判断是git version，则GIT_VERSION为第三个数值
        if /i "%%A %%B" == "git version" (
            set "GIT_VERSION=%%C"
        ) else (
            echo "'git --version' returned an inproper version string!"
            pause
            exit /b
        )
    )
    ::使GIT_VERSION_%~1获取到GIT_VERSION的值
    endlocal & set "GIT_VERSION_%~1=%GIT_VERSION%" & %lib_console% debug_output :read_version "Env Var - GIT_VERSION_%~1=%GIT_VERSION%"

    exit /b

:parse_version
:::===============================================================================
:::parse_version - Parse semantic version string 'x.x.x.x' and return the pieces
:::.
:::include:
:::.
:::  call "$0"
:::.
:::usage:
:::.
:::  %lib_git% parse_version "[VERSION]"
:::.
:::required:
:::.
:::  [SCOPE]     <in> USER | VENDORED
:::  [VERSION]   <in> Semantic version String. Ex: 1.2.3.4
:::.
:::output:
:::.
:::  [SCOPE]_MAJOR <out> Scoped Major version.
:::  [SCOPE]_MINOR <out> Scoped Minor version.
:::  [SCOPE]_PATCH <out> Scoped Patch version.
:::  [SCOPE]_BUILD <out> Scoped Build version.
:::-------------------------------------------------------------------------------

    :: process a `x.x.x.xxxx.x` formatted string
    :: debug
    %lib_console% debug_output :parse_version "ARGV[1]=%~1, ARGV[2]=%~2"

    setlocal enabledelayedexpansion
    :: 将第二个参数进行分割
    for /F "tokens=1-3* delims=.,-" %%A in ("%2") do (
        set "%~1_MAJOR=%%A"
        set "%~1_MINOR=%%B"
        set "%~1_PATCH=%%C"
        set "%~1_BUILD=%%D"
    )

    REM endlocal & set "%~1_MAJOR=!%~1_MAJOR!" & set "%~1_MINOR=!%~1_MINOR!" & set "%~1_PATCH=!%~1_PATCH!" & set "%~1_BUILD=!%~1_BUILD!"
    :: 如果第一个参数是VENDORED
    if "%~1" == "VENDORED" (
      :: 如果是VENDORED则进行设置VENDORED的MAJOR
      endlocal & set "%~1_MAJOR=%VENDORED_MAJOR%" & set "%~1_MINOR=%VENDORED_MINOR%" & set "%~1_PATCH=%VENDORED_PATCH%" & set "%~1_BUILD=%VENDORED_BUILD%"
    ) else (
      :: 如果不是则设置USER
      endlocal & set "%~1_MAJOR=%USER_MAJOR%" & set "%~1_MINOR=%USER_MINOR%" & set "%~1_PATCH=%USER_PATCH%" & set "%~1_BUILD=%USER_BUILD%"
    )

    exit /b

:endlocal_set_git_version

:validate_version
:::===============================================================================
:::validate_version - Validate semantic version string 'x.x.x.x'.
:::.
:::include:
:::.
:::  call "$0"
:::.
:::usage:
:::.
:::  %lib_git% validate_version [SCOPE] [VERSION]
:::.
:::required:
:::.
:::  [SCOPE]     <in> Example:  USER | VENDORED
:::  [VERSION]   <in> Semantic version String. Ex: 1.2.3.4
:::-------------------------------------------------------------------------------

    :: now parse the version information into the corresponding variables
    %lib_console% debug_output :validate_version "ARGV[1]=%~1, ARGV[2]=%~2"
    :: 跳转到parse_version
    call :parse_version %~1 %~2

    :: ... and maybe display it, for debugging purposes.
    REM %lib_console% debug_output :validate_version "Found Git Version for %~1: !%~1_MAJOR!.!%~1_MINOR!.!%~1_PATCH!.!%~1_BUILD!"
    if "%~1" == "VENDORED" (
      %lib_console% debug_output :validate_version "Found Git Version for %~1: %VENDORED_MAJOR%.%VENDORED_MINOR%.%VENDORED_PATCH%.%VENDORED_BUILD%"
    ) else (
      %lib_console% debug_output :validate_version "Found Git Version for %~1: %USER_MAJOR%.%USER_MINOR%.%USER_PATCH%.%USER_BUILD%"
    )
    exit /b

:compare_versions
:::===============================================================================
:::compare_version - Compare semantic versions return latest version.
:::.
:::include:
:::.
:::  call "$0"
:::.
:::usage:
:::.
:::  %lib_git% validate_version [SCOPE1] [SCOPE2]
:::.
:::required:
:::.
:::  [SCOPE1]    <in> Example: USER
:::  [SCOPE2]    <in> Example: VENDOR
:::-------------------------------------------------------------------------------

    :: checks all major, minor, patch and build variables for the given arguments.
    :: whichever binary that has the most recent version will be used based on the return code.

    %lib_console% debug_output Comparing:
    %lib_console% debug_output %~1: %USER_MAJOR%.%USER_MINOR%.%USER_PATCH%.%USER_BUILD%
    %lib_console% debug_output %~2: %VENDORED_MAJOR%.%VENDORED_MINOR%.%VENDORED_PATCH%.%VENDORED_BUILD%

    setlocal enabledelayedexpansion
    :: 通过对比来进行返回不同的返回码，其意思应为对比是否相等
    if !%~1_MAJOR! GTR !%~2_MAJOR! (endlocal & exit /b  1)
    if !%~1_MAJOR! LSS !%~2_MAJOR! (endlocal & exit /b -1)

    if !%~1_MINOR! GTR !%~2_MINOR! (endlocal & exit /b  1)
    if !%~1_MINOR! LSS !%~2_MINOR! (endlocal & exit /b -1)

    if !%~1_PATCH! GTR !%~2_PATCH! (endlocal & exit /b  1)
    if !%~1_PATCH! LSS !%~2_PATCH! (endlocal & exit /b -1)

    if !%~1_BUILD! GTR !%~2_BUILD! (endlocal & exit /b  1)
    if !%~1_BUILD! LSS !%~2_BUILD! (endlocal & exit /b -1)

    :: looks like we have the same versions.
    endlocal & exit /b 0
