@echo off

:: 调用lib_base
call "%~dp0lib_base.cmd"
:: 调用lib_console
call "%%~dp0lib_console"
:: 设置lib_profile
set lib_profile=call "%~dp0lib_profile.cmd"

if "%~1" == "/h" (
    %lib_base% help "%~0"
) else if "%1" neq "" (
    call :%*
)

exit /b

:run_profile_d
:::===============================================================================
:::run_profile_d - Run all scripts in the passed dir path
:::
:::include:
:::
:::  call "lib_profile.cmd"
:::
:::usage:
:::
:::  %lib_profile% "[dir_path]"
:::
:::required:
:::
:::  [dir_path] <in> Fully qualified directory path containing init *.cmd|*.bat.
:::                  Example: "c:\bin"
:::
:::  path       <out> Sets the path env variable if required.
:::-------------------------------------------------------------------------------
  :: 如果第一个参数不存在，则创建文件夹
  if not exist "%~1" (
    mkdir "%~1"
  )
  :: 相当于路径切换到%~1
  pushd "%~1"
  :: 运行该文件夹下的所有的bat文件
  for /f "usebackq" %%x in ( `dir /b *.bat *.cmd 2^>nul` ) do (
    %lib_console% verbose_output "Calling '%~1\%%x'..."
    call "%~1\%%x"
  )
  :: 还原环境变量
  popd
  exit /b

