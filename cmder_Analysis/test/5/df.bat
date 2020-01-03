@echo OFF

set ceshi=1

if defined DEMO (
	echo ok
) else (
	echo no DEMO
)

if defined ceshi (
	echo ok,ceshi
) else (
	echo no ceshi
)