@echo off
setlocal enabledelayedexpansion

rem [begin main]
if "%1" == "" (
	goto :help
)

if "%1" == "-l" (
	diskpart /s %~dp0\eject\listvolume
)

if "%1" == "-r" (
	if "%2" == "" (
		goto :help
	)
	echo select volume  %2  > %~dp0\eject\dismount
	echo remove all dismount >> %~dp0\eject\dismount
	diskpart /s %~dp0\eject\dismount
)
goto :EOF
rem [end main]

rem [begin help]
:help
	echo EJECT [command]
	echo.
	echo -l		List all volume
	echo -r [Num]	Safely remove
	echo -i [Num]	Insert a usb and assign a letter
goto :EOF
rem [end help]

endlocal
