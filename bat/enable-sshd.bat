@echo off
setlocal EnableDelayedExpansion

if not exist "C:\Program Files\Git" (
	echo Git for Windows is not installed.
	exit
)

call :admin

set self=%0
call :init

:loop
if NOT "%1" == "" (
	goto :ParseArgs
:ParseEnd
	shift
	goto :loop
) else if NOT "!Exec!" == "1" (
	call :help
	goto :end
)

call :exec

pause
goto :end

:genkey
echo =====Step 1: Generate Keys=====
if not exist "!userprofile!\.ssh\id_rsa.pub" (
	"C:\Program Files\Git\usr\bin\ssh-keygen.exe"
)
if not exist "C:\Program Files\Git\etc\ssh\ssh_host_rsa_key" (
	"C:\Program Files\Git\usr\bin\ssh-keygen.exe" -A
)
echo.
goto :EOF

:nopasswd
echo =====Step 2: Generate No Password file=====
set keys=!userprofile!\.ssh\authorized_keys
if not exist !userprofile!\.ssh\ (
	mkdir !userprofile!\.ssh\
)
break > !keys!
icacls !keys! /inheritancelevel:d 
icacls !keys! /remove Administrators
echo.
goto :EOF

:autorun
echo =====Step 3: Create AutoRun=====
set sshfile=!userprofile!\desktop\sshd.xml
if exist !sshfile! del !sshfile!
call :dumpfile !self! "sshd" >> !sshfile!
call :dumpfile !self! "bashrc" > !userprofile!\.bashrc
taskkill /im sshd.exe /f
schtasks /delete /tn sshd /f
schtasks /create /xml !sshfile! /tn sshd
schtasks /run /tn sshd /i
del !sshfile!
echo.
goto :EOF

:setpassword
if NOT "!SetPassword!" == "1" goto :EOF
echo =====Step 4: Set Default Password=====
set str=
set hdr=
for /f "delims=" %%i in ('net user !username!') do (
	set str=%%i
	set hdr=!str:~0,17!
	if "!hdr!" == "Password required" (
		for /f "tokens=1,2,3*" %%a in ("!str!") do set value=%%c
		if "!value!" == "No" (
:pwdloop
			set /p yn=Set default password to !username! ^(Y/n^) 
			if /i "!yn!" == "n" (
				goto :pwdbreak
			) else if /i "!yn!" == "" (
				set yn=!yn!
			) else if /i NOT "!yn!" == "y" (
				echo input y or n
				goto :pwdloop
			)
			net user !username! !username!
		)
	)
)
:pwdbreak

goto :EOF

:dumpfile
set findfile=%1
set name=%~2
set found=0
set str=

if "!name!" == "" (
	echo missing name
	goto :EOF
)

echo =====Dump !name!===== >&2
for /f "delims=" %%i in (!findfile!) do (
	set str=%%i
	if "!str!" == "start!name!" (
		set found=1
	) else if "!str!" == "end!name!" (
		goto :EOF
	) else if "!found!" == "1" (
		if "!str:~0,7!" == "<UserId" (
			if "!name!" == "sshd" (
				echo ^<UserId^>!userdomain!\!username!^</UserId^>
			) else (
				goto :dumpelse
			)
		) else (
:dumpelse
			echo !str!
		)
	)
)
goto :EOF

:exec

if NOT "!list!" == "" (
	for %%i in (!list!) do (
		call :%%i
	)
) else (
	call :genkey
	call :nopasswd
	call :autorun
	call :setpassword
)

goto :EOF

:ParseArgs
if /i "%1" == "genkey" (
	call :addlist genkey
)

if /i "%1" == "nopwd" (
	call :addlist nopasswd
)

if /i "%1" == "autorun" (
	call :addlist autorun
)

if /i "%1" == "setpwd" (
	set SetPassword=1
	call :addlist setpassword
)

if /i "%1" == "--dftpwd" (
	set SetPassword=1
)

if /i "%1" == "-h" (
	set Exec=0
)
goto :ParseEnd

:addlist
set list=!list! %1
goto :EOF

:help
echo %0 ^[genkey^|nopwd^|autorun^|setpwd^|--dftpwd^]
echo genkey/nopwd/autorun/setpwd
echo 	execute action
echo --dftpwd
echo 	set default password when execute default action
goto :EOF

:init
set action=
set SetPassword=0
set list=
set Exec=1
goto :EOF

:admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
	goto UACPrompt
) else (
	goto gotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~f0", "%*", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
goto :EOF

startsshd
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo>
<Date>2019-11-14T10:33:36</Date>
<Author>tom</Author>
</RegistrationInfo>
<Triggers>
<LogonTrigger>
<StartBoundary>2019-11-14T10:33:00</StartBoundary>
<Enabled>true</Enabled>
<UserId>WIN7_X86\tom</UserId>
</LogonTrigger>
</Triggers>
<Principals>
<Principal id="Author">
<UserId>WIN7_X86\tom</UserId>
<LogonType>InteractiveToken</LogonType>
<RunLevel>HighestAvailable</RunLevel>
</Principal>
</Principals>
<Settings>
<MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
<DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
<StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
<AllowHardTerminate>true</AllowHardTerminate>
<StartWhenAvailable>false</StartWhenAvailable>
<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
<IdleSettings>
<StopOnIdleEnd>true</StopOnIdleEnd>
<RestartOnIdle>false</RestartOnIdle>
</IdleSettings>
<AllowStartOnDemand>true</AllowStartOnDemand>
<Enabled>true</Enabled>
<Hidden>false</Hidden>
<RunOnlyIfIdle>false</RunOnlyIfIdle>
<WakeToRun>false</WakeToRun>
<ExecutionTimeLimit>P3D</ExecutionTimeLimit>
<Priority>7</Priority>
</Settings>
<Actions Context="Author">
<Exec>
<Command>"C:\Program Files\Git\usr\bin\sshd.exe"</Command>
</Exec>
</Actions>
</Task>
endsshd
startbashrc
export TEMP='C:\Windows\TEMP'
export TMP="$TEMP"
export PATH=/c/bin:$PATH
endbashrc

:end
endlocal
