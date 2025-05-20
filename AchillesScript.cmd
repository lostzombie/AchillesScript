::https://github.com/lostzombie/AchillesScript
@echo off
::#############################################################################
::set nobackup=1
::#############################################################################
cls&chcp 65001>nul 2>&1&color 0F
set "asv=ver 1.6.2"
set AS=Achilles
set "ifdef=if defined"
set "ifNdef=if not defined"
set "else=^|^|"
set "then=^&^&"
dir "%windir%\sysnative">nul 2>&1&&set "sysdir=%windir%\sysnative"||set "sysdir=%windir%\system32"
if "%sysdir%"=="X:\windows\system32" set "sys="
for %%i in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do (
    if exist "%%i:\Windows\System32" (
        set "sys=%%i"
        goto :SysFound
    )
)
:SysFound
set "sysdir=%sys%:\windows\system32"
set "cmd=%sysdir%\cmd.exe"
set "reg=%sysdir%\reg.exe"
set "ra=%reg% add"
set "rq=%reg% query"
set "rd=%reg% delete"
set "rs=%reg% save"
set "dw=REG_DWORD"
set "sz=REG_SZ"
set "bcdedit=%sysdir%\bcdedit.exe"
set "sc=%sysdir%\sc.exe"
set powershell="%sysdir%\WindowsPowerShell\v1.0\powershell.exe"
set "regsvr32=%sysdir%\regsvr32.exe"
set "whoami=%sysdir%\whoami.exe"
set "schtasks=%sysdir%\schtasks.exe"
set "shutdown=%sysdir%\shutdown.exe"
set "timeout=%sysdir%\timeout.exe"
set "reagentc=%sysdir%\reagentc.exe"
set "tk=%sysdir%\taskkill.exe"
set "gpupdate=%sysdir%\gpupdate.exe"
set "Script=%~dpnx0"
set ScriptPS=\"%~dpnx0\"
set ASR="HKLM\Software\%AS%Script"
set "pth=%~dp0"
%ifdef% save goto :SkipFindSave
%rq% %ASR% /v "Save" >nul 2>&1&&for /f "tokens=2*" %%a in ('%rq% %ASR% /v "Save" 2^>nul') do (set "save=%%b"&goto :SkipFindSave)
%ifNdef% save set "save=%pth%"
%ifNdef% usertemp set "usertemp=%tmp%"
set SaveDesktop=
if "%pth%"=="%tmp%\" set SaveDesktop=1
%ifNdef% save if "%pth%"=="%usertemp%\" set SaveDesktop=1
%ifdef% SaveDesktop for /f "tokens=2*" %%a in ('%rq% "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" 2^>nul') do set "save=%%b"
%ifdef% SaveDesktop for /f "tokens=*" %%a in ('echo %save%') do @set save=%%a
%ifdef% SaveDesktop if not exist "%save%" set "save=%USERPROFILE%\Desktop"
set "save=%save%\Achilles Backup\"
:SkipFindSave
set "arg1=%~1"
set "arg2=%~2"
shift
set "args=%*"
set "tiargs=%args:ti=%"
set "tiargs=%tiargs:~1%"
set "msg=call :2LangMsg"
set "err=call :2LangErr"
set "errn=call :2LangErrNoPause"
set L=ru
set isTrustedInstaller=
set UserSettingDone=
set BackUpDone=
::#############################################################################
set "dl=disable"
set "df=defend"
set "wd=Windows %df%er"
set "ss=SmartScreen"
set "cv=CurrentVersion"
set "scc=\SYSTEM\CurrentControlSet\Control"
set "smw=\Software\Microsoft\Windows"
set "spm=\SOFTWARE\Policies\Microsoft"
set "smwd=%smw% %df%er"
set "smwci=%smw% NT\%cv%\Image File Execution Options"
set "spmwd=%spm%\%wd%"
set "sccd=%scc%\DeviceGuard"
set "scs=\SYSTEM\CurrentControlSet\Services"
set "scl=\SOFTWARE\Classes"
set "uwpsearch=HKLM%scl%\Local Settings%smw%\%cv%\AppModel\PackageRepository\Packages"
set "regback=%save%Registry Backup"
::
(%rq% "HKCU\Control Panel\International\User Profile\%L%">nul 2>&1) %then% (set Lang=%L%) %else% ((%rq% "HKLM%scc%\Nls\Language" /v Default|find "0x409">nul 2>&1) %then% (set Lang=%L%))
%ifNdef% Lang (title %AS%' Script) else (title Ахилесов Скрипт)
::
%whoami% /groups | find "S-1-5-32-544" >nul 2>&1||%ifdef% Lang (echo Запустите этот файл из под учетной записи с правами администратора)&pause&exit else (echo Run this file under an account with administrator rights)&pause&exit
if not exist %powershell% %err% "Error %powershell% file not exist" "Ошибка файл %powershell% не найден"
call :CheckTrusted||%bcdedit% >nul 2>&1||(if AdminRestart==1 %err% "Error - bcdedit is broken or unable to get admin rights using powershell" "Ошибка - bcdedit поломан или невозможно получить права администратора с помощью powershell")
call :CheckTrusted||%bcdedit% >nul 2>&1||(set AdminRestart=1&%msg% "Requesting Administrator privileges..." "Запрос привилегий администратора..."&%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c Start-Process %cmd% -ArgumentList '/c', '%ScriptPS% %args%' -Verb RunAs&exit)
echo test>>"%pth%test.ps1"&&del /f /q "%pth%test.ps1"||(%err% "Testing write error in %pth%test.ps1" "Ошибка тестовой записи в %pth%test.ps1")
echo test>>"%pth%test.cmd"&&del /f /q "%pth%test.cmd"||(%err% "Testing write error in %pth%test.cmd" "Ошибка тестовой записи в %pth%test.cmd")
set REBOOT_PENDING=
%rq% "HKLM%smw%\%cv%\WindowsUpdate\Auto Update\RebootRequired" > nul 2>&1 && set REBOOT_PENDING=1
%rq% "HKLM%smw%\%cv%\Component Based Servicing\RebootPending" > nul 2>&1 && set REBOOT_PENDING=1
%ifNdef% arg1 %ifdef% REBOOT_PENDING %err% "Scheduled actions during reboot, reboot before using the script" "Запланированы действия во время перезагрузки, перед использованием скрипта перезагрузитесь"
%ifdef% arg1 %ifdef% REBOOT_PENDING %errn% "Scheduled actions during reboot, reboot before using the script" "Запланированы действия во время перезагрузки, перед использованием скрипта перезагрузитесь"
::Args
%ifdef% arg1 (
	for %%i in (apply multi restore block unblock ti backup safeboot winre sac uwpoff uwpon) do if [%arg1%]==[%%i] set "isValidArg=%%i"
	%ifNdef% isValidArg %errn% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	set  isValidArg=
)
(%rq% %ASR%>nul 2>&1) %then% (%rq% %ASR% /v "BackUpDone" 2>nul|find "1">nul 2>&1) %then% (set BackUpDone=1)>nul 2>&1
%rd% %ASR% /f >nul 2>&1
%ifNdef% arg1 if exist "%pth%hkcu.txt" del /f /q "%pth%hkcu.txt">nul 2>&1&set UserSettingDone=
if "%arg1%"=="apply" (
	%ifdef% arg2 for %%i in (1 2 3 4 6 policies setting services block) do if [%arg2%]==[%%i] set "isValidArg=%%i"
	%ifNdef% isValidArg %errn% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	%ifdef% arg2 for %%i in (1 2 3 4 6) do if [%arg2%]==[%%i] call :Menu%%i
	if [%arg2%]==[policies] set Policies=1
	if [%arg2%]==[setting]  set Registry=1
	if [%arg2%]==[services] set Services=1
	if [%arg2%]==[block]    set Block=1
	call :MAIN
)
if "%arg1%" neq "multi" goto :SkipMulti
	:multi
	set "multi=%~1"
	set isValidArg=
	%ifdef% multi for %%i in (policies setting services block) do if [%multi%]==[%%i] set "isValidArg=%%i"
	%ifNdef% isValidArg %errn% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	if [%isValidArg%]==[policies] set Policies=1
	if [%isValidArg%]==[setting]  set Registry=1
	if [%isValidArg%]==[services] set Services=1
	if [%isValidArg%]==[block]    set Block=1
	shift
	if [%~1] == [] call :MAIN
	goto :multi
:SkipMulti
if "%arg1%"=="restore" call :Menu6
if "%arg1%"=="block"   if "%arg2%" neq "" (call :BlockProcess %arg2%&exit /b)
if "%arg1%"=="unblock" if "%arg2%" neq "" (call :UnBlockProcess %arg2%&exit /b)
if "%arg1%"=="ti"      (call :TrustedRun "%tiargs%"&exit /b %errorlevel%)
if "%arg1%"=="backup"  (
	call :CheckTrusted||del /f /q "%save%MySecurityDefaults.reg">nul 2>&1
	call :CheckTrusted||rd /s /q "%regback%">nul 2>&1
	call :CheckTrusted||(call :Backup&set UserSettingDone=1)
	call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit)
	call :Backup
	exit /b
)
if "%arg1%"=="safeboot" call :Reboot2Safe only
if "%arg1%"=="winre"  call :WinRE&exit /b
if "%arg1%"=="sac"    call :SAC&exit /b
if "%arg1%"=="uwpoff" if "%arg2%" neq "" (call :BlockUWP %arg2%&exit /b)
if "%arg1%"=="uwpon"  if "%arg2%" neq "" (call :UnBlockUWP %arg2%&exit /b)
if "%arg1%" neq "" %err% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
::
%msg% "Determining the Windows version..." "Определение версии Windows..."
for /f "tokens=4 delims= " %%v in ('ver') do set "win=%%v"
for /f "tokens=3 delims=." %%v in ('echo  %win%') do set /a "build=%%v"
for /f "tokens=1 delims=." %%v in ('echo  %win%') do set /a "win=%%v"
for /f "tokens=4" %%a in ('ver') do set "WindowsBuild=%%a"
set "WindowsBuild=%WindowsBuild:~5,-1%"
if [%win%] lss [10] %ifdef% Lang (echo Этот скрипт разработан для Windows 10 и новее)&echo.&pause&exit else (echo This Script is designed for Windows 10 and newer)&echo.&pause&exit
for /f "tokens=2*" %%a in ('%rq% "HKLM%smw% NT\%cv%" /v ProductName') do set "WindowsVersion=%%b"
if [%build%] gtr [22000] set WindowsVersion=%WindowsVersion:10=11%
::#############################################################################
:BEGIN
set isValidItem=
set Item=
call :Screen
%ifNdef% Lang (set /p Item="Enter menu item number using your keyboard [0-6]:") else (set /p Item="Введите номер пункта меню используя клавиатуру [0-6]:")
for %%i in (1 2 3 4 5 6 0) do if [%Item%]==[%%i] set "isValidItem=%%i"
%ifNdef% isValidItem goto :BEGIN
if [%Item%] == [0] exit
call :Menu%Item%

:Menu1
set Policies=1
call :MAIN
:Menu2
set Registry=1
call :Menu1
:Menu3
set Services=1
call :Menu2
:Menu4
set Block=1
call :Menu3
:Menu5
cls
echo.
call :MiniHelp
goto :BEGIN
:Menu6
cls
%msg% "Restore defaults..." "Восстановление по умолчанию..."
%ifdef% Item set "args=apply %Item%"
call :CheckTrusted||call :RestoreCurrentUser
%sc% query wdFilter | find /i "RUNNING" >nul 2>&1 && %ifNdef% SAFEBOOT_OPTION call :Reboot2Safe
call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit)
call :Restore
call :Reboot2Normal
exit

:MAIN
%ifNdef% BackUpDone %ifNdef% UserSettingDone (
	cls
	%ifNdef% arg1 call :Warning
	%ifNdef% nobackup (call :CheckTrusted||call :Backup)
	"%ProgramFiles%\%wd%\MpCmdRun.exe" -RemoveDefinitions -All>nul 2>&1
	%ifdef% Policies (call :CheckTrusted||call :PoliciesHKCU)
	%ifdef% Registry (call :CheckTrusted||call :RegistryHKCU)
)
cls
%ifdef% Item set "args=apply %Item%"
%ifNdef% nobackup cls&call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit&cls)
%ifNdef% nobackup %ifNdef% BackUpDone call :Backup
call :BackUpDone
%ifNdef% SAFEBOOT_OPTION call :Reboot2Safe
cls&call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit&cls)
%ifdef% Policies call :Policies
%ifdef% Registry call :Registry
%ifdef% Services call :Services
%ifdef%    Block call :Block
call :Reboot2Normal
::#############################################################################
:2LangMsg
%ifdef% Lang (echo %~2) else (echo %~1)
exit /b
:2LangErr
(%ifdef% Lang (echo %~2) else (echo %~1))&pause>nul 2>&1&exit

:2LangErrNoPause
(%ifdef% Lang (echo %~2) else (echo %~1))&exit /b 1

:CheckTrusted
%whoami% /GROUPS|find "TrustedInstaller">nul 2>&1&&exit /b 0||exit /b 1

:Warning
cls
echo.
if exist "%save%MySecurityDefaults.reg" (
%msg% "MySecurityDefaults.reg is detected, the backup of the current settings will be skipped." "Обнаружен MySecurityDefaults.reg, будет пропущен бэкап текущих настроек."
%msg% "Delete MySecurityDefaults.reg and restart the script if you want to create a new backup." "Удалите MySecurityDefaults.reg и перезапустите скрипт если хотите создать новый бэкап."
echo.
)
if exist "%save%MySecurityDefaults.reg" echo "%save%MySecurityDefaults.reg"&echo.
%ifdef% Policies (
%msg% "Group policies will be applied to %dl% " "Будут применены групповые политики для отключения "
%msg% "%wd%, %ss%, Kernel Isolation, SmartAppControl etc." "Защитника Windows, %ss%, Изоляции ядра, Интелектуального управления приложениями"
if exist "%sysdir%\MRT.exe" %msg% "%dl% updating and reporting for Malicious Software Removal Tool." "Отключено обновление и отчеты средства удаления вредоносных программ."
echo.
)
%ifdef% Registry (
%msg% "Registry settings will be applied to %dl%" "Будут применены настройки реестра для отключения"
%msg% "tasks in the scheduler, warnings for downloaded files, file explorer extensions" "задач в планировщике, предупреждения для скачанных файлов, расширения проводника"
echo.
)
%ifdef% Services %msg% "The launch of %df%er services and drivers will be %dl%d." "Будет отключен запуск служб и драйверов защитника."&echo.
%ifdef%    Block %msg% "The launch of %df%er executable files will be blocked." "Будет заблокирован запуск исполняемых файлов защитника."&echo.
%ifNdef% SAFEBOOT_OPTION %msg% "[93mThe computer will be restarted [91mtwice[93m, to [91msafe mode[93m and back.[0m" "[93mКомпьютер будет перезагружен [91mдважды[93m, в [91mбезопасный режим[93m и обратно.[0m"
%ifdef% SAFEBOOT_OPTION %msg% "[93mThe computer will be restarted.[0m" "[93mКомпьютер будет перезагружен.[0m"
echo.
%ifNdef% Lang (choice /m "You really want to %dl% Windows defences" /c "yn") else (choice /m "Вы действительно хотите отключить защиты Windows?" /c "дн")
if [%errorlevel%]==[2] goto :BEGIN
cls
exit /b

:Reboot2Safe
set "only=%~1"
%reg% copy "HKLM%scc%\SafeBoot\Minimal\Win%df%" "HKLM%scc%\SafeBoot\Minimal\Win%df%_off" /s /f>nul 2>&1
%rd% "HKLM%scc%\SafeBoot\Minimal\Win%df%" /f>nul 2>&1
set "BootArgs=%args%"
%ifdef% Item set "BootArgs=apply %Item%"
%tk% /im mmc.exe /t /f>nul 2>&1
%sc% delete %AS%Service>nul 2>&1
%sc% create %AS%Service type= own start= auto error= ignore obj= "LocalSystem" binPath= "cmd.exe /c start \"\" \"%pth%%AS%Boot.cmd\"">nul 2>&1
set "EventLog="
for /f "tokens=2*" %%a in ('%rq% "HKLM%scc%\WMI\Autologger\EventLog-System\{555908d1-a6d7-4695-8e1e-26931d2012f4}" /v "Enabled" 2^>nul') do set "EventLog=%%b"
if [%EventLog%]==[0x1] %ra% "HKLM%scc%\WMI\Autologger\EventLog-System\{555908d1-a6d7-4695-8e1e-26931d2012f4}" /v Enabled /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%scc%\SafeBoot\Minimal\%AS%Service" /ve /t REG_SZ /d "Service" /f>nul 2>&1
%ifNdef% only %ra% "HKLM%smw%\%cv%\RunOnce" /v "*Wait" /t %sz% /d "cmd.exe /k title WAIT&echo WAIT...&if exist \"%pth%%AS%Boot.cmd\" (call \"%pth%%AS%Boot.cmd\"&exit)" /f >nul 2>&1
%ifNdef% only %ra% %ASR% /v "Save" /t %sz% /d "%save%\" /f >nul 2>&1
call :SafeBoot %only%
%msg% "The computer will now reboot into safe mode." "Компьютер сейчас перезагрузиться в безопасный режим."
%shutdown% /r /f /t 3 /c "Reboot Safe Mode" 
%timeout% /t 4
exit

:SafeBoot
set "only=%~1"
del /f /q "%pth%%AS%Boot.cmd">nul 2>&1
set win%df%=
(%rq% "HKLM%scc%\SafeBoot\Minimal\Win%df%">nul 2>&1) %then% (set win%df%=1)
set boottimeout=30
set displaybootmenu=
for /f "tokens=2" %%t in ('%bcdedit% /enum {bootmgr} ^| find "timeout"') do set "boottimeout=%%t"
for /f "tokens=2" %%t in ('%bcdedit% /enum {bootmgr} ^| find "displaybootmenu"') do set "displaybootmenu=%%t"
for /f "tokens=2" %%t in ('%bcdedit% /v ^| find "default"') do set "default=%%t"
for /f "tokens=2 delims={}" %%a in ('%bcdedit% /copy {current} /d "Safe Mode" ^| find "{"') do set guid=%%a
%bcdedit% /timeout "2" >nul 2>&1
%bcdedit% /set {bootmgr} displaybootmenu Yes>nul 2>&1
%bcdedit% /set {%guid%} safeboot minimal>nul 2>&1
%bcdedit% /set {%guid%} bootmenupolicy Legacy>nul 2>&1
%bcdedit% /set {%guid%} hypervisorlaunchtype off>nul 2>&1
%bcdedit% /default {%guid%}>nul 2>&1
echo chcp 65001>"%pth%%AS%Boot.cmd"
echo bcdedit /timeout "%boottimeout%" >>"%pth%%AS%Boot.cmd"
%ifdef% displaybootmenu echo bcdedit /set {bootmgr} displaybootmenu %displaybootmenu% >>"%pth%%AS%Boot.cmd"
%ifNdef% displaybootmenu echo bcdedit /deletevalue {bootmgr} displaybootmenu >>"%pth%%AS%Boot.cmd"
%ifdef% default echo bcdedit /default %default% >>"%pth%%AS%Boot.cmd"
echo bcdedit /delete {%guid%}>>"%pth%%AS%Boot.cmd"
echo reg delete "HKLM%scs%\%AS%Service" /f>>"%pth%%AS%Boot.cmd"
echo reg delete "HKLM%scc%\SafeBoot\Minimal\%AS%Service" /f>>"%pth%%AS%Boot.cmd"
%ifdef% win%df% (
	%reg% copy "HKLM%scc%\SafeBoot\Minimal\Win%df%" "HKLM%scc%\SafeBoot\Minimal\Win%df%_off" /s /f>nul 2>&1
	%rd% "HKLM%scc%\SafeBoot\MinimalMinimal\Win%df%" /f>nul 2>&1
	echo reg copy "HKLM%scc%\SafeBoot\Minimal\Win%df%_off" "HKLM%scc%\SafeBoot\Minimal\Win%df%" /s /f>>"%pth%%AS%Boot.cmd"
	echo reg delete "HKLM%scc%\SafeBoot\Minimal\Win%df%_off" /f>>"%pth%%AS%Boot.cmd"
)
if [%EventLog%]==[0x1] echo reg add "HKLM%scc%\WMI\Autologger\EventLog-System\{555908d1-a6d7-4695-8e1e-26931d2012f4}" /v Enabled /t %dw% /d 1 /f >>"%pth%%AS%Boot.cmd"
%ifNdef% only echo if defined SAFEBOOT_OPTION start ^"^" ^"%Script%^" %BootArgs% >>"%pth%%AS%Boot.cmd"
echo del /f /q ^"%pth%%AS%Boot.cmd^" >>"%pth%%AS%Boot.cmd"
exit /b

:Reboot2Normal
%msg% "The computer will now reboot into default mode." "Компьютер сейчас перезагрузиться в обычный режим."
%rd% "HKLM%smw%\%cv%\RunOnce" /v "*Wait" /f >nul 2>&1
%rd% %ASR% /f >nul 2>&1
%ifdef% SAFEBOOT_OPTION %shutdown% /r /f /t 0
%ifNdef% SAFEBOOT_OPTION %shutdown% /r /f /t 3 /c "Reboot"
%timeout% /t 4
exit

:TrustedRun
%msg% "Getting Trusted Installer privileges..." "Получение привилегий Trusted Installer..."
%sc% config "TrustedInstaller" start= demand>nul 2>&1
%sc% start "TrustedInstaller">nul 2>&1
del /f /q "%pth%%AS%TI.ps1">nul 2>&1
set "RunAsTrustedInstaller=%~1"
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$null|Out-File -FilePath '%pth%%AS%TI.ps1' -Encoding UTF8">nul 2>&1
echo $AppFullPath=[System.Environment]::GetEnvironmentVariable('RunAsTrustedInstaller')>>"%pth%%AS%TI.ps1"
echo [string]$GetTokenAPI=@'>>"%pth%%AS%TI.ps1"
echo using System;using System.ServiceProcess;using System.Diagnostics;using System.Runtime.InteropServices;using System.Security.Principal;namespace WinAPI{internal static class WinBase{[StructLayout(LayoutKind.Sequential)]internal struct SECURITY_ATTRIBUTES{public int nLength;public IntPtr lpSecurityDeScriptor;public bool bInheritHandle;}[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]internal struct STARTUPINFO{public Int32 cb;public string lpReserved;public string lpDesktop;public string lpTitle;public uint dwX;public uint dwY;public uint dwXSize;public uint dwYSize;public uint dwXCountChars;public uint dwYCountChars;public uint dwFillAttribute;public uint dwFlags;public Int16 wShowWindow;public Int16 cbReserved2;public IntPtr lpReserved2;public IntPtr hStdInput;public IntPtr hStdOutput;public IntPtr hStdError;}[StructLayout(LayoutKind.Sequential)]internal struct PROCESS_INFORMATION{public IntPtr hProcess;public IntPtr hThread;public uint dwProcessId;public uint dwThreadId;}}internal static class WinNT{public enum TOKEN_TYPE{TokenPrimary=1,TokenImpersonation}public enum SECURITY_IMPERSONATION_LEVEL{SecurityAnonymous,SecurityIdentification,SecurityImpersonation,SecurityDelegation}[StructLayout(LayoutKind.Sequential,Pack=1)]internal struct TokPriv1Luid{public uint PrivilegeCount;public long Luid;public UInt32 Attributes;}}internal static class Advapi32{public const int SE_PRIVILEGE_ENABLED=0x00000002;public const uint CREATE_NO_WINDOW=0x08000000;public const uint CREATE_NEW_CONSOLE=0x00000010;public const uint CREATE_UNICODE_ENVIRONMENT=0x00000400;public const UInt32 STANDARD_RIGHTS_REQUIRED=0x000F0000;public const UInt32 STANDARD_RIGHTS_READ=0x00020000;public const UInt32 TOKEN_ASSIGN_PRIMARY=0x0001;public const UInt32 TOKEN_DUPLICATE=0x0002;public const UInt32 TOKEN_IMPERSONATE=0x0004;public const UInt32 TOKEN_QUERY=0x0008;public const UInt32 TOKEN_QUERY_SOURCE=0x0010;public const UInt32 TOKEN_ADJUST_PRIVILEGES=0x0020;public const UInt32 TOKEN_ADJUST_GROUPS=0x0040;public const UInt32 TOKEN_ADJUST_DEFAULT=0x0080;public const UInt32 TOKEN_ADJUST_SESSIONID=0x0100;public const UInt32 TOKEN_READ=(STANDARD_RIGHTS_READ^|TOKEN_QUERY);public const UInt32 TOKEN_ALL_ACCESS=(STANDARD_RIGHTS_REQUIRED^|TOKEN_ASSIGN_PRIMARY^|TOKEN_DUPLICATE^|TOKEN_IMPERSONATE^|TOKEN_QUERY^|TOKEN_QUERY_SOURCE^|TOKEN_ADJUST_PRIVILEGES^|TOKEN_ADJUST_GROUPS^|TOKEN_ADJUST_DEFAULT^|TOKEN_ADJUST_SESSIONID);[DllImport("advapi32.dll",SetLastError=true)][return:MarshalAs(UnmanagedType.Bool)]public static extern bool OpenProcessToken(IntPtr ProcessHandle,UInt32 DesiredAccess,out IntPtr TokenHandle);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public extern static bool DuplicateTokenEx(IntPtr hExistingToken,uint dwDesiredAccess,IntPtr lpTokenAttributes,WinNT.SECURITY_IMPERSONATION_LEVEL ImpersonationLevel,WinNT.TOKEN_TYPE TokenType,out IntPtr phNewToken);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]internal static extern bool LookupPrivilegeValue(string lpSystemName,string lpName,ref long lpLuid);[DllImport("advapi32.dll",SetLastError=true)]internal static extern bool AdjustTokenPrivileges(IntPtr TokenHandle,bool %dl%AllPrivileges,ref WinNT.TokPriv1Luid NewState,UInt32 Zero,IntPtr Null1,IntPtr Null2);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Unicode)]public static extern bool CreateProcessAsUserW(IntPtr hToken,string lpApplicationName,string lpCommandLine,IntPtr lpProcessAttributes,IntPtr lpThreadAttributes,bool bInheritHandles,uint dwCreationFlags,IntPtr lpEnvironment,string lpCurrentDirectory,ref WinBase.STARTUPINFO lpStartupInfo,out WinBase.PROCESS_INFORMATION lpProcessInformation);[DllImport("advapi32.dll",SetLastError=true)]public static extern bool SetTokenInformation(IntPtr TokenHandle,uint TokenInformationClass,ref IntPtr TokenInformation,int TokenInformationLength);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public static extern bool RevertToSelf();}internal static class Kernel32{[Flags]public enum ProcessAccessFlags:uint{All=0x001F0FFF}[DllImport("kernel32.dll",SetLastError=true)]>>"%pth%%AS%TI.ps1"
echo public static extern IntPtr OpenProcess(ProcessAccessFlags processAccess,bool bInheritHandle,int processId);[DllImport("kernel32.dll",SetLastError=true)]public static extern bool CloseHandle(IntPtr hObject);}internal static class Userenv{[DllImport("userenv.dll",SetLastError=true)]public static extern bool CreateEnvironmentBlock(ref IntPtr lpEnvironment,IntPtr hToken,bool bInherit);}public static class ProcessConfig{public static IntPtr DuplicateTokenSYS(IntPtr hTokenSys){IntPtr hProcess=IntPtr.Zero,hToken=IntPtr.Zero,hTokenDup=IntPtr.Zero;int pid=0;string name;bool bSuccess,impersonate=false;try{if(hTokenSys==IntPtr.Zero){bSuccess=RevertToRealSelf();name=System.Text.Encoding.UTF8.GetString(new byte[]{87,73,78,76,79,71,79,78});}else{name=System.Text.Encoding.UTF8.GetString(new byte[]{84,82,85,83,84,69,68,73,78,83,84,65,76,76,69,82});ServiceController controlTI=new ServiceController(name);if(controlTI.Status==ServiceControllerStatus.Stopped){controlTI.Start();System.Threading.Thread.Sleep(5);controlTI.Close();}impersonate=ImpersonateWithToken(hTokenSys);if(!impersonate){return IntPtr.Zero;}}IntPtr curSessionId=new IntPtr(Process.GetCurrentProcess().SessionId);Process process=Array.Find(Process.GetProcessesByName(name),p=^>p.Id^>0);if(process!=null){pid=process.Id;}else{return IntPtr.Zero;}hProcess=Kernel32.OpenProcess(Kernel32.ProcessAccessFlags.All,true,pid);uint DesiredAccess=Advapi32.TOKEN_QUERY^|Advapi32.TOKEN_DUPLICATE^|Advapi32.TOKEN_ASSIGN_PRIMARY;bSuccess=Advapi32.OpenProcessToken(hProcess,DesiredAccess,out hToken);if(!bSuccess){return IntPtr.Zero;}DesiredAccess=Advapi32.TOKEN_ALL_ACCESS;bSuccess=Advapi32.DuplicateTokenEx(hToken,DesiredAccess,IntPtr.Zero,WinNT.SECURITY_IMPERSONATION_LEVEL.SecurityDelegation,WinNT.TOKEN_TYPE.TokenPrimary,out hTokenDup);if(!bSuccess){bSuccess=Advapi32.DuplicateTokenEx(hToken,DesiredAccess,IntPtr.Zero,WinNT.SECURITY_IMPERSONATION_LEVEL.SecurityImpersonation,WinNT.TOKEN_TYPE.TokenPrimary,out hTokenDup);}if(bSuccess){bSuccess=EnableAllPrivilages(hTokenDup);}if(!impersonate){hTokenSys=hTokenDup;impersonate=ImpersonateWithToken(hTokenSys);}if(impersonate){bSuccess=Advapi32.SetTokenInformation(hTokenDup,12,ref curSessionId,4);}}catch(Exception){}finally{if(hProcess!=IntPtr.Zero){Kernel32.CloseHandle(hProcess);}if(hToken!=IntPtr.Zero){Kernel32.CloseHandle(hToken);}bSuccess=RevertToRealSelf();}if(hTokenDup!=IntPtr.Zero){return hTokenDup;}else{return IntPtr.Zero;}}public static bool RevertToRealSelf(){try{Advapi32.RevertToSelf();WindowsImpersonationContext currentImpersonate=WindowsIdentity.GetCurrent().Impersonate();currentImpersonate.Undo();currentImpersonate.Dispose();}catch(Exception){return false;}return true;}public static bool ImpersonateWithToken(IntPtr hTokenSys){try{WindowsImpersonationContext ImpersonateSys=new WindowsIdentity(hTokenSys).Impersonate();}catch(Exception){return false;}return true;}private enum PrivilegeNames{SeAssignPrimaryTokenPrivilege,SeBackupPrivilege,SeIncreaseQuotaPrivilege,SeLoadDriverPrivilege,SeManageVolumePrivilege,SeRestorePrivilege,SeSecurityPrivilege,SeShutdownPrivilege,SeSystemEnvironmentPrivilege,SeSystemTimePrivilege,SeTakeOwnershipPrivilege,SeTrustedCredmanAccessPrivilege,SeUndockPrivilege};private static bool EnableAllPrivilages(IntPtr hTokenSys){WinNT.TokPriv1Luid tp;tp.PrivilegeCount=1;tp.Luid=0;tp.Attributes=Advapi32.SE_PRIVILEGE_ENABLED;bool bSuccess=false;try{foreach(string privilege in Enum.GetNames(typeof(PrivilegeNames))){bSuccess=Advapi32.LookupPrivilegeValue(null,privilege,ref tp.Luid);bSuccess=Advapi32.AdjustTokenPrivileges(hTokenSys,false,ref tp,0,IntPtr.Zero,IntPtr.Zero);}}catch(Exception){return false;}return bSuccess;}public static StructOut CreateProcessWithTokenSys(IntPtr hTokenSys,string AppPath){uint exitCode=0;bool bSuccess;bool bInherit=false;string stdOutString="";IntPtr hReadOut=IntPtr.Zero,hWriteOut=IntPtr.Zero;const uint HANDLE_FLAG_INHERIT=0x00000001;const uint STARTF_USESTDHANDLES=0x00000100;const UInt32 INFINITE=0xFFFFFFFF;IntPtr NewEnvironment=IntPtr.Zero;bSuccess=Userenv.CreateEnvironmentBlock(ref NewEnvironment,hTokenSys,true);uint CreationFlags=Advapi32.CREATE_UNICODE_ENVIRONMENT^|Advapi32.CREATE_NEW_CONSOLE;WinBase.PROCESS_INFORMATION pi=new WinBase.PROCESS_INFORMATION();WinBase.STARTUPINFO si=new WinBase.STARTUPINFO();si.cb=Marshal.SizeOf(si);si.lpDesktop="winsta0\\default";try{bSuccess=ImpersonateWithToken(hTokenSys);bSuccess=Advapi32.CreateProcessAsUserW(hTokenSys,null,AppPath,IntPtr.Zero,IntPtr.Zero,bInherit,(uint)CreationFlags,NewEnvironment,null,ref si,out pi);if(!bSuccess){exitCode=1;}}catch(Exception){}finally{if(pi.hProcess!=IntPtr.Zero){Kernel32.CloseHandle(pi.hProcess);}if(pi.hThread!=IntPtr.Zero){Kernel32.CloseHandle(pi.hThread);}bSuccess=RevertToRealSelf();}StructOut so=new StructOut();so.ProcessId=pi.dwProcessId;so.ExitCode=exitCode;so.StdOut=stdOutString;return so;}[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]public struct StructOut{public uint ProcessId;public uint ExitCode;public string StdOut;}}}>>"%pth%%AS%TI.ps1"
echo '@>>"%pth%%AS%TI.ps1"
echo if (-not ('WinAPI.ProcessConfig' -as [type] )){$cp=[System.CodeDom.Compiler.CompilerParameters]::new(@('System.dll','System.ServiceProcess.dll'))>>"%pth%%AS%TI.ps1"
echo $cp.TempFiles=[System.CodeDom.Compiler.TempFileCollection]::new($DismScratchDirGlobal,$false)>>"%pth%%AS%TI.ps1"
echo $cp.GenerateInMemory=$true>>"%pth%%AS%TI.ps1"
echo $cp.CompilerOptions='/platform:anycpu /nologo'>>"%pth%%AS%TI.ps1"
echo Add-Type -TypeDefinition $GetTokenAPI -Language CSharp -ErrorAction Stop -CompilerParameters $cp}>>"%pth%%AS%TI.ps1"
echo $Global:Token_SYS=[WinAPI.ProcessConfig]::DuplicateTokenSYS([System.IntPtr]::Zero)>>"%pth%%AS%TI.ps1"
echo if ($Global:Token_SYS -eq [IntPtr]::Zero ){$Exit=$true; Return}>>"%pth%%AS%TI.ps1"
echo $Global:Token_TI=[WinAPI.ProcessConfig]::DuplicateTokenSYS($Global:Token_SYS)>>"%pth%%AS%TI.ps1"
echo if ($Global:Token_TI -eq [IntPtr]::Zero ){$Exit=$true; Return}>>"%pth%%AS%TI.ps1"
echo [WinAPI.ProcessConfig+StructOut] $StructOut=New-Object -TypeName WinAPI.ProcessConfig+StructOut>>"%pth%%AS%TI.ps1"
echo $StructOut=[WinAPI.ProcessConfig]::CreateProcessWithTokenSys($Global:Token_TI, $AppFullPath)>>"%pth%%AS%TI.ps1"
echo return $StructOut.ExitCode>>"%pth%%AS%TI.ps1"
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f "%pth%%AS%TI.ps1"
set "trusted=%errorlevel%">nul 2>&1
del /f /q "%pth%%AS%TI.ps1">nul 2>&1
exit /b %trusted%

:Backup
if exist "%save%MySecurityDefaults.reg" goto :EndBackup
call :CheckTrusted&&goto :TrustedBackup
%ifdef% UserSettingDone goto :EndBackup
%msg% "Creating a recovery point if recovery is enabled..." "Создание точки восстановления, если восстановление включено..."
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Checkpoint-Computer -DeScription '%AS% Script Backup %date% %time%' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue"&&echo OK||%msg% "Skip" "Пропуск"
call :RegSave
%msg% "Backup security settings from the HKCU registry key..." "Бэкап настроек безопасности из раздела реестра HKCU..."
call :HKCU_List
call :BackupReg "hkcu.list" "hkcu.txt"
del /f/q "%pth%hkcu.list">nul 2>&1
goto :EndBackup
:TrustedBackup
call :RegSave
%msg% "Backup settings from the HKLM registry key..." "Бэкап настроек из раздела реестра HKLM..."
call :HKLM_List
call :BackupReg "hklm.list" "hklm.txt"
del /f/q "%pth%hklm.list">nul 2>&1
if exist "%pth%hkcu.txt" copy /b "%pth%hkcu.txt"+"%pth%hklm.txt" "%save%MySecurityDefaults.reg">nul 2>&1
if not exist "%pth%hkcu.txt" move /y "%pth%hklm.txt" "%save%MySecurityDefaults.reg">nul 2>&1
del /f/q "%pth%hkcu.txt">nul 2>&1
del /f/q "%pth%hklm.txt">nul 2>&1
echo "%save%MySecurityDefaults.reg"
:EndBackup
exit /b

:RegSave
if exist "%regback%\SOFTWARE" if exist "%regback%\SOFTWARE" goto :SkipRegSave
%msg% "Creating a complete copy of the registry in %regback%" "Создание полной копии реестра в %regback%"
if not exist "%regback%" md "%regback%">nul 2>&1
%msg% "Creating full copy of HKLM\SOFTWARE in %regback%" "Создание полной копии HKLM\SOFTWARE"
%rs% HKLM\SOFTWARE "%regback%\SOFTWARE" /y>nul 2>&1
%msg% "Creating full copy of HKLM\SYSTEM in %regback%" "Создание полной копии HKLM\SYSTEM"
%rs% HKLM\SYSTEM "%regback%\SYSTEM" /y>nul 2>&1
:SkipRegSave
exit /b

:BackupReg
set out="%pth%%AS%Backup.ps1"
del /f/q %out%>nul 2>&1
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "$null|Out-File -FilePath '%out%' -Encoding UTF8">nul 2>&1
echo $I="%pth%%~1">>%out%
echo $F="%pth%%~2">>%out%
echo $O=New-Object System.Text.StringBuilder>>%out%
echo if($F -ne "%pth%hklm.txt"){$O.AppendLine("Windows Registry Editor Version 5.00")^|Out-Null}>>%out%
echo if($F -eq "%pth%hklm.txt"){if(![System.IO.File]::Exists("%pth%hkcu.txt")){$O.AppendLine("Windows Registry Editor Version 5.00")^|Out-Null}}>>%out%
echo $O.AppendLine("")^|Out-Null>>%out%
echo Get-Content -Path $I^|ForEach-Object{$l=$_.Trim()>>%out%
echo if($l -eq ""){return}>>%out%
echo $t=$l -split ",">>%out%
echo $P=$t[0]>>%out%
echo $K=if($t.Count -gt 1){$t[1]}else{""}>>%out%
echo $S=$P -replace "HKCU:","HKEY_CURRENT_USER" -replace "HKLM:","HKEY_LOCAL_MACHINE">>%out%
echo if(Test-Path -Path $P){$O.AppendLine("[$S]")^|Out-Null>>%out%
echo if($K -eq ""){Get-ItemProperty -Path $P^|Select-Object -Property *^|ForEach-Object{>>%out%
echo $_.PSObject.Properties^|Where-Object{$_.Name -notmatch '^^PS'}^|ForEach-Object{>>%out%
echo if ($($_.Name) -eq "(default)"){$O.AppendLine("@=""$($_.Value)""")^|Out-Null}>>%out%
echo else {$O.AppendLine("""$($_.Name)""=""$($_.Value)""")^|Out-Null}}}}>>%out%
echo else{$C=(Get-ItemProperty -Path $P -ErrorAction SilentlyContinue).PSObject.Properties.Name>>%out%
echo if($C -contains $K){$V=(Get-ItemProperty -Path $P -Name $K -ErrorAction SilentlyContinue).$K>>%out%
echo $ln=$V.Length>>%out%
echo if($ln -eq 0){if($K -eq "Start"){$O.AppendLine("""$K""=dword:$("{0:X8}" -f $V)")^|Out-Null}>>%out%
echo else{$O.AppendLine("""$K""=""""")^|Out-Null}}>>%out%
echo else{if($V -is [int]){$O.AppendLine("""$K""=dword:$("{0:X8}" -f $V)")^|Out-Null}>>%out%
echo elseif ($V -is [byte[]]) {>>%out%
echo $bin=($V ^| ForEach-Object {"{0:X2}" -f $_ }) -join ",">>%out%
echo $O.AppendLine("""$K""=hex:$bin")^|Out-Null}>>%out%
echo else{$O.AppendLine("""$K""=""$V""")^|Out-Null}}}>>%out%
echo else{$O.AppendLine("""$K""=-")^|Out-Null}}>>%out%
echo $O.AppendLine("")^|Out-Null}>>%out%
echo else{if(-not $O.ToString().Contains("[-$S]")){$O.AppendLine("[-$S]")^|Out-Null>>%out%
echo $O.AppendLine("")^|Out-Null}}}>>%out%
echo $O.ToString()^|Set-Content -Path $F -Encoding Unicode>>%out%
%powershell% -MTA -NoP -NoL -NonI -EP Bypass -f %out%>nul 2>&1
del /f/q %out%>nul 2>&1
exit /b

:Screen
cls
			   echo [36m┌──────────────────────────────────────────┐[0m
			   echo [36m│[96m ┌─┐┌─┐┬ ┬┬┬  ┬  ┌─┐┌─┐┐ ┌─┐┌─┐┬─┐┬┌─┐┌┬┐[0m [36m│[0m
               echo [36m│[96m ├─┤│  ├─┤││  │  ├┤ └─┐  └─┐│  ├┬┘│├─┘ │ [0m [36m│[0m
               echo [36m│[96m ┴ ┴└─┴┴ ┴┴┴─┘┴─┘└─┘└─┘  └─┘└─┘┴└─┴┴   ┴ [0m [36m│[0m
			   echo [36m└──────────────────────────────────────────┘[0m
%ifNdef% Lang  (echo [96m to disable Windows Defender and Security[0m
) else (
               echo [96m отключение Защитника Windows и Безопасности[0m
)
echo.
               echo  [36m%asv%[0m  
echo.
               echo  [4;93m%WindowsVersion% build %WindowsBuild%[0m
echo.
%msg% " [92m[1][0m Group Policies"                                                                   " [92m[1][0m Групповые политики"
%msg% " [92m[2][0m Policies + Registry Settings"                                                     " [92m[2][0m Политики + Настройки реестра"
%msg% " [92m[3][0m Policies + Settings + Disabling Services and drivers"                             " [92m[3][0m Политики + Настройки + Отключение служб и драйверов"
%msg% " [92m[4][0m Policies + Settings + Disabling Services and drivers + Block launch executables"  " [92m[4][0m Политики + Настройки + Отключение служб и драйверов + Блокировка запуска"
%msg% "[36m─────────────────────────────────────────────────────────────────────────────────────[0m" "[36m─────────────────────────────────────────────────────────────────────────────[0m"
%msg% " [93m[5][0m Help"                                                                             " [93m[5][0m Помощь"
%msg% " [93m[6][0m Restore Defaults"                                                                 " [93m[6][0m Восстановить по умолчанию"
%msg% " [93m[0][0m Exit"                                                                             " [93m[0][0m Выход"
echo.
exit /b

:HKCU_List
del /f/q "%pth%hkcu.list">nul 2>&1
echo HKCU:%smw% Security Health\State,AppAndBrowser_Edge%ss%Off>"%pth%hkcu.list"
echo HKCU:%smw% Security Health\State,AppAndBrowser_Pua%ss%Off>>"%pth%hkcu.list"
echo HKCU:%smw% Security Health\State,AppAndBrowser_StoreApps%ss%Off>>"%pth%hkcu.list"
echo HKCU:%smw%\%cv%\AppHost,EnableWebContentEvaluation>>"%pth%hkcu.list"
echo HKCU:%smw%\%cv%\AppHost,PreventOverride>>"%pth%hkcu.list"
echo HKCU:%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,Enabled>>"%pth%hkcu.list"
echo HKCU:%smw%\%cv%\Policies\Attachments,SaveZoneInformation>>"%pth%hkcu.list"
echo HKCU:%smw%\%cv%\Policies\Attachments,HideZoneInfoOnProperties>>"%pth%hkcu.list"
echo HKCU:%smw%\%cv%\Policies\Attachments,ScanWithAntiVirus>>"%pth%hkcu.list"
echo HKCU:%spm%\Edge,%ss%Enabled>>"%pth%hkcu.list"
echo HKCU:%spm%\Edge,%ss%PuaEnabled>>"%pth%hkcu.list"
echo HKLM:%scc%\SafeBoot\Minimal\Win%df%>>"%pth%hkcu.list"
echo HKLM:%scc%\SafeBoot\Minimal\Win%df%_off>>"%pth%hkcu.list"
call :ListUWP sechealth
call :ListUWP chxapp
exit /b

:HKLM_List
del /f/q "%pth%hklm.list">nul 2>&1
echo HKLM:%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>"%pth%hklm.list"
echo HKLM:%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32>>"%pth%hklm.list"
echo HKLM:%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32>>"%pth%hklm.list"
echo HKLM:%scl%\exefile\shell\open,No%ss%>>"%pth%hklm.list"
echo HKLM:%scl%\exefile\shell\runas,No%ss%>>"%pth%hklm.list"
echo HKLM:%scl%\exefile\shell\runasuser,No%ss%>>"%pth%hklm.list"
echo HKLM:%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%pth%hklm.list"
echo HKLM:%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32>>"%pth%hklm.list"
echo HKLM:%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32>>"%pth%hklm.list"
echo HKLM:%scl%\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}>>"%pth%hklm.list"
echo HKLM:%scl%\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0>>"%pth%hklm.list"
echo HKLM:%scl%\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\0>>"%pth%hklm.list"
echo HKLM:%scl%\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\0\win64>>"%pth%hklm.list"
echo HKLM:%scl%\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\FLAGS>>"%pth%hklm.list"
echo HKLM:%scl%\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\HELPDIR>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\RemovalTools\MpGears,HeartbeatTrackingIndex>>"%pth%hklm.list"
echo HKLM:%smwd% Security Center\Device security,UILockdown>>"%pth%hklm.list"
echo HKLM:%smwd% Security Center\Notifications,%dl%EnhancedNotifications>>"%pth%hklm.list"
echo HKLM:%smwd% Security Center\Virus and threat protection,FilesBlockedNotification%dl%d>>"%pth%hklm.list"
echo HKLM:%smwd% Security Center\Virus and threat protection,NoActionNotification%dl%d>>"%pth%hklm.list"
echo HKLM:%smwd% Security Center\Virus and threat protection,SummaryNotification%dl%d>>"%pth%hklm.list"
echo HKLM:%smwd%,%dl%AntiSpyware>>"%pth%hklm.list"
echo HKLM:%smwd%,%dl%AntiVirus>>"%pth%hklm.list"
echo HKLM:%smwd%,HybridModeEnabled>>"%pth%hklm.list"
echo HKLM:%smwd%,IsServiceRunning>>"%pth%hklm.list"
echo HKLM:%smwd%,ProductStatus>>"%pth%hklm.list"
echo HKLM:%smwd%,ProductType>>"%pth%hklm.list"
echo HKLM:%smwd%,PUAProtection>>"%pth%hklm.list"
echo HKLM:%smwd%,SmartLockerMode>>"%pth%hklm.list"
echo HKLM:%smwd%,VerifiedAndReputableTrustModeEnabled>>"%pth%hklm.list"
echo HKLM:%smwd%\CoreService,%dl%CoreService1DSTelemetry>>"%pth%hklm.list"
echo HKLM:%smwd%\CoreService,%dl%CoreServiceECSIntegration>>"%pth%hklm.list"
echo HKLM:%smwd%\CoreService,Md%dl%ResController>>"%pth%hklm.list"
echo HKLM:%smwd%\Features,EnableCACS>>"%pth%hklm.list"
echo HKLM:%smwd%\Features,Protection>>"%pth%hklm.list"
echo HKLM:%smwd%\Features,TamperProtection>>"%pth%hklm.list"
echo HKLM:%smwd%\Features,TamperProtectionSource>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,EnableAdsSymlinkMitigation_MpRamp>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,EnableBmProcessInfoMetastoreMaintenance_MpRamp>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,EnableCIWorkaroundOnCFAEnabled_MpRamp>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,Md%dl%ResController>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,Mp%dl%PropBagNotification>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,Mp%dl%ResourceMonitoring>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpEnableNoMetaStoreProcessInfoContainer>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpEnablePurgeHipsCache>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_AdvertiseLogonMinutesFeature>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_EnableCommonMetricsEvents>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_EnableImpersonationOnNetworkResourceScan>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_EnablePersistedScanV2>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_Kernel_EnableFolderGuardOnPostCreate>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_Kernel_SystemIoRequestWorkOnBehalfOf>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_Md%dl%1ds>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_MdEnableCoreService>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpFC_RtpEnable%df%erConfigMonitoring>>"%pth%hklm.list"
echo HKLM:%smwd%\Features\EcsConfigs,MpForceDllHostScanExeOnOpen>>"%pth%hklm.list"
echo HKLM:%smwd%\Real-Time Protection,%dl%AsyncScanOnOpen>>"%pth%hklm.list"
echo HKLM:%smwd%\Real-Time Protection,%dl%RealtimeMonitoring>>"%pth%hklm.list"
echo HKLM:%smwd%\Real-Time Protection,Dpa%dl%d>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,AvgCPULoadFactor>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,%dl%ArchiveScanning>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,%dl%EmailScanning>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,%dl%RemovableDriveScanning>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,%dl%ScanningMappedNetworkDrivesForFullScan>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,%dl%ScanningNetworkFiles>>"%pth%hklm.list"
echo HKLM:%smwd%\Scan,LowCpuPriority>>"%pth%hklm.list"
echo HKLM:%smwd%\Spynet,MAPSconcurrency>>"%pth%hklm.list"
echo HKLM:%smwd%\Spynet,SpyNetReporting>>"%pth%hklm.list"
echo HKLM:%smwd%\Spynet,SpyNetReportingLocation>>"%pth%hklm.list"
echo HKLM:%smwd%\Spynet,SubmitSamplesConsent>>"%pth%hklm.list"
echo HKLM:%smwd%\%wd% Exploit Guard\ASR,EnableASRConsumers>>"%pth%hklm.list"
echo HKLM:%smwd%\%wd% Exploit Guard\Controlled Folder Access,EnableControlledFolderAccess>>"%pth%hklm.list"
echo HKLM:%smwd%\%wd% Exploit Guard\Network Protection,EnableNetworkProtection>>"%pth%hklm.list"
echo HKLM:%smwci%\ConfigSecurityPolicy.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\DlpUserAgent.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\%df%erbootstrapper.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpam-d.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpam-fe.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpam-fe_bd.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpas-d.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpas-fe.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpas-fe_bd.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpav-d.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpav-fe.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpav-fe_bd.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MpCmdRun.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MpCopyAccelerator.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\Mp%df%erCoreService.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MpDlpCmd.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MpDlpService.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\mpextms.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MpSigStub.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MRT.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MsMpEng.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\MsSense.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\NisSrv.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\OfflineScannerShell.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\secinit.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SecureKernel.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SecurityHealthHost.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SecurityHealthService.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SecurityHealthSystray.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseAP.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseAPToast.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseCM.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseGPParser.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseIdentity.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseImdsCollector.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseIR.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseNdr.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseSampleUploader.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SenseTVM.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\SgrmBroker.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\%ss%.exe>>"%pth%hklm.list"
echo HKLM:%smwci%\LSASS.exe>>"%pth%hklm.list"
echo HKLM:%smw% NT\%cv%\Svchost,WebThreatDefense>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\AppHost,EnableWebContentEvaluation>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Explorer,AicEnabled>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Explorer,%ss%Enabled>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Explorer\StartupApproved\Run,SecurityHealth>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,Enabled>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Run,SecurityHealth>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Run\Autoruns%dl%d,SecurityHealth>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Shell Extensions\Approved,{09A47860-11B0-4DA5-AFA5-26D86198A780}>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Shell Extensions\Blocked,{09A47860-11B0-4DA5-AFA5-26D86198A780}>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\WINEVT\Channels\Microsoft-Windows-%wd%\Operational,Enabled>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\WINEVT\Channels\Microsoft-Windows-%wd%\WHC,Enabled>>"%pth%hklm.list"
echo HKLM:%smw%\%cv%\Policies\Explorer,SettingsPageVisibility>>"%pth%hklm.list"
echo HKLM:%spm%\MRT,DontOfferThroughWUAU>>"%pth%hklm.list"
echo HKLM:%spm%\MRT,DontReportInfectionInformation>>"%pth%hklm.list"
echo HKLM:%spm%\MicrosoftEdge\PhishingFilter>>"%pth%hklm.list"
echo HKLM:%spm%\MicrosoftEdge\PhishingFilter,EnabledV9>>"%pth%hklm.list"
echo HKLM:%spm%\MicrosoftEdge\PhishingFilter,PreventOverrideAppRepUnknown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Account protection,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\App and Browser protection,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\App and Browser protection,DisallowExploitProtectionOverride>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Device performance and health,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Device security,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Family options,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Firewall and network protection,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Notifications,%dl%Notifications>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Systray,HideSystray>>"%pth%hklm.list"
echo HKLM:%spmwd% Security Center\Virus and threat protection,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd%,AllowFastServiceStartup>>"%pth%hklm.list"
echo HKLM:%spmwd%,%dl%AntiSpyware>>"%pth%hklm.list"
echo HKLM:%spmwd%,%dl%LocalAdminMerge>>"%pth%hklm.list"
echo HKLM:%spmwd%,%dl%RoutinelyTakingAction>>"%pth%hklm.list"
echo HKLM:%spmwd%,PUAProtection>>"%pth%hklm.list"
echo HKLM:%spmwd%,RandomizeScheduleTaskTimes>>"%pth%hklm.list"
echo HKLM:%spmwd%,ServiceKeepAlive>>"%pth%hklm.list"
echo HKLM:%spmwd%\Exclusions,%dl%AutoExclusions>>"%pth%hklm.list"
echo HKLM:%spmwd%\MpEngine,EnableFileHashComputation>>"%pth%hklm.list"
echo HKLM:%spmwd%\MpEngine,MpBafsExtendedTimeout>>"%pth%hklm.list"
echo HKLM:%spmwd%\MpEngine,MpCloudBlockLevel>>"%pth%hklm.list"
echo HKLM:%spmwd%\MpEngine,MpEnablePus>>"%pth%hklm.list"
echo HKLM:%spmwd%\NIS\Consumers\IPS,%dl%ProtocolRecognition>>"%pth%hklm.list"
echo HKLM:%spmwd%\NIS\Consumers\IPS,%dl%SignatureRetirement>>"%pth%hklm.list"
echo HKLM:%spmwd%\NIS\Consumers\IPS,ThrottleDetectionEventsRate>>"%pth%hklm.list"
echo HKLM:%spmwd%\Policy Manager,%dl%ScanningNetworkFiles>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%BehaviorMonitoring>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%InformationProtectionControl>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%IntrusionPreventionSystem>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%IOAVProtection>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%OnAccessProtection>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%RawWriteNotification>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%RealtimeMonitoring>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%ScanOnRealtimeEnable>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,%dl%ScriptScanning>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,LocalSettingOverride%dl%BehaviorMonitoring>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,LocalSettingOverride%dl%IntrusionPreventionSystem>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,LocalSettingOverride%dl%IOAVProtection>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,LocalSettingOverride%dl%OnAccessProtection>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,LocalSettingOverride%dl%RealtimeMonitoring>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,LocalSettingOverrideRealtimeScanDirection>>"%pth%hklm.list"
echo HKLM:%spmwd%\Real-Time Protection,RealtimeScanDirection>>"%pth%hklm.list"
echo HKLM:%spmwd%\Reporting,%dl%EnhancedNotifications>>"%pth%hklm.list"
echo HKLM:%spmwd%\Reporting,%dl%GenericRePorts>>"%pth%hklm.list"
echo HKLM:%spmwd%\Reporting,WppTracingComponents>>"%pth%hklm.list"
echo HKLM:%spmwd%\Reporting,WppTracingLevel>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%ArchiveScanning>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%CatchupFullScan>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%CatchupQuickScan>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%EmailScanning>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%Heuristics>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%RemovableDriveScanning>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%ReparsePointScanning>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%RestorePoint>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%ScanningMappedNetworkDrivesForFullScan>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,%dl%ScanningNetworkFiles>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,LowCpuPriority>>"%pth%hklm.list"
echo HKLM:%spmwd%\Scan,ScanOnlyIfIdle>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,%dl%ScanOnUpdate>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,%dl%ScheduledSignatureUpdateOnBattery>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,%dl%UpdateOnStartupWithoutEngine>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,ForceUpdateFromMU>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,RealtimeSignatureDelivery>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,ScheduleTime>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,Signature%dl%Notification>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,SignatureUpdateCatchupInterval>>"%pth%hklm.list"
echo HKLM:%spmwd%\Signature Updates,UpdateOnStartUp>>"%pth%hklm.list"
echo HKLM:%spmwd%\%ss%,ConfigureAppInstallControl>>"%pth%hklm.list"
echo HKLM:%spmwd%\%ss%,ConfigureAppInstallControlEnabled>>"%pth%hklm.list"
echo HKLM:%spmwd%\Spynet,%dl%BlockAtFirstSeen>>"%pth%hklm.list"
echo HKLM:%spmwd%\Spynet,LocalSettingOverrideSpynetReporting>>"%pth%hklm.list"
echo HKLM:%spmwd%\Spynet,SpynetReporting>>"%pth%hklm.list"
echo HKLM:%spmwd%\Spynet,SubmitSamplesConsent>>"%pth%hklm.list"
echo HKLM:%spmwd%\UX Configuration,UILockdown>>"%pth%hklm.list"
echo HKLM:%spmwd%\%wd% Exploit Guard\ASR,ExploitGuard_ASR_Rules>>"%pth%hklm.list"
echo HKLM:%spmwd%\%wd% Exploit Guard\Controlled Folder Access,EnableControlledFolderAccess>>"%pth%hklm.list"
echo HKLM:%spmwd%\%wd% Exploit Guard\Network Protection,EnableNetworkProtection>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,ConfigureKernelShadowStacksLaunch>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,ConfigureSystemGuardLaunch>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,EnableVirtualizationBasedSecurity>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,HVCIMATRequired>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,HypervisorEnforcedCodeIntegrity>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,LsaCfgFlags>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\DeviceGuard,RequirePlatformSecurityFeatures>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\System,Enable%ss%>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\WTDS\Components,NotifyMalicious>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\WTDS\Components,NotifyPasswordReuse>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\WTDS\Components,NotifyUnsafeApp>>"%pth%hklm.list"
echo HKLM:%spm%\Windows\WTDS\Components,ServiceEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%pth%hklm.list"
echo HKLM:%scc%\CI\Policy>>"%pth%hklm.list"
echo HKLM:%scc%\CI\State>>"%pth%hklm.list"
echo HKLM:%scc%\Lsa,LsaCfgFlags>>"%pth%hklm.list"
echo HKLM:%scc%\Lsa,RunAsPPL>>"%pth%hklm.list"
echo HKLM:%scc%\Lsa,RunAsPPLBoot>>"%pth%hklm.list"
echo HKLM:%sccd%,EnableVirtualizationBasedSecurity>>"%pth%hklm.list"
echo HKLM:%sccd%,Locked>>"%pth%hklm.list"
echo HKLM:%sccd%,RequirePlatformSecurityFeatures>>"%pth%hklm.list"
echo HKLM:%sccd%,RequireMicrosoftSignedBootChain>>"%pth%hklm.list"
echo HKLM:%sccd%\Capabilities>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\CredentialGuard>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\KeyGuard\Status>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity,Enabled>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity,HVCIMATRequired>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity,Locked>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity,WasEnabledBy>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity,WasEnabledBySysprep>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\KernelShadowStacks,AuditModeEnabled>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\KernelShadowStacks,Enabled>>"%pth%hklm.list"
echo HKLM:%sccd%\Scenarios\KernelShadowStacks,WasEnabledBy>>"%pth%hklm.list"
echo HKLM:%scc%\Ubpm,CriticalMaintenance_%df%erCleanup>>"%pth%hklm.list"
echo HKLM:%scc%\Ubpm,CriticalMaintenance_%df%erVerification>>"%pth%hklm.list"
echo HKLM:%scc%\WMI\Autologger\%df%erApiLogger,Start>>"%pth%hklm.list"
echo HKLM:%scc%\WMI\Autologger\%df%erAuditLogger,Start>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Allow_In>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Allow_Out>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Block_In>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Block_Out>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,Windows%df%er-1>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,Windows%df%er-2>>"%pth%hklm.list"
echo HKLM:%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,Windows%df%er-3>>"%pth%hklm.list"
echo HKLM:%scs%\MDCoreSvc,Start>>"%pth%hklm.list"
echo HKLM:%scs%\MsSecFlt,Start>>"%pth%hklm.list"
echo HKLM:%scs%\MsSecWfp,Start>>"%pth%hklm.list"
echo HKLM:%scs%\SecurityHealthService,Start>>"%pth%hklm.list"
echo HKLM:%scs%\Sense,Start>>"%pth%hklm.list"
echo HKLM:%scs%\SgrmAgent,Start>>"%pth%hklm.list"
echo HKLM:%scs%\SgrmBroker,Start>>"%pth%hklm.list"
echo HKLM:%scs%\WdNisDrv,Start>>"%pth%hklm.list"
echo HKLM:%scs%\WdNisSvc,Start>>"%pth%hklm.list"
echo HKLM:%scs%\webthreatdefsvc,Start>>"%pth%hklm.list"
echo HKLM:%scs%\webthreatdefusersvc,Start>>"%pth%hklm.list"
echo HKLM:%scs%\Win%df%,Start>>"%pth%hklm.list"
echo HKLM:%scs%\wscsvc,Start>>"%pth%hklm.list"
echo HKLM:%scs%\wtd,Start>>"%pth%hklm.list"
echo HKLM:%scs%\WdBoot,Start>>"%pth%hklm.list"
echo HKLM:%scs%\WdFilter,Start>>"%pth%hklm.list"
echo HKLM:%scs%\MsSecCore,Start>>"%pth%hklm.list"
exit /b 

:BackUpDone
%ra% %ASR% /v "BackUpDone" /t %dw% /d 1 /f>nul 2>&1
set BackUpDone=1
exit /b

:PoliciesHKCU
%msg% "Applying policies for the current user..." "Применение политик для текущего пользователя..."
%ra% "HKCU%spm%\Edge" /v "%ss%Enabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKCU%spm%\Edge" /v "%ss%PuaEnabled" /t %dw% /d 0 /f>nul 2>&1
set UserSettingDone=1
exit /b

:Policies
%msg% "Applying group policies..." "Применение групповых политик..." 
%ra% "HKLM%spmwd%" /v "AllowFastServiceStartup" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%" /v "%dl%AntiSpyware" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%" /v "%dl%LocalAdminMerge" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%" /v "%dl%RoutinelyTakingAction" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%" /v "PUAProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%" /v "RandomizeScheduleTaskTimes" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%" /v "ServiceKeepAlive" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Exclusions" /v "%dl%AutoExclusions" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\MpEngine" /v "EnableFileHashComputation" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\MpEngine" /v "MpBafsExtendedTimeout" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\MpEngine" /v "MpCloudBlockLevel" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\MpEngine" /v "MpEnablePus" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\NIS\Consumers\IPS" /v "%dl%ProtocolRecognition" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\NIS\Consumers\IPS" /v "%dl%SignatureRetirement" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\NIS\Consumers\IPS" /v "ThrottleDetectionEventsRate" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Policy Manager" /v "%dl%ScanningNetworkFiles" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%BehaviorMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%IOAVProtection" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%InformationProtectionControl" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%IntrusionPreventionSystem" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%OnAccessProtection" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%RawWriteNotification" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%ScanOnRealtimeEnable" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "%dl%ScriptScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%BehaviorMonitoring" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%IOAVProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%IntrusionPreventionSystem" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%OnAccessProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "LocalSettingOverride%dl%RealtimeMonitoring" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "LocalSettingOverrideRealtimeScanDirection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Real-Time Protection" /v "RealtimeScanDirection" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM%spmwd%\Spynet" /v "LocalSettingOverrideSpynetReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Spynet" /v "SpynetReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Spynet" /v "SubmitSamplesConsent" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM%spmwd%\Spynet" /v "%dl%BlockAtFirstSeen" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "%dl%ScanOnUpdate" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "%dl%ScheduledSignatureUpdateOnBattery" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "%dl%UpdateOnStartupWithoutEngine" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "ForceUpdateFromMU" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "RealtimeSignatureDelivery" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "ScheduleTime" /t %dw% /d "5184" /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "Signature%dl%Notification" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "SignatureUpdateCatchupInterval" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM%spmwd%\Signature Updates" /v "UpdateOnStartUp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Reporting" /v "%dl%EnhancedNotifications" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Reporting" /v "%dl%GenericRePorts" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Reporting" /v "WppTracingComponents" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Reporting" /v "WppTracingLevel" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%ArchiveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%CatchupFullScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%CatchupQuickScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%EmailScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%Heuristics" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%RemovableDriveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%ReparsePointScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%RestorePoint" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%ScanningMappedNetworkDrivesForFullScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "%dl%ScanningNetworkFiles" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "LowCpuPriority" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\Scan" /v "ScanOnlyIfIdle" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\%wd% Exploit Guard\ASR" /v "ExploitGuard_ASR_Rules" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\%wd% Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\%wd% Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\App and Browser protection" /v "DisallowExploitProtectionOverride" /t %dw% /d 1 /f>nul 2>&1
::
%ra% "HKLM%spm%\Windows\System" /v "Enable%ss%" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spmwd%\%ss%" /v "ConfigureAppInstallControlEnabled" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\%ss%" /v "ConfigureAppInstallControl" /t %sz% /d "Anywhere" /f>nul 2>&1
%ra% "HKLM%spm%\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\MicrosoftEdge\PhishingFilter" /v "PreventOverrideAppRepUnknown" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\MicrosoftEdge\PhishingFilter" /v "" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\Windows\WTDS\Components" /v "ServiceEnabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\Windows\WTDS\Components" /v "NotifyUnsafeApp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\Windows\WTDS\Components" /v "NotifyMalicious" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\Windows\WTDS\Components" /v "NotifyPasswordReuse" /t %dw% /d 0 /f>nul 2>&1
::
%rd% "HKLM%spm%\Windows\DeviceGuard" /v "HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\DeviceGuard" /v "LsaCfgFlags" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\DeviceGuard" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\DeviceGuard" /v "ConfigureSystemGuardLaunch" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\DeviceGuard" /v "ConfigureKernelShadowStacksLaunch" /f>nul 2>&1
%ra% "HKLM%spm%\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%spm%\Windows\DeviceGuard" /v "HVCIMATRequired" /t %dw% /d 0 /f>nul 2>&1
::
%ra% "HKLM%spmwd% Security Center\Account protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\App and Browser protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Device performance and health" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Device security" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Family options" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Firewall and network protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Notifications" /v "%dl%Notifications" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Systray" /v "HideSystray" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd% Security Center\Virus and threat protection" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spmwd%\UX Configuration" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
::
%ra% "HKLM%spm%\MRT" /v DontOfferThroughWUAU /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%spm%\MRT" /v DontReportInfectionInformation /t %dw% /d 1 /f>nul 2>&1
::
set "HidePath=HKLM%smw%\%cv%\Policies\Explorer"
%rq% "%HidePath%" /v "SettingsPageVisibility">nul 2>&1||(%ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "hide:windows%df%er" /f>nul 2>&1&goto :EndHideSetting)
for /f "tokens=2*" %%a in ('%rq% "%HidePath%" /v "SettingsPageVisibility" 2^>nul') do set "SettingsPageVisibility=%%b"
if "%SettingsPageVisibility%"==";" set SettingsPageVisibility=
if "%SettingsPageVisibility%"=="hide:" set SettingsPageVisibility=
%ifNdef% SettingsPageVisibility %ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "hide:windows%df%er" /f>nul 2>&1
echo %SettingsPageVisibility% | find /i "windows%df%er">nul 2>&1&&goto :EndHideSetting
%ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "%SettingsPageVisibility%;windows%df%er" /f>nul 2>&1
:EndHideSetting
%gpupdate% /force >nul 2>&1
exit /b

:RegistryHKCU
%msg% "Applying registry settings for the current user..." "Применение настроек реестра для текущего пользователя..." 
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cleanup" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Verification" /%dl%>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\%ss%Specific" /%dl%>nul 2>&1
::
%ra% "HKCU%smw%\%cv%\AppHost" /v "EnableWebContentEvaluation" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKCU%smw%\%cv%\AppHost" /v "PreventOverride" /t %dw% /d 0 /f>nul 2>&1
::
%ra% "HKCU%smw% Security Health\State" /v "AppAndBrowser_Edge%ss%Off" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKCU%smw% Security Health\State" /v "AppAndBrowser_StoreApps%ss%Off" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKCU%smw% Security Health\State" /v "AppAndBrowser_Pua%ss%Off" /t %dw% /d 1 /f>nul 2>&1
::
%ra% "HKCU%smw%\%cv%\Policies\Attachments" /v "SaveZoneInformation" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKCU%smw%\%cv%\Policies\Attachments" /v "HideZoneInfoOnProperties" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKCU%smw%\%cv%\Policies\Attachments" /v "ScanWithAntiVirus" /t %dw% /d 1 /f>nul 2>&1
::
%ra% "HKCU%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
call :BlockUWP sechealth
call :BlockUWP chxapp
set UserSettingDone=1
exit /b

:Registry
%msg% "Applying registry settings..." "Применение настроек реестра..."
%ra% "HKLM%smw%\%cv%\AppHost" /v "EnableWebContentEvaluation" /t %dw% /d 0 /f>nul 2>&1
::
%rd% "HKLM%smw%\%cv%\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t %sz% /d "" /f>nul 2>&1
%regsvr32% /u "%SystemDrive%\Program Files\%wd%\shellext.dll" /s>nul 2>&1
::
%ra% "HKLM%scl%\exefile\shell\open" /v "No%ss%" /t %sz% /d "" /f>nul 2>&1
%ra% "HKLM%scl%\exefile\shell\runas" /v "No%ss%" /t %sz% /d "" /f>nul 2>&1
%ra% "HKLM%scl%\exefile\shell\runasuser" /v "No%ss%" /t %sz% /d "" /f>nul 2>&1
::
%ra% "HKLM%smwd% Security Center\Notifications" /v "%dl%EnhancedNotifications" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd% Security Center\Virus and threat protection" /v "FilesBlockedNotification%dl%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd% Security Center\Virus and threat protection" /v "NoActionNotification%dl%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd% Security Center\Virus and threat protection" /v "SummaryNotification%dl%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%" /v "%dl%AntiSpyware" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%" /v "%dl%AntiVirus" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%" /v "HybridModeEnabled" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM%smwd%" /v "IsServiceRunning" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "PUAProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%" /v "ProductStatus" /t %dw% /d 2 /f>nul 2>&1
%ra% "HKLM%smwd%" /v "ProductType" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM%smwd%\CoreService">nul 2>&1||goto :SkipCoreService
%ra% "HKLM%smwd%\CoreService" /v "%dl%CoreService1DSTelemetry" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\CoreService" /v "%dl%CoreServiceECSIntegration" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\CoreService" /v "Md%dl%ResController" /t %dw% /d 1 /f>nul 2>&1
:SkipCoreService
%ra% "HKLM%smwd%\Features" /v "EnableCACS" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features" /v "Protection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features" /v "TamperProtection" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features" /v "TamperProtectionSource" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM%smwd%\EcsConfigs">nul 2>&1||goto :SkipEcsConfigs
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "EnableAdsSymlinkMitigation_MpRamp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "EnableBmProcessInfoMetastoreMaintenance_MpRamp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "EnableCIWorkaroundOnCFAEnabled_MpRamp" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "Md%dl%ResController" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "Mp%dl%PropBagNotification" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "Mp%dl%ResourceMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpEnableNoMetaStoreProcessInfoContainer" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpEnablePurgeHipsCache" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_AdvertiseLogonMinutesFeature" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_EnableCommonMetricsEvents" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_EnableImpersonationOnNetworkResourceScan" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_EnablePersistedScanV2" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_EnableFolderGuardOnPostCreate" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_SystemIoRequestWorkOnBehalfOf" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_Md%dl%1ds" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_MdEnableCoreService" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_RtpEnable%df%erConfigMonitoring" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpForceDllHostScanExeOnOpen" /t %dw% /d 0 /f>nul 2>&1
:SkipEcsConfigs
%ra% "HKLM%smwd%\Real-Time Protection" /v "%dl%AsyncScanOnOpen" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Real-Time Protection" /v "Dpa%dl%d" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "AvgCPULoadFactor" /t %dw% /d "10" /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%ArchiveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%EmailScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%RemovableDriveScanning" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%ScanningMappedNetworkDrivesForFullScan" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%ScanningNetworkFiles" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "LowCpuPriority" /t %dw% /d 1 /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "MAPSconcurrency" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "SpyNetReporting" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "https://0.0.0.0" /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "SubmitSamplesConsent" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\%wd% Exploit Guard\ASR" /v "EnableASRConsumers" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\%wd% Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%\%wd% Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t %dw% /d 0 /f>nul 2>&1
::
%rq% "HKLM%smw%\%cv%\Run" /v "SecurityHealth">nul 2>&1&&(
%rd% "HKLM%smw%\%cv%\Run" /v "SecurityHealth" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Run\Autoruns%dl%d" /v "SecurityHealth" /t REG_EXPAND_SZ /d "^%windir^%\system32\SecurityHealthSystray.exe" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "FFFFFFFFFFFFFFFFFFFFFFFF" /f>nul 2>&1
)
::
%ra% "HKLM%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
::
%ra% "HKLM%scc%\CI\Policy" /v "VerifiedAndReputablePolicyState" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM%scc%\CI\State" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "SmartLockerMode" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smwd%" /v "VerifiedAndReputableTrustModeEnabled" /t %dw% /d 0 /f>nul 2>&1
::
%ra% "HKLM%smwd% Security Center\Device security" /v "UILockdown" /t %dw% /d 1 /f>nul 2>&1
%rd% "HKLM%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "WasEnabledBy" /f>nul 2>&1
%rd% "HKLM%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "WasEnabledBySysprep" /f>nul 2>&1
%ra% "HKLM%sccd%" /v "EnableVirtualizationBasedSecurity" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%" /v "RequirePlatformSecurityFeatures" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%" /v "RequireMicrosoftSignedBootChain" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%" /v "Locked" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM%sccd%\Capabilities" /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\CredentialGuard" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "HVCIMATRequired" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\KernelShadowStacks" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\KernelShadowStacks" /v "AuditModeEnabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%sccd%\Scenarios\KernelShadowStacks" /v "WasEnabledBy" /t %dw% /d 4 /f>nul 2>&1

%ra% "HKLM%scc%\Lsa" /v "LsaCfgFlags" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%scc%\Lsa" /v "RunAsPPL" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%scc%\Lsa" /v "RunAsPPLBoot" /t %dw% /d 0 /f>nul 2>&1
%rd% "HKLM%smwci%\LSASS.exe" /v "AuditLevel" /f>nul 2>&1
::
%ra% "HKLM%smw%\%cv%\WINEVT\Channels\Microsoft-Windows-%wd%\Operational" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\WINEVT\Channels\Microsoft-Windows-%wd%\WHC" /v "Enabled" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%scc%\WMI\Autologger\%df%erApiLogger" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%ra% "HKLM%scc%\WMI\Autologger\%df%erAuditLogger" /v "Start" /t %dw% /d 0 /f>nul 2>&1
::
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /f>nul 2>&1
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /f>nul 2>&1
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /f>nul 2>&1
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /f>nul 2>&1
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-1" /f>nul 2>&1
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-2" /f>nul 2>&1
%rd% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-3" /f>nul 2>&1
::
%rd% "HKLM%scc%\Ubpm" /v "CriticalMaintenance_%df%erCleanup" /f>nul 2>&1
%rd% "HKLM%scc%\Ubpm" /v "CriticalMaintenance_%df%erVerification" /f>nul 2>&1
::
%tk% /im %ss%.exe /t /f>nul 2>&1
%rd% "HKLM%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%rd% "HKLM%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%rd% "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
::
%ra% "HKLM%smw%\%cv%\Explorer" /v "%ss%Enabled" /t %sz% /d "Off" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Explorer" /v "AicEnabled" /t %sz% /d "Anywhere" /f>nul 2>&1
exit /b

:Services
%msg% "Disabling the launch of services and drivers..." "Отключение запуска служб и драйверов..."
for %%s in (Win%df% MDCoreSvc WdNisSvc Sense wscsvc SgrmBroker SecurityHealthService webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdFilter SgrmAgent MsSecWfp MsSecFlt MsSecCore wtd) do %rq% "HKLM%scs%\%%~s">nul 2>&1&&%ra% "HKLM%scs%\%%~s" /v "Start" /t %dw% /d 4 /f>nul 2>&1
::
%rd% "HKLM%smw% NT\CurentVersion\Svchost" /v "WebThreatDefense" /f>nul 2>&1
exit /b

:Block
%msg% "Block process launch via fake Debugger" "Блокировка запуска процессов через поддельный отладчик"
%ra% "HKLM%smwci%\ConfigSecurityPolicy.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\DlpUserAgent.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\%df%erbootstrapper.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpam-d.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpam-fe.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpam-fe_bd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpas-d.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpas-fe.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpas-fe_bd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpav-d.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpav-fe.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpav-fe_bd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MpCmdRun.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MpCopyAccelerator.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\Mp%df%erCoreService.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MpDlpCmd.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MpDlpService.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\mpextms.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MpSigStub.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MsMpEng.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\MsSense.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\NisSrv.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\OfflineScannerShell.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\secinit.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SecureKernel.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SecurityHealthHost.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SecurityHealthService.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SecurityHealthSystray.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseAP.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseAPToast.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseCM.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseGPParser.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseIdentity.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseImdsCollector.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseIR.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseNdr.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseSampleUploader.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SenseTVM.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\SgrmBroker.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
%ra% "HKLM%smwci%\%ss%.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
if exist "%sysdir%\MRT.exe" %ra% "HKLM%smwci%\MRT.exe" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
exit /b

:BlockProcess
%ra% "HKLM%smwci%\%~1" /v "Debugger" /t %sz% /d "dllhost.exe" /f>nul 2>&1
exit /b %errorlevel%

:UnBlockProcess
set "unbl=HKLM%smwci%\%~1"
%rd% "%unbl%" /v "Debugger" /f>nul 2>&1
%rq% "%unbl%" /v *>nul 2>&1
if %errorlevel%==1 %rd% "%unbl%" /f>nul 2>&1
exit /b %errorlevel%

:RestoreCurrentUser
%msg% "Restore default setting for current user..." "Восстановление настроек по умолчанию для текущего пользователя..."
%regsvr32% /i "%SystemDrive%\Program Files\%wd%\shellext.dll" /s>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cache Maintenance" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Cleanup" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Scheduled Scan" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\%wd%\%wd% Verification" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\%ss%Specific" /Enable>nul 2>&1
%rd% "HKCU%smw% Security Health\State" /v "AppAndBrowser_Edge%ss%Off" /f>nul 2>&1
%rd% "HKCU%smw% Security Health\State" /v "AppAndBrowser_Pua%ss%Off" /f>nul 2>&1
%rd% "HKCU%smw% Security Health\State" /v "AppAndBrowser_StoreApps%ss%Off" /f>nul 2>&1
%rd% "HKCU%smw%\%cv%\AppHost" /v "EnableWebContentEvaluation" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKCU%smw%\%cv%\AppHost" /v "PreventOverride" /f>nul 2>&1
%rd% "HKCU%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f>nul 2>&1
%rd% "HKCU%smw%\%cv%\Policies\Attachments" /f>nul 2>&1
%rd% "HKCU%spm%\Edge" /f>nul 2>&1
call :UnBlockUWP sechealth
call :UnBlockUWP chxapp
if exist "%save%MySecurityDefaults.reg" %reg% import "%save%MySecurityDefaults.reg">nul 2>&1
exit /b

:Restore
%msg% "Restore default setting for system..." "Восстановление настроек по умолчанию для всей системы..."
set "HidePath=HKLM%smw%\%cv%\Policies\Explorer"
for /f "tokens=2*" %%a in ('%rq% "%HidePath%" /v "SettingsPageVisibility" 2^>nul') do set "SettingsPageVisibility=%%b"
%ifNdef% SettingsPageVisibility goto :SkipRestoreVisibility
echo %SettingsPageVisibility% | find /i "windows%df%er">nul 2>&1||goto :SkipRestoreVisibility
set SettingsPageVisibility=%SettingsPageVisibility:windowsdefender;=%
set SettingsPageVisibility=%SettingsPageVisibility:windowsdefender=%
if "%SettingsPageVisibility%"=="hide:" set SettingsPageVisibility=
%ra% "%HidePath%" /v "SettingsPageVisibility" /t %sz% /d "%SettingsPageVisibility%" /f>nul 2>&1
:SkipRestoreVisibility
%ra% "HKLM%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t %sz% /d "%ss%" /f>nul 2>&1
%ra% "HKLM%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t %sz% /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%ra% "HKLM%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /ve /t %sz% /d "%windir%\System32\%ss%ps.dll" /f>nul 2>&1
%ra% "HKLM%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /v "ThreadingModel" /t %sz% /d "Both" /f>nul 2>&1
%ra% "HKLM%scl%\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32" /ve /t %sz% /d "%windir%\System32\%ss%.exe" /f>nul 2>&1
%ifNdef% ProgramFiles(x86) goto :SkipRestoreSmartScreen
%ra% "HKLM%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t %sz% /d "%ss%" /f>nul 2>&1
%ra% "HKLM%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t %sz% /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%ra% "HKLM%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /ve /t %sz% /d "%windir%\SysWOW64\%ss%ps.dll" /f>nul 2>&1
%ra% "HKLM%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /v "ThreadingModel" /t %sz% /d "Both" /f>nul 2>&1
%ra% "HKLM%scl%\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32" /ve /t %sz% /d "%windir%\SysWOW64\%ss%.exe" /f>nul 2>&1
:SkipRestoreSmartScreen
%rd% "HKLM%scl%\exefile\shell\open" /v "No%ss%" /f>nul 2>&1
%rd% "HKLM%scl%\exefile\shell\runas" /v "No%ss%" /f>nul 2>&1
%rd% "HKLM%scl%\exefile\shell\runasuser" /v "No%ss%" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t %dw% /d "2" /f>nul 2>&1
%rd% "HKLM%smwd% Security Center\Device security" /v "UILockdown" /f>nul 2>&1
%rd% "HKLM%smwd% Security Center\Notifications" /v "%dl%EnhancedNotifications" /f>nul 2>&1
%rd% "HKLM%smwd% Security Center\Virus and threat protection" /v "FilesBlockedNotification%dl%d" /f>nul 2>&1
%rd% "HKLM%smwd% Security Center\Virus and threat protection" /v "NoActionNotification%dl%d" /f>nul 2>&1
%rd% "HKLM%smwd% Security Center\Virus and threat protection" /v "SummaryNotification%dl%d" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "%dl%AntiSpyware" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "%dl%AntiVirus" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "HybridModeEnabled" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "IsServiceRunning" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "ProductStatus" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "ProductType" /t %dw% /d "2" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "PUAProtection" /t %dw% /d "2" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "SmartLockerMode" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "VerifiedAndReputableTrustModeEnabled" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%" /v "SacLearningModeSwitch" /t %dw% /d "0" /f>nul 2>&1
%rq% "HKLM%smwd%\CoreService">nul 2>&1||goto :SkipRestoreCoreService
%ra% "HKLM%smwd%\CoreService" /v "%dl%CoreService1DSTelemetry" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\CoreService" /v "%dl%CoreServiceECSIntegration" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\CoreService" /v "Md%dl%ResController" /t %dw% /d "0" /f>nul 2>&1
:SkipRestoreCoreService
%ra% "HKLM%smwd%\Features" /v "EnableCACS" /t %dw% /d "0" /f>nul 2>&1
%rd% "HKLM%smwd%\Features" /v "Protection" /f>nul 2>&1
%ra% "HKLM%smwd%\Features" /v "TamperProtection" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features" /v "TamperProtectionSource" /t %dw% /d "5" /f>nul 2>&1
%rq% "HKLM%smwd%\EcsConfigs">nul 2>&1||goto :SkipRestoreEcsConfigs
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "EnableAdsSymlinkMitigation_MpRamp" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "EnableBmProcessInfoMetastoreMaintenance_MpRamp" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "EnableCIWorkaroundOnCFAEnabled_MpRamp" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "Md%dl%ResController" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "Mp%dl%PropBagNotification" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "Mp%dl%ResourceMonitoring" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpEnableNoMetaStoreProcessInfoContainer" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpEnablePurgeHipsCache" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_AdvertiseLogonMinutesFeature" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_EnableCommonMetricsEvents" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_EnableImpersonationOnNetworkResourceScan" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_EnablePersistedScanV2" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_EnableFolderGuardOnPostCreate" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_Kernel_SystemIoRequestWorkOnBehalfOf" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_Md%dl%1ds" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_MdEnableCoreService" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpFC_RtpEnable%df%erConfigMonitoring" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Features\EcsConfigs" /v "MpForceDllHostScanExeOnOpen" /t %dw% /d "1" /f>nul 2>&1
:SkipRestoreEcsConfigs
%ra% "HKLM%smwd%\Real-Time Protection" /v "%dl%AsyncScanOnOpen" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Real-Time Protection" /v "%dl%RealtimeMonitoring" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Real-Time Protection" /v "Dpa%dl%d" /t %dw% /d "0" /f>nul 2>&1
%rd% "HKLM%smwd%\Scan" /v "AvgCPULoadFactor" /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%ArchiveScanning" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%EmailScanning" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%RemovableDriveScanning" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%ScanningMappedNetworkDrivesForFullScan" /t %dw% /d "0" /f>nul 2>&1
%ra% "HKLM%smwd%\Scan" /v "%dl%ScanningNetworkFiles" /f>nul 2>&1
%rd% "HKLM%smwd%\Scan" /v "LowCpuPriority" /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "MAPSconcurrency" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "SpyNetReporting" /t %dw% /d "2" /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "SpyNetReportingLocation" /t %sz% /d "SOAP:https://wdcp.microsoft.com/WdCpSrvc.asmx SOAP:https://wdcpalt.microsoft.com/WdCpSrvc.asmx REST:https://wdcp.microsoft.com/wdcp.svc/submitReport REST:https://wdcpalt.microsoft.com/wdcp.svc/submitReport BOND:https://wdcp.microsoft.com/wdcp.svc/bond/submitreport BOND:https://wdcpalt.microsoft.com/wdcp.svc/bond/submitreport" /f>nul 2>&1
%ra% "HKLM%smwd%\Spynet" /v "SubmitSamplesConsent" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM%smwd%\%wd% Exploit Guard\ASR" /v "EnableASRConsumers" /f>nul 2>&1
%rd% "HKLM%smwd%\%wd% Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /f>nul 2>&1
%ra% "HKLM%smwd%\%wd% Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t %dw% /d "0" /f>nul 2>&1
%rd% "HKLM%smwci%\ConfigSecurityPolicy.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\DlpUserAgent.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\%df%erbootstrapper.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpam-d.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpam-fe.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpam-fe_bd.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpas-d.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpas-fe.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpas-fe_bd.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpav-d.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpav-fe.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpav-fe_bd.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MpCmdRun.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MpCopyAccelerator.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\Mp%df%erCoreService.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MpDlpCmd.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MpDlpService.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\mpextms.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MpSigStub.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MsMpEng.exe" /v "Debugger" /f>nul 2>&1
%rd% "HKLM%smwci%\MsSense.exe" /v "Debugger" /f>nul 2>&1
%rd% "HKLM%smwci%\NisSrv.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\OfflineScannerShell.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\secinit.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SecureKernel.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SecurityHealthHost.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SecurityHealthService.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SecurityHealthSystray.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseAP.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseAPToast.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseCM.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseGPParser.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseIdentity.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseImdsCollector.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseIR.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseNdr.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseSampleUploader.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SenseTVM.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\SgrmBroker.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\%ss%.exe" /f>nul 2>&1
%rd% "HKLM%smwci%\MRT.exe" /v "Debugger" /f>nul 2>&1
%ra% "HKLM%smw% NT\%cv%\Svchost" /v "WebThreatDefense" /t %sz% /d "webthreatdefsvc" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\AppHost" /v "EnableWebContentEvaluation" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM%smw%\%cv%\Explorer" /v "AicEnabled" /f>nul 2>&1
%rd% "HKLM%smw%\%cv%\Explorer" /v "%ss%Enabled" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "040000000000000000000000" /f>nul 2>&1
%rd% "HKLM%smw%\%cv%\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Run" /v "SecurityHealth" /t %sz% /d "C:\WINDOWS\system32\SecurityHealthSystray.exe" /f>nul 2>&1
%rd% "HKLM%smw%\%cv%\Run\Autoruns%dl%d" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t %sz% /d "EPP" /f>nul 2>&1
%rd% "HKLM%smw%\%cv%\Shell Extensions\Blocked" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\WINEVT\Channels\Microsoft-Windows-%wd%\Operational" /v "Enabled" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\WINEVT\Channels\Microsoft-Windows-%wd%\WHC" /v "Enabled" /t %dw% /d "1" /f>nul 2>&1
%rd% "HKLM%spm%\MicrosoftEdge\PhishingFilter" /f>nul 2>&1
%rd% "HKLM%spmwd% Security Center" /f>nul 2>&1
%rd% "HKLM%spmwd%" /f>nul 2>&1
%rd% "HKLM%spmwd%\%wd% Exploit Guard" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\DeviceGuard" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\System" /v "Enable%ss%" /f>nul 2>&1
%rd% "HKLM%spm%\Windows\WTDS\Components" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t %sz% /d "%ss%" /f>nul 2>&1
%ra% "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t %sz% /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%ra% "HKLM\SYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM\SYSTEM\ControlSet001\Control\CI\Protected" /v "VerifiedAndReputablePolicyStateMinValueSeen" /t %dw% /d "2" /f>nul 2>&1
%ra% "HKLM%scc%\CI\Policy" /v "VerifiedAndReputablePolicyState" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%scc%\CI\Protected" /v "VerifiedAndReputablePolicyStateMinValueSeen" /t %dw% /d "2" /f>nul 2>&1
%rd% "HKLM%scc%\CI\State" /f>nul 2>&1
%rd% "HKLM%sccd%" /v "EnableVirtualizationBasedSecurity" /f>nul 2>&1
%rd% "HKLM%sccd%" /v "Locked" /f>nul 2>&1
%rd% "HKLM%sccd%" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%rd% "HKLM%sccd%" /v "RequireMicrosoftSignedBootChain" /f>nul 2>&1
%rd% "HKLM%sccd%\Scenarios\CredentialGuard" /f>nul 2>&1
%rd% "HKLM%sccd%\Scenarios\HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%rd% "HKLM%sccd%\Scenarios\KernelShadowStacks" /f>nul 2>&1
%rd% "HKLM%sccd%\Capabilities" /f>nul 2>&1
%ra% "HKLM%scc%\Ubpm" /v "CriticalMaintenance_%df%erCleanup" /t %sz% /d "NT Task\Microsoft\Windows\%wd%\%wd% Cleanup" /f>nul 2>&1
%ra% "HKLM%scc%\Ubpm" /v "CriticalMaintenance_%df%erVerification" /t %sz% /d "NT Task\Microsoft\Windows\%wd%\%wd% Verification" /f>nul 2>&1
%ra% "HKLM%scc%\WMI\Autologger\%df%erApiLogger" /v "Start" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%scc%\WMI\Autologger\%df%erAuditLogger" /v "Start" /t %dw% /d "1" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /t %sz% /d "v2.0|Action=Allow|Dir=In|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|LPort=443|Protocol=6|Name=Allow WebThreatDefSvc to receive from port 443|" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /t %sz% /d "v2.0|Action=Allow|Dir=Out|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|RPort=443|Protocol=6|Name=Allow WebThreatDefSvc to send to port 443|" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /t %sz% /d "v2.0|Action=Block|Dir=In|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|Name=Block inbound traffic to WebThreatDefSvc|" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /t %sz% /d "v2.0|Action=Block|Dir=Out|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|Name=Block outbound traffic to WebThreatDefSvc|" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-1" /t %sz% /d "v2.0|Action=Allow|Active=TRUE|Dir=Out|Protocol=6|App=%%ProgramFiles%%\%wd%\MsMpEng.exe|Svc=Win%df%|Name=Allow Out TCP traffic from Win%df%|" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-2" /t %sz% /d "v2.0|Action=Block|Active=TRUE|Dir=In|App=%%ProgramFiles%%\%wd%\MsMpEng.exe|Svc=Win%df%|Name=Block All In traffic to Win%df%|" /f>nul 2>&1
%ra% "HKLM%scs%\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "Windows%df%er-3" /t %sz% /d "v2.0|Action=Block|Active=TRUE|Dir=Out|App=%%ProgramFiles%%\%wd%\MsMpEng.exe|Svc=Win%df%|Name=Block All Out traffic from Win%df%|" /f>nul 2>&1
%rq% "HKLM%scs%\MDCoreSvc">nul 2>&1&&%ra% "HKLM%scs%\MDCoreSvc" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM%scs%\MsSecCore">nul 2>&1&&%ra% "HKLM%scs%\MsSecCore" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM%scs%\MsSecFlt">nul 2>&1&&%ra% "HKLM%scs%\MsSecFlt" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\MsSecWfp">nul 2>&1&&%ra% "HKLM%scs%\MsSecWfp" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\SecurityHealthService">nul 2>&1&&%ra% "HKLM%scs%\SecurityHealthService" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\Sense">nul 2>&1&&%ra% "HKLM%scs%\Sense" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\SgrmAgent">nul 2>&1&&%ra% "HKLM%scs%\SgrmAgent" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM%scs%\SgrmBroker">nul 2>&1&&%ra% "HKLM%scs%\SgrmBroker" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM%scs%\WdBoot">nul 2>&1&&%ra% "HKLM%scs%\WdBoot" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM%scs%\WdFilter">nul 2>&1&&%ra% "HKLM%scs%\WdFilter" /v "Start" /t %dw% /d 0 /f>nul 2>&1
%rq% "HKLM%scs%\WdNisDrv">nul 2>&1&&%ra% "HKLM%scs%\WdNisDrv" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\WdNisSvc">nul 2>&1&&%ra% "HKLM%scs%\WdNisSvc" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\webthreatdefsvc">nul 2>&1&&%ra% "HKLM%scs%\webthreatdefsvc" /v "Start" /t %dw% /d 3 /f>nul 2>&1
%rq% "HKLM%scs%\webthreatdefusersvc">nul 2>&1&&%ra% "HKLM%scs%\webthreatdefusersvc" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM%scs%\Win%df%">nul 2>&1&&%ra% "HKLM%scs%\Win%df%" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM%scs%\wscsvc">nul 2>&1&&%ra% "HKLM%scs%\wscsvc" /v "Start" /t %dw% /d 2 /f>nul 2>&1
%rq% "HKLM%scs%\wtd">nul 2>&1&&%ra% "HKLM%scs%\wtd" /v "Start" /t %dw% /d 2 /f>nul 2>&1
call :UnBlockUWP sechealth
call :UnBlockUWP chxapp
if exist "%save%MySecurityDefaults.reg" %reg% import "%save%MySecurityDefaults.reg">nul 2>&1
%gpupdate% /force >nul 2>&1
exit /b

:ListUWP
set "UWP=%~1"
set UwpName=
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k^|^|goto :EndSearchListUWP') do (set "UwpName=%%~nxa"&goto :EndSearchListUWP)
:EndSearchListUWP
%ifNdef% UwpName exit /b
echo HKLM:%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%>>"%pth%hkcu.list"
echo HKLM:%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%>>"%pth%hkcu.list"
for /f "tokens=*" %%a in ('%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore" ^| findstr /R /C:"S-1-5-21-*"') do (
	echo HKLM:%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%>>"%pth%hkcu.list"
	echo HKLM:%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%>>"%pth%hkcu.list"
	echo HKLM:%smw%\%cv%\Appx\AppxAllUserStore\%%~nxa\%UwpName%>>"%pth%hkcu.list")
exit /b

:BlockUWP
set "UWP=%~1"
set UwpName=
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=2" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k^|^|goto :EndSearchBlockUWP') do (set "UwpName=%%~nxa"&goto :EndSearchBlockUWP)
:EndSearchBlockUWP
%ifNdef% UwpName exit /b
%ra% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%" /f>nul 2>&1
%ra% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%" /f>nul 2>&1
for /f "tokens=*" %%a in ('%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore" ^| findstr /R /C:"S-1-5-21-*"') do (
	%ra% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%" /f>nul 2>&1
	%ra% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%" /f>nul 2>&1
)
exit /b

:UnBlockUWP
set "UWP=%~1"
set UwpName=
set UwpPath=
%rq% "%uwpsearch%" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "%uwpsearch%" /f "*%UWP%*" /k') do (set "UwpName=%%~nxa"&goto :EndSearchUnBlockUWP)
%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\InboxApplications" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\InboxApplications" /f "*%UWP%*" /k') do (set "UwpName=%%~nxa"&goto :EndSearchUnBlockUWP)
%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned" /f "*%UWP%*" /k>nul 2>&1&&for /f "tokens=*" %%a in ('%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned" /f "*%UWP%*" /k') do (set "UwpName=%%~nxa"&goto :EndSearchUnBlockUWP)
:EndSearchUnBlockUWP
%ifNdef% UwpName exit /b
for /f "tokens=2*" %%a in ('%rq% "%uwpsearch%\%UwpName%" /v "Path" 2^>nul') do set "UwpPath=%%b"
%ifNdef% UwpPath for /f "tokens=2*" %%a in ('%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\InboxApplications\%UwpName%" /v "Path" 2^>nul') do set "UwpPath=%%b"
%ifNdef% UwpPath for /d %%f in ("%windir%\SystemApps\*%UWP%*") do set "UwpPath=%%f\AppXManifest.xml"
%ifNdef% UwpPath for /d %%f in ("%ProgramFiles%\WindowsApps\*%UWP%*") do set "UwpPath=%%f\AppXManifest.xml"
%rd% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\Deprovisioned\%UwpName%" /f >nul 2>&1
%rd% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\%UwpName%" /f >nul 2>&1
for /f "tokens=*" %%a in ('%rq% "HKLM%smw%\%cv%\Appx\AppxAllUserStore" ^| findstr /R /C:"S-1-5-21-*"') do (
	%rd% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\EndOfLife\%%~nxa\%UwpName%" /f >nul 2>&1
	%rd% "HKLM%smw%\%cv%\Appx\AppxAllUserStore\Deleted\EndOfLife\%%~nxa\%UwpName%" /f >nul 2>&1
)
%ifNdef% SAFEBOOT_OPTION %powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Reset-AppxPackage -Package %UwpName%" >nul 2>&1
%ifdef% UwpPath %powershell% -MTA -NoP -NoL -NonI -EP Bypass -c "Add-AppxPackage -%dl%DevelopmentMode -Register '%UwpPath%'" >nul 2>&1
exit /b

:WinRE
set winre=
for /f "delims=" %%i in ('%reagentc% /info ^| findstr /i "Enabled"') do (if not errorlevel 1 (set winre=1))
%ifNdef% winre %reagentc% /enable>nul 2>&1
for /f "delims=" %%i in ('%reagentc% /info ^| findstr /i "Enabled"') do (if not errorlevel 1 (set winre=1))
%ifNdef% winre %msg% "Windows Recovery Environment is missing or cannot be enabled" "В системе отсутсвует Среда восстановления Windows или её невозвможно включить"&exit /b
%reagentc% /boottore>nul 2>&1
manage-bde -protectors %sys%: -%dl% -rebootcount 2
%msg% "The computer will now reboot intoWindows Recovery Environment" "Компьютер сейчас перезагрузиться в Среду восстановления Windows"
%shutdown% /r /f /t 3 /c "Reboot WinRE"
%timeout% 4
exit /b

:SAC
reg load HKLM\sac %sys%:\windows\system32\config\system
reg add HKLM\sac\controlset001\control\ci\policy /v VerifiedAndReputablePolicyState /t REG_DWORD /d 2 /f 
reg add HKLM\sac\controlset001\control\ci\protected /v VerifiedAndReputablePolicyStateMinValueSeen /t REG_DWORD /d 2 /f
reg unload HKLM\sac
reg load HKLM\sac2 %sys%:\windows\system32\config\SOFTWARE
reg add "HKLM\sac2\Microsoft\Windows Defender" /v SacLearningModeSwitch /t REG_DWORD /d 0 /f
reg unload HKLM\sac2
goto :EOF

:MiniHelp
cls
echo.
%msg% "Group Policies" "Групповые политики"
echo.
%msg% "Legally. Documented. Incomplete." "Легально. Документированно. Неполноценно."
%msg% "Only known group policies are applied through the registry" "Применяются только известные групповые политики через реестр"
%msg% "Drivers, services, and background processes are active but do not perform any actions" "Драйверы, службы и фоновые процессы активны, но не выполняют никаких действий"
echo.
%msg% "Policies + Registry Settings" "Политики + Настройки реестра"
echo.
%msg% "Semi-legally. Almost complete." "Полулегально. Почти полноценно."
%msg% "In addition to policies, known tweaks are applied to %dl% various protection aspects" "В дополнение к политикам применяются известные твики отключающие различные аспекты защит"
%msg% "Only drivers and services are active in the background, performing no actions" "Только драйверы и службы активны в фоне, не выполняют никаких действий"
echo.
%msg% "Policies + Settings + Disabling Services and drivers" "Политики + Настройки + Отключение служб и драйверов"
echo.
%msg% "Illegally. Complete." "Нелегально. Полноценно."
%msg% "Also %dl%s the startup of all related services and drivers" "Также отключается запуск всех сопутствующих служб и драйверов"
%msg% "No background activities" "Никаких фоновых активностей"
echo.
%msg% "Policies + Settings + Disabling Services and drivers + Block launch executables" "Политики + Настройки + Отключение служб и драйверов + Блокировка запуска"
echo.
%msg% "Hacker-style. Excessive." "По-хакерски. Избыточно."
%msg% "Blocks the launch of known protection processes by assigning an incorrect debugger in the registry" "Блокируется запуск известных процессов защит с помощью назначения неправильного дебагера в реестре"
%msg% "Helps reduce the risk of enabling the %df%er during a Windows update" "Помогает снизить риск включения защитника при обновлении Windows"
echo.
pause
exit /b
