@echo off

SET demo=1231

echo %demo%

@if "%demo:~-1%"=="1" echo ok

pause