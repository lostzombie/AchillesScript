::https://github.com/lostzombie/AchillesScript
@echo off
cls&chcp 65001>nul 2>&1&color 0F
dir "%windir%\sysnative">nul 2>&1&&set "sysdir=%windir%\sysnative"||set "sysdir=%windir%\system32"
set "cmd=%sysdir%\cmd.exe"
set "reg=%sysdir%\reg.exe"
set "bcdedit=%sysdir%\bcdedit.exe"
set "sc=%sysdir%\sc.exe"
set "powershell=%sysdir%\WindowsPowerShell\v1.0\powershell.exe"
set "regsvr32=%sysdir%\regsvr32.exe"
set "whoami=%sysdir%\whoami.exe"
set "schtasks=%sysdir%\schtasks.exe"
set "shutdown=%sysdir%\shutdown.exe"
set "timeout=%sysdir%\timeout.exe"
set "reagentc=%sysdir%\reagentc.exe"
set "Script=%~0"
set "pth=%~dp0"
set "arg1=%~1"
set "arg2=%~2"
shift
set "args=%*"
set "tiargs=%args:ti=%"
set "tiargs=%tiargs:~1%"
set "msg=call :2LangMsg"
set "err=call :2LangErr"
set "if=if defined"
set "ifnot=if not defined"
set "else=^|^|"
set "then=^&^&"
set L=ru
set isTrustedInstaller=
set UserSettingDone=
::#############################################################################
(reg query "HKCU\Control Panel\International\User Profile\%L%">nul 2>&1) %then% (set Lang=%L%) %else% (if exist "%sysdir%\%L%-%L%" (set Lang=%L%) else (if exist "C:\Windows\System32\%L%-%L%" (set Lang=%L%)))
%ifnot% Lang (title Achilles' Script) else (title Ахилесов Скрипт)
::Detect is admin account # Определение учетки администратора
%whoami% /groups | find "S-1-5-32-544" >nul 2>&1||%if% Lang (echo Запустите этот файл из под учетной записи с правами администратора)&pause&exit else (echo Run this file under an account with administrator rights)&pause&exit
if not exist "%powershell%" %err% "Error %powershell% file not exist" "Ошибка файл %powershell% не найден"
%msg% "Requesting Administrator privileges..." "Запрос привилегий администратора..."
dir "%windir%\system32\config\systemprofile">nul 2>&1||(%powershell% -ExecutionPolicy Bypass -Command Start-Process %cmd% -ArgumentList '/c', '%Script%' -Verb RunAs&exit)
::Args
%if% arg1 (
	for %%i in (apply multi restore cancel block unblock ti backup point regback reg safeboot winre sac) do if [%arg1%]==[%%i] set "isValidArg=%%i"
	%ifnot% isValidArg %err% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
)
if exist "%pth%hkcu.txt" set UserSettingDone=1
%ifnot% arg1 if exist "%pth%hkcu.txt" del /f /q "%pth%hkcu.txt">nul 2>&1
if "%arg1%"=="apply" (
	%ifnot% SAFEBOOT_OPTION if exist "%pth%hkcu.txt" del /f /q "%pth%hkcu.txt">nul 2>&1&set UserSettingDone=
	set isValidArg=
	%if% arg2 for %%i in (1 2 3 4 policies setting services block) do if [%arg2%]==[%%i] set "isValidArg=%%i"
	%ifnot% isValidArg %err% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	set isValidArg=
	%if% arg2 for %%i in (1 2 3 4) do if [%arg2%]==[%%i] set "isValidArg=%%i"
	%if% isValidArg call :Menu%isValidArg%
	if [%arg2%]==[policies] set Policies=1
	if [%arg2%]==[setting]  set Registry=1
	if [%arg2%]==[services] set Services=1
	if [%arg2%]==[block]    set Block=1
	call :MAIN
)
:multi
set "multi=%~1"
if "%arg1%"=="multi" (
	%ifnot% SAFEBOOT_OPTION if exist "%pth%hkcu.txt" del /f /q "%pth%hkcu.txt">nul 2>&1&set UserSettingDone=
	set isValidArg=
	%if% multi for %%i in (policies setting services block) do if [%multi%]==[%%i] set "isValidArg=%%i"
	%ifnot% isValidArg %err% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"
	if [%isValidArg%]==[policies] set Policies=1
	if [%isValidArg%]==[setting]  set Registry=1
	if [%isValidArg%]==[services] set Services=1
	if [%isValidArg%]==[block]    set Block=1
	shift
	if [%~1] neq [] goto :multi
	call :MAIN
)
if "%arg1%"=="restore" call :Menu6
if "%arg1%"=="block"   if "%arg2%" neq "" call :BlockProcess %arg2%&exit /b
if "%arg1%"=="unblock" if "%arg2%" neq "" call :UnBlockProcess %arg2%&exit /b
if "%arg1%"=="ti"      (call :TrustedRun "%tiargs%"&exit /b %errorlevel%)
if "%arg1%"=="backup"  (
	call :CheckTrusted||(del /f/q "%pth%MySecurityDefaults.reg">nul 2>&1&call :Backup)
	call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit)
	call :Backup
	exit /b
)
if "%arg1%"=="safeboot" (
  %bcdedit% /set {default} safeboot minimal>nul 2>&1||%err% "Error enabling Safe Mode boot" "Ошибка влючения Безопасного режима"
  %msg% "The computer will now reboot into safe mode." "Компьютер сейчас перезагрузиться в безопасный режим."
  %shutdown% -r -f -t 5
  %timeout% 4
  exit
)
if "%arg1%"=="winre"  call :WinRE&exit /b
if "%arg1%"=="sac"    call :SAC&exit /b
if "%arg1%" neq "" %err% "Invalid command line arguments %args%" "Недопустимые аргументы командной строки %args%"&pause&exit
::Detect is Windows version # Определение версии Windows
%msg% "Determining the Windows version..." "Определение версии Windows..."
for /f "tokens=4 delims= " %%v in ('ver') do set "win=%%v"
for /f "tokens=3 delims=." %%v in ('echo  %win%') do set /a "build=%%v"
for /f "tokens=1 delims=." %%v in ('echo  %win%') do set /a "win=%%v"
for /f "tokens=4" %%a in ('ver') do set "WindowsBuild=%%a"
set "WindowsBuild=%WindowsBuild:~5,-1%"
if [%win%] lss [10] %if% Lang (echo Этот скрипт разработан для Windows 10 и новее)&echo.&pause&exit else (echo This Script is designed for Windows 10 and newer)&echo.&pause&exit
for /f "tokens=3,*" %%a in ('%reg% query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "WindowsVersion=%%a %%b"
if [%build%] gtr [22000] set WindowsVersion=%WindowsVersion:10=11%
::#############################################################################
:BEGIN
set isValidItem=
set Item=
call :Screen
%ifnot% Lang (set /p Item="Enter menu item number using your keyboard [0-8]:") else (set /p Item="Введите номер пункта меню используя клавиатуру [0-6]:")
for %%i in (1 2 3 4 5 6 0) do if [%Item%]==[%%i] set "isValidItem=%%i"
%ifnot% isValidItem goto :BEGIN
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
echo Menu 5 Under construction
pause
goto :BEGIN
:Menu6
cls
call :CheckTrusted||call :RestoreCurrentUser
%ifnot% SAFEBOOT_OPTION call :Reboot2Safe
call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit)
call :Restore
call :Reboot2Normal
exit

:MAIN
%ifnot% UserSettingDone (
	%ifnot% arg1 call :Warning
	call :Backup
	%if% Policies call :PoliciesHKCU
	%if% Registry call :RegistryHKCU
	%ifnot% SAFEBOOT_OPTION call :Reboot2Safe
)
call :CheckTrusted||(call :TrustedRun "%Script% %args%"&&exit)
call :Backup
%if% Policies call :Policies
%if% Registry call :Registry
%if% Services call :Services
%if%    Block call :Block
call :Reboot2Normal
exit
::#############################################################################
:2LangMsg
%if% Lang (echo %~2) else (echo %~1)
exit /b
:2LangErr
(%if% Lang (echo %~2) else (echo %~1))&pause>nul 2>&1&exit

:CheckTrusted
dir "%SystemDrive%\System Volume Information">nul 2>&1&&exit /b 0||exit /b 1

:Warning
cls
echo.
if exist "%pth%MySecurityDefaults.reg" (
%msg% "MySecurityDefaults.reg is detected, the backup of the current settings will be skipped." "Обнаружен MySecurityDefaults.reg, будет пропущен бэкап текущих настроек."
%msg% "Delete MySecurityDefaults.reg and restart the script if you want to create a new backup." "Удалите MySecurityDefaults.reg и перезапустите скрипт если хотите создать новый бэкап."
echo.
)
%if% Policies (
%msg% "Group policies will be applied to disable " "Будут применены групповые политики для отключения "
%msg% "Windows Defender, SmartScreen, and Kernel Isolation." "Защитника Windows, SmartScreen, Изоляции ядра."
if exist "%sysdir%\MRT.exe" %msg% "Disable updating and reporting for Malicious Software Removal Tool." "Отключено обновление и отчеты средства удаления вредоносных программ."
echo.
)
%if% Registry (
%msg% "Registry settings will be applied to disable" "Будут применены настройки реестра для отключения"
%msg% "tasks in the scheduler, warnings for downloaded files, file explorer extensions" "задач в планировщике, предупреждения для скачанных файлов, расширения проводника"
echo.
)
%if% Services %msg% "The launch of Defender services and drivers will be disabled." "Будет отключен запуск служб и драйверов защитника."&echo.
%if%    Block %msg% "The launch of defender executable files will be blocked." "Будет заблокирован запуск исполняемых файлов защитника."&echo.
%msg% "The computer will be restarted twice, to safe mode and back." "Компьютер будет перезагружен дважды, в безопасный режим и обратно."&
echo.
%ifnot% Lang (choice /m "You really want to disable Windows defences" /c "yn") else (choice /m "Вы действительно хотите отключить защиты Windows?" /c "дн")
if [%errorlevel%]==[2] goto :BEGIN
cls
exit /b

:Reboot2Safe
%bcdedit% /set {default} safeboot minimal>nul 2>&1||%err% "Error enabling Safe Mode boot" "Ошибка влючения Безопасного режима"
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "cmd.exe /c cd \"%pth%\\"&\"%Script%\" apply %Item%" /f>nul 2>&1||%err% "Error changing Winlogon/Shell Registry parameter" "Ошибка изменения параметра реестра Winlogon/Shell"
%msg% "The computer will now reboot into safe mode." "Компьютер сейчас перезагрузиться в безопасный режим."
%shutdown% -r -f -t 5
%timeout% 4
exit

:Reboot2Normal
%msg% "Restore default boot parameters..." "Восстановление параметров загрузки по умолчанию..."
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe" /f>nul 2>&1
%bcdedit% /deletevalue {default} safeboot>nul 2>&1
%msg% "The computer will now reboot into default mode." "Компьютер сейчас перезагрузиться в обычный режим."
%shutdown% -r -f -t 5
%timeout% 4
exit

:TrustedRun
%msg% "Getting Trusted Installer privileges..." "Получение привилегий Trusted Installer..."
%sc% config "TrustedInstaller" start= demand>nul 2>&1
%sc% start "TrustedInstaller">nul 2>&1
del /f /q "%pth%ti.ps1">nul 2>&1
set "RunAsTrustedInstaller=%~1"
echo $AppFullPath=[System.Environment]::GetEnvironmentVariable('RunAsTrustedInstaller')>>"%pth%ti.ps1"
echo [string]$GetTokenAPI=@'>>"%pth%ti.ps1"
echo using System;using System.ServiceProcess;using System.Diagnostics;using System.Runtime.InteropServices;using System.Security.Principal;namespace WinAPI{internal static class WinBase{[StructLayout(LayoutKind.Sequential)]internal struct SECURITY_ATTRIBUTES{public int nLength;public IntPtr lpSecurityDeScriptor;public bool bInheritHandle;}[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]internal struct STARTUPINFO{public Int32 cb;public string lpReserved;public string lpDesktop;public string lpTitle;public uint dwX;public uint dwY;public uint dwXSize;public uint dwYSize;public uint dwXCountChars;public uint dwYCountChars;public uint dwFillAttribute;public uint dwFlags;public Int16 wShowWindow;public Int16 cbReserved2;public IntPtr lpReserved2;public IntPtr hStdInput;public IntPtr hStdOutput;public IntPtr hStdError;}[StructLayout(LayoutKind.Sequential)]internal struct PROCESS_INFORMATION{public IntPtr hProcess;public IntPtr hThread;public uint dwProcessId;public uint dwThreadId;}}internal static class WinNT{public enum TOKEN_TYPE{TokenPrimary=1,TokenImpersonation}public enum SECURITY_IMPERSONATION_LEVEL{SecurityAnonymous,SecurityIdentification,SecurityImpersonation,SecurityDelegation}[StructLayout(LayoutKind.Sequential,Pack=1)]internal struct TokPriv1Luid{public uint PrivilegeCount;public long Luid;public UInt32 Attributes;}}internal static class Advapi32{public const int SE_PRIVILEGE_ENABLED=0x00000002;public const uint CREATE_NO_WINDOW=0x08000000;public const uint CREATE_NEW_CONSOLE=0x00000010;public const uint CREATE_UNICODE_ENVIRONMENT=0x00000400;public const UInt32 STANDARD_RIGHTS_REQUIRED=0x000F0000;public const UInt32 STANDARD_RIGHTS_READ=0x00020000;public const UInt32 TOKEN_ASSIGN_PRIMARY=0x0001;public const UInt32 TOKEN_DUPLICATE=0x0002;public const UInt32 TOKEN_IMPERSONATE=0x0004;public const UInt32 TOKEN_QUERY=0x0008;public const UInt32 TOKEN_QUERY_SOURCE=0x0010;public const UInt32 TOKEN_ADJUST_PRIVILEGES=0x0020;public const UInt32 TOKEN_ADJUST_GROUPS=0x0040;public const UInt32 TOKEN_ADJUST_DEFAULT=0x0080;public const UInt32 TOKEN_ADJUST_SESSIONID=0x0100;public const UInt32 TOKEN_READ=(STANDARD_RIGHTS_READ^|TOKEN_QUERY);public const UInt32 TOKEN_ALL_ACCESS=(STANDARD_RIGHTS_REQUIRED^|TOKEN_ASSIGN_PRIMARY^|TOKEN_DUPLICATE^|TOKEN_IMPERSONATE^|TOKEN_QUERY^|TOKEN_QUERY_SOURCE^|TOKEN_ADJUST_PRIVILEGES^|TOKEN_ADJUST_GROUPS^|TOKEN_ADJUST_DEFAULT^|TOKEN_ADJUST_SESSIONID);[DllImport("advapi32.dll",SetLastError=true)][return:MarshalAs(UnmanagedType.Bool)]public static extern bool OpenProcessToken(IntPtr ProcessHandle,UInt32 DesiredAccess,out IntPtr TokenHandle);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public extern static bool DuplicateTokenEx(IntPtr hExistingToken,uint dwDesiredAccess,IntPtr lpTokenAttributes,WinNT.SECURITY_IMPERSONATION_LEVEL ImpersonationLevel,WinNT.TOKEN_TYPE TokenType,out IntPtr phNewToken);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]internal static extern bool LookupPrivilegeValue(string lpSystemName,string lpName,ref long lpLuid);[DllImport("advapi32.dll",SetLastError=true)]internal static extern bool AdjustTokenPrivileges(IntPtr TokenHandle,bool DisableAllPrivileges,ref WinNT.TokPriv1Luid NewState,UInt32 Zero,IntPtr Null1,IntPtr Null2);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Unicode)]public static extern bool CreateProcessAsUserW(IntPtr hToken,string lpApplicationName,string lpCommandLine,IntPtr lpProcessAttributes,IntPtr lpThreadAttributes,bool bInheritHandles,uint dwCreationFlags,IntPtr lpEnvironment,string lpCurrentDirectory,ref WinBase.STARTUPINFO lpStartupInfo,out WinBase.PROCESS_INFORMATION lpProcessInformation);[DllImport("advapi32.dll",SetLastError=true)]public static extern bool SetTokenInformation(IntPtr TokenHandle,uint TokenInformationClass,ref IntPtr TokenInformation,int TokenInformationLength);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public static extern bool RevertToSelf();}internal static class Kernel32{[Flags]public enum ProcessAccessFlags:uint{All=0x001F0FFF}[DllImport("kernel32.dll",SetLastError=true)]>>"%pth%ti.ps1"
echo public static extern IntPtr OpenProcess(ProcessAccessFlags processAccess,bool bInheritHandle,int processId);[DllImport("kernel32.dll",SetLastError=true)]public static extern bool CloseHandle(IntPtr hObject);}internal static class Userenv{[DllImport("userenv.dll",SetLastError=true)]public static extern bool CreateEnvironmentBlock(ref IntPtr lpEnvironment,IntPtr hToken,bool bInherit);}public static class ProcessConfig{public static IntPtr DuplicateTokenSYS(IntPtr hTokenSys){IntPtr hProcess=IntPtr.Zero,hToken=IntPtr.Zero,hTokenDup=IntPtr.Zero;int pid=0;string name;bool bSuccess,impersonate=false;try{if(hTokenSys==IntPtr.Zero){bSuccess=RevertToRealSelf();name=System.Text.Encoding.UTF8.GetString(new byte[]{87,73,78,76,79,71,79,78});}else{name=System.Text.Encoding.UTF8.GetString(new byte[]{84,82,85,83,84,69,68,73,78,83,84,65,76,76,69,82});ServiceController controlTI=new ServiceController(name);if(controlTI.Status==ServiceControllerStatus.Stopped){controlTI.Start();System.Threading.Thread.Sleep(5);controlTI.Close();}impersonate=ImpersonateWithToken(hTokenSys);if(!impersonate){return IntPtr.Zero;}}IntPtr curSessionId=new IntPtr(Process.GetCurrentProcess().SessionId);Process process=Array.Find(Process.GetProcessesByName(name),p=^>p.Id^>0);if(process!=null){pid=process.Id;}else{return IntPtr.Zero;}hProcess=Kernel32.OpenProcess(Kernel32.ProcessAccessFlags.All,true,pid);uint DesiredAccess=Advapi32.TOKEN_QUERY^|Advapi32.TOKEN_DUPLICATE^|Advapi32.TOKEN_ASSIGN_PRIMARY;bSuccess=Advapi32.OpenProcessToken(hProcess,DesiredAccess,out hToken);if(!bSuccess){return IntPtr.Zero;}DesiredAccess=Advapi32.TOKEN_ALL_ACCESS;bSuccess=Advapi32.DuplicateTokenEx(hToken,DesiredAccess,IntPtr.Zero,WinNT.SECURITY_IMPERSONATION_LEVEL.SecurityDelegation,WinNT.TOKEN_TYPE.TokenPrimary,out hTokenDup);if(!bSuccess){bSuccess=Advapi32.DuplicateTokenEx(hToken,DesiredAccess,IntPtr.Zero,WinNT.SECURITY_IMPERSONATION_LEVEL.SecurityImpersonation,WinNT.TOKEN_TYPE.TokenPrimary,out hTokenDup);}if(bSuccess){bSuccess=EnableAllPrivilages(hTokenDup);}if(!impersonate){hTokenSys=hTokenDup;impersonate=ImpersonateWithToken(hTokenSys);}if(impersonate){bSuccess=Advapi32.SetTokenInformation(hTokenDup,12,ref curSessionId,4);}}catch(Exception){}finally{if(hProcess!=IntPtr.Zero){Kernel32.CloseHandle(hProcess);}if(hToken!=IntPtr.Zero){Kernel32.CloseHandle(hToken);}bSuccess=RevertToRealSelf();}if(hTokenDup!=IntPtr.Zero){return hTokenDup;}else{return IntPtr.Zero;}}public static bool RevertToRealSelf(){try{Advapi32.RevertToSelf();WindowsImpersonationContext currentImpersonate=WindowsIdentity.GetCurrent().Impersonate();currentImpersonate.Undo();currentImpersonate.Dispose();}catch(Exception){return false;}return true;}public static bool ImpersonateWithToken(IntPtr hTokenSys){try{WindowsImpersonationContext ImpersonateSys=new WindowsIdentity(hTokenSys).Impersonate();}catch(Exception){return false;}return true;}private enum PrivilegeNames{SeAssignPrimaryTokenPrivilege,SeBackupPrivilege,SeIncreaseQuotaPrivilege,SeLoadDriverPrivilege,SeManageVolumePrivilege,SeRestorePrivilege,SeSecurityPrivilege,SeShutdownPrivilege,SeSystemEnvironmentPrivilege,SeSystemTimePrivilege,SeTakeOwnershipPrivilege,SeTrustedCredmanAccessPrivilege,SeUndockPrivilege};private static bool EnableAllPrivilages(IntPtr hTokenSys){WinNT.TokPriv1Luid tp;tp.PrivilegeCount=1;tp.Luid=0;tp.Attributes=Advapi32.SE_PRIVILEGE_ENABLED;bool bSuccess=false;try{foreach(string privilege in Enum.GetNames(typeof(PrivilegeNames))){bSuccess=Advapi32.LookupPrivilegeValue(null,privilege,ref tp.Luid);bSuccess=Advapi32.AdjustTokenPrivileges(hTokenSys,false,ref tp,0,IntPtr.Zero,IntPtr.Zero);}}catch(Exception){return false;}return bSuccess;}public static StructOut CreateProcessWithTokenSys(IntPtr hTokenSys,string AppPath){uint exitCode=0;bool bSuccess;bool bInherit=false;string stdOutString="";IntPtr hReadOut=IntPtr.Zero,hWriteOut=IntPtr.Zero;const uint HANDLE_FLAG_INHERIT=0x00000001;const uint STARTF_USESTDHANDLES=0x00000100;const UInt32 INFINITE=0xFFFFFFFF;IntPtr NewEnvironment=IntPtr.Zero;bSuccess=Userenv.CreateEnvironmentBlock(ref NewEnvironment,hTokenSys,true);uint CreationFlags=Advapi32.CREATE_UNICODE_ENVIRONMENT^|Advapi32.CREATE_NEW_CONSOLE;WinBase.PROCESS_INFORMATION pi=new WinBase.PROCESS_INFORMATION();WinBase.STARTUPINFO si=new WinBase.STARTUPINFO();si.cb=Marshal.SizeOf(si);si.lpDesktop="winsta0\\default";try{bSuccess=ImpersonateWithToken(hTokenSys);bSuccess=Advapi32.CreateProcessAsUserW(hTokenSys,null,AppPath,IntPtr.Zero,IntPtr.Zero,bInherit,(uint)CreationFlags,NewEnvironment,null,ref si,out pi);if(!bSuccess){exitCode=1;}}catch(Exception){}finally{if(pi.hProcess!=IntPtr.Zero){Kernel32.CloseHandle(pi.hProcess);}if(pi.hThread!=IntPtr.Zero){Kernel32.CloseHandle(pi.hThread);}bSuccess=RevertToRealSelf();}StructOut so=new StructOut();so.ProcessId=pi.dwProcessId;so.ExitCode=exitCode;so.StdOut=stdOutString;return so;}[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]public struct StructOut{public uint ProcessId;public uint ExitCode;public string StdOut;}}}>>"%pth%ti.ps1"
echo '@>>"%pth%ti.ps1"
echo if (-not ('WinAPI.ProcessConfig' -as [type] )){$cp=[System.CodeDom.Compiler.CompilerParameters]::new(@('System.dll','System.ServiceProcess.dll'))>>"%pth%ti.ps1"
echo $cp.TempFiles=[System.CodeDom.Compiler.TempFileCollection]::new($DismScratchDirGlobal,$false)>>"%pth%ti.ps1"
echo $cp.GenerateInMemory=$true>>"%pth%ti.ps1"
echo $cp.CompilerOptions='/platform:anycpu /nologo'>>"%pth%ti.ps1"
echo Add-Type -TypeDefinition $GetTokenAPI -Language CSharp -ErrorAction Stop -CompilerParameters $cp}>>"%pth%ti.ps1"
echo $Global:Token_SYS=[WinAPI.ProcessConfig]::DuplicateTokenSYS([System.IntPtr]::Zero)>>"%pth%ti.ps1"
echo if ($Global:Token_SYS -eq [IntPtr]::Zero ){$Exit=$true; Return}>>"%pth%ti.ps1"
echo $Global:Token_TI=[WinAPI.ProcessConfig]::DuplicateTokenSYS($Global:Token_SYS)>>"%pth%ti.ps1"
echo if ($Global:Token_TI -eq [IntPtr]::Zero ){$Exit=$true; Return}>>"%pth%ti.ps1"
echo [WinAPI.ProcessConfig+StructOut] $StructOut=New-Object -TypeName WinAPI.ProcessConfig+StructOut>>"%pth%ti.ps1"
echo $StructOut=[WinAPI.ProcessConfig]::CreateProcessWithTokenSys($Global:Token_TI, $AppFullPath)>>"%pth%ti.ps1"
echo return $StructOut.ExitCode>>"%pth%ti.ps1"
%powershell% -ExecutionPolicy Bypass -File "%pth%ti.ps1">nul 2>&1
set "trusted=%errorlevel%">nul 2>&1
del /f /q "%pth%ti.ps1">nul 2>&1
exit /b %trusted%

:Backup 
if exist "%pth%MySecurityDefaults.reg" goto :EndBackup
call :CheckTrusted&&goto :TrustedBackup
%if% UserSettingDone goto :EndBackup
%msg% "Enabling the RegIdleBackup task in the scheduler..." "Включение задания RegIdleBackup в планировщике..."
%schtasks% /Change /TN "Microsoft\Windows\Registry\RegIdleBackup" /Enable>nul 2>&1&&(echo OK&%msg% "Running RegIdleBackup task from the scheduler..." "Запуск задания RegIdleBackup из планировщика..."&%schtasks% /Run /I /TN "Microsoft\Windows\Registry\RegIdleBackup">nul 2>&1&&echo OK||%msg% "Skip" "Пропуск")||%msg% "Skip" "Пропуск"
%msg% "Creating a recovery point if recovery is enabled..." "Создание точки восстановления, если восстановление включено..."
%powershell% -ExecutionPolicy Bypass-Command "Checkpoint-Computer -DeScription 'Achilles Script' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue"&&echo OK||%msg% "Skip" "Пропуск"
%msg% "Backup settings from the HKCU registry key..." "Бэкап настроек из раздела реестра HKCU..."
call :HKCU_List
call :BackupReg "hkcu.list" "hkcu.txt"
del /f/q "%pth%hkcu.list">nul 2>&1
goto :EndBackup
:TrustedBackup
%msg% "Backup settings from the HKLM registry key..." "Бэкап настроек из раздела реестра HKLM..."
call :HKLM_List
call :BackupReg "hklm.list" "hklm.txt"
del /f/q "%pth%hklm.list">nul 2>&1
copy /b "%pth%hkcu.txt"+"%pth%hklm.txt" "%pth%MySecurityDefaults.reg">nul 2>&1
del /f/q "%pth%hkcu.txt">nul 2>&1
del /f/q "%pth%hklm.txt">nul 2>&1
%msg% "The current settings are saved in %pth%MySecurityDefaults.reg" "Текущие настройки сохранены в %pth%MySecurityDefaults.reg"
:EndBackup
exit /b

:BackupReg
set out="%pth%backup.ps1"
del /f/q %out%>nul 2>&1
echo $I="%pth%%~1">>%out%
echo $F="%pth%%~2">>%out%
echo $O=New-Object System.Text.StringBuilder>>%out%
echo if($F -ne "%pth%hklm.txt"){$O.AppendLine("Windows Registry Editor Version 5.00")^|Out-Null}>>%out%
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
%powershell% -ExecutionPolicy Bypass -File %out%>nul 2>&1
del /f/q %out%>nul 2>&1
exit /b

:Screen
cls
			   echo [36m┌──────────────────────────────────────────┐[0m
			   echo [36m│[96m ┌─┐┌─┐┬ ┬┬┬  ┬  ┌─┐┌─┐┐ ┌─┐┌─┐┬─┐┬┌─┐┌┬┐[0m [36m│[0m
               echo [36m│[96m ├─┤│  ├─┤││  │  ├┤ └─┐  └─┐│  ├┬┘│├─┘ │ [0m [36m│[0m
               echo [36m│[96m ┴ ┴└─┴┴ ┴┴┴─┘┴─┘└─┘└─┘  └─┘└─┘┴└─┴┴   ┴ [0m [36m│[0m
			   echo [36m│[96m                for Windows[0m               [36m│[0m
			   echo [36m└──────────────────────────────────────────┘[0m
%ifnot% Lang  (echo [96m Non distructive disabling Windows defenses[0m
) else (
               echo [96m Неразрушающее отключение защит Windows[0m
)
			   echo [36m┌────────────────────────────┬─────────────┐[0m
               echo [36m│[0m [92mMade with love of Windows*[0m [36m│   [0m[93mver 1.0[0m   [36m│[0m
			   echo [36m└────────────────────────────┴─────────────┘[0m		
               echo [90m *pure unprotected love[0m
		   
echo.
               echo  [4;93m%WindowsVersion% build %WindowsBuild%[0m
echo.
%msg% "Disable defenses using:" "Отключить защиты используя:"
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
echo HKCU:\Software\Microsoft\Windows Security Health\State,AppAndBrowser_EdgeSmartScreenOff>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows Security Health\State,AppAndBrowser_PuaSmartScreenOff>>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows Security Health\State,AppAndBrowser_StoreAppsSmartScreenOff>>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost,EnableWebContentEvaluation>>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost,PreventOverride>>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,Enabled>>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments,SaveZoneInformation>>"%pth%hkcu.list"
echo HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments,ScanWithAntiVirus>>"%pth%hkcu.list"
echo HKCU:\Software\Policies\Microsoft\Edge,SmartScreenEnabled>>"%pth%hkcu.list"
echo HKCU:\Software\Policies\Microsoft\Edge,SmartScreenPuaEnabled>>"%pth%hkcu.list"
exit /b

:HKLM_List
del /f/q "%pth%hklm.list">nul 2>&1
echo HKLM:\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\exefile\shell\open,NoSmartScreen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\exefile\shell\runas,NoSmartScreen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\exefile\shell\runasuser,NoSmartScreen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\0>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\0\win64>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\FLAGS>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\HELPDIR>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\RemovalTools\MpGears,HeartbeatTrackingIndex>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Device security,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications,DisableEnhancedNotifications>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection,FilesBlockedNotificationDisabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection,NoActionNotificationDisabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection,SummaryNotificationDisabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,DisableAntiSpyware>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,DisableAntiVirus>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,HybridModeEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,IsServiceRunning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,ProductStatus>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,ProductType>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,PUAProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,SmartLockerMode>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender,VerifiedAndReputableTrustModeEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\CoreService,DisableCoreService1DSTelemetry>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\CoreService,DisableCoreServiceECSIntegration>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\CoreService,MdDisableResController>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features,EnableCACS>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features,Protection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features,TamperProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features,TamperProtectionSource>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,EnableAdsSymlinkMitigation_MpRamp>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,EnableBmProcessInfoMetastoreMaintenance_MpRamp>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,EnableCIWorkaroundOnCFAEnabled_MpRamp>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MdDisableResController>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpDisablePropBagNotification>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpDisableResourceMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpEnableNoMetaStoreProcessInfoContainer>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpEnablePurgeHipsCache>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_AdvertiseLogonMinutesFeature>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_EnableCommonMetricsEvents>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_EnableImpersonationOnNetworkResourceScan>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_EnablePersistedScanV2>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_Kernel_EnableFolderGuardOnPostCreate>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_Kernel_SystemIoRequestWorkOnBehalfOf>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_MdDisable1ds>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_MdEnableCoreService>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpFC_RtpEnableDefenderConfigMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs,MpForceDllHostScanExeOnOpen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection,DisableAsyncScanOnOpen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection,DisableRealtimeMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection,DpaDisabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,AvgCPULoadFactor>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,DisableArchiveScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,DisableEmailScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,DisableRemovableDriveScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,DisableScanningMappedNetworkDrivesForFullScan>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,DisableScanningNetworkFiles>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Scan,LowCpuPriority>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Spynet,MAPSconcurrency>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Spynet,SpyNetReporting>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Spynet,SpyNetReportingLocation>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Spynet,SubmitSamplesConsent>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR,EnableASRConsumers>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access,EnableControlledFolderAccess>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection,EnableNetworkProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-d.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-fe.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-fe_bd.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-d.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-fe.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-fe_bd.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-d.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-fe.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-fe_bd.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpCmdRun.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpDefenderCoreService.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpSigStub.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsSense.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MRT.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NisSrv.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecHealthUI.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecurityHealthService.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SgrmBroker.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\smartscreen.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\OfflineScannerShell.exe,Debugger>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost,WebThreatDefense>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost,EnableWebContentEvaluation>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer,AicEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer,SmartScreenEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run,SecurityHealth>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance,Enabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run,SecurityHealth>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled,SecurityHealth>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved,{09A47860-11B0-4DA5-AFA5-26D86198A780}>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked,{09A47860-11B0-4DA5-AFA5-26D86198A780}>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\Operational,Enabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\WHC,Enabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer,SettingsPageVisibility>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\MRT,DontOfferThroughWUAU>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\MRT,DontReportInfectionInformation>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter,EnabledV9>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter,PreventOverrideAppRepUnknown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Account protection,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection,DisallowExploitProtectionOverride>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Firewall and network protection,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications,DisableNotifications>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray,HideSystray>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,AllowFastServiceStartup>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,DisableAntiSpyware>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,DisableLocalAdminMerge>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,DisableRoutinelyTakingAction>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,PUAProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,RandomizeScheduleTaskTimes>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,ServiceKeepAlive>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender,ServiceKeepAlive>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions,DisableAutoExclusions>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine,EnableFileHashComputation>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine,MpBafsExtendedTimeout>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine,MpCloudBlockLevel>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine,MpEnablePus>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS,DisableProtocolRecognition>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS,DisableSignatureRetirement>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS,ThrottleDetectionEventsRate>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager,DisableScanningNetworkFiles>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableBehaviorMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableInformationProtectionControl>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableIntrusionPreventionSystem>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableIOAVProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableOnAccessProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableRawWriteNotification>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableRealtimeMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableScanOnRealtimeEnable>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,DisableScriptScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,LocalSettingOverrideDisableBehaviorMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,LocalSettingOverrideDisableIntrusionPreventionSystem>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,LocalSettingOverrideDisableIOAVProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,LocalSettingOverrideDisableOnAccessProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,LocalSettingOverrideDisableRealtimeMonitoring>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,LocalSettingOverrideRealtimeScanDirection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection,RealtimeScanDirection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting,DisableEnhancedNotifications>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting,DisableGenericRePorts>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting,WppTracingComponents>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting,WppTracingLevel>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableArchiveScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableCatchupFullScan>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableCatchupQuickScan>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableEmailScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableHeuristics>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableRemovableDriveScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableReparsePointScanning>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableRestorePoint>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableScanningMappedNetworkDrivesForFullScan>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,DisableScanningNetworkFiles>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,LowCpuPriority>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan,ScanOnlyIfIdle>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,DisableScanOnUpdate>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,DisableScheduledSignatureUpdateOnBattery>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,DisableUpdateOnStartupWithoutEngine>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,ForceUpdateFromMU>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,RealtimeSignatureDelivery>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,ScheduleTime>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,SignatureDisableNotification>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,SignatureUpdateCatchupInterval>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates,UpdateOnStartUp>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen,ConfigureAppInstallControl>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen,ConfigureAppInstallControlEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet,DisableBlockAtFirstSeen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet,LocalSettingOverrideSpynetReporting>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet,SpynetReporting>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet,SubmitSamplesConsent>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration,UILockdown>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR,ExploitGuard_ASR_Rules>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access,EnableControlledFolderAccess>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection,EnableNetworkProtection>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,ConfigureKernelShadowStacksLaunch>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,ConfigureSystemGuardLaunch>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,EnableVirtualizationBasedSecurity>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,HVCIMATRequired>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,HypervisorEnforcedCodeIntegrity>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,LsaCfgFlags>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard,RequirePlatformSecurityFeatures>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\System,EnableSmartScreen>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components,NotifyMalicious>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components,NotifyPasswordReuse>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components,NotifyUnsafeApp>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components,ServiceEnabled>>"%pth%hklm.list"
echo HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy,VerifiedAndReputablePolicyState>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard,EnableVirtualizationBasedSecurity>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard,Locked>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard,RequirePlatformSecurityFeatures>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity,Enabled>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity,HVCIMATRequired>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity,Locked>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity,WasEnabledBy>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity,WasEnabledBySysprep>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks,AuditModeEnabled>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks,Enabled>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks,WasEnabledBy>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Control\Ubpm,CriticalMaintenance_DefenderCleanup>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Control\Ubpm,CriticalMaintenance_DefenderVerification>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger,Start>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger,Start>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\WinDefend>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Allow_In>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Allow_Out>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Block_In>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WebThreatDefSvc_Block_Out>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WindowsDefender-1>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WindowsDefender-2>>"%pth%hklm.list"
echo HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System,WindowsDefender-3>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\MDCoreSvc,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\MsSecFlt,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\MsSecWfp,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\SecurityHealthService,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\Sense,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\SgrmAgent,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\SgrmBroker,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\WdNisDrv,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\WdNisSvc,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\webthreatdefsvc,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\webthreatdefusersvc,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\WinDefend,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\wscsvc,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\wtd,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\WdBoot,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\WdFilter,Start>>"%pth%hklm.list"
echo HKLM:\System\CurrentControlset\Services\MsSecCore,Start>>"%pth%hklm.list"
exit /b

:PoliciesHKCU
%msg% "Applying policies for the current user..." "Применение политик для текущего пользователя..."
%reg% add "HKCU\Software\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKCU\Software\Policies\Microsoft\Edge" /v "SmartScreenPuaEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
exit /b

:Policies
%msg% "Applying group policies..." "Применение групповых политик..." 
::Disabling Defender via Group Policies # Отключение Защитника через групповые политики
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "AllowFastServiceStartup" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableLocalAdminMerge" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "RandomizeScheduleTaskTimes" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" /v "DisableAutoExclusions" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "EnableFileHashComputation" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpBafsExtendedTimeout" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpCloudBlockLevel" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEnablePus" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" /v "DisableProtocolRecognition" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" /v "DisableSignatureRetirement" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" /v "ThrottleDetectionEventsRate" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v "DisableScanningNetworkFiles" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableInformationProtectionControl" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIntrusionPreventionSystem" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRawWriteNotification" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScriptScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableBehaviorMonitoring" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableIOAVProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableIntrusionPreventionSystem" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableOnAccessProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableRealtimeMonitoring" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideRealtimeScanDirection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "RealtimeScanDirection" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableScanOnUpdate" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableScheduledSignatureUpdateOnBattery" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableUpdateOnStartupWithoutEngine" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "RealtimeSignatureDelivery" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleTime" /t REG_DWORD /d "5184" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureDisableNotification" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureUpdateCatchupInterval" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "UpdateOnStartUp" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericRePorts" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "WppTracingComponents" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "WppTracingLevel" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupFullScan" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupQuickScan" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableEmailScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableHeuristics" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRemovableDriveScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableReparsePointScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRestorePoint" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "LowCpuPriority" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "ScanOnlyIfIdle" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" /v "ExploitGuard_ASR_Rules" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" /v "DisallowExploitProtectionOverride" /t REG_DWORD /d 1 /f>nul 2>&1
::Disabling SmartScreen via Group Policies # Отключение SmartScreen через групповые политики через групповые политики
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "PreventOverrideAppRepUnknown" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "ServiceEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyUnsafeApp" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyMalicious" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyPasswordReuse" /t REG_DWORD /d 0 /f>nul 2>&1
::Disbaling Virtualization Based Security via Group Policies # Отключение безопасности на основе виртуализации ядра
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "LsaCfgFlags" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "ConfigureSystemGuardLaunch" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "ConfigureKernelShadowStacksLaunch" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d 0 /f>nul 2>&1
::
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Account protection" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Family options" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Firewall and network protection" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
::Disable updating and reporting for Windows Malicious Software Removal Tool # Отключить обновление и создание отчетов для средства удаления вредоносных программ Windows
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontReportInfectionInformation /t REG_DWORD /d 1 /f>nul 2>&1
::Hiding security setting # Скрытие параметров безопасности
set "HidePath=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
for /f "usebackq tokens=2*" %%A in (`reg query "%HidePath%" /v "SettingsPageVisibility" 2^>nul`) do (
    set "SettingsPageVisibility=%%B"
)
%ifnot% SettingsPageVisibility %reg% add "%HidePath%" /v "SettingsPageVisibility" /t REG_SZ /d "hide:windowsdefender" /f>nul 2>&1
echo %SettingsPageVisibility% | find /i "windowsdefender">nul 2>&1&&goto :EndHideSetting
%reg% add "%HidePath%" /v "SettingsPageVisibility" /t REG_SZ /d "%SettingsPageVisibility%;windowsdefender" /f>nul 2>&1
:EndHideSetting
exit /b

:RegistryHKCU
%msg% "Applying registry settings for the current user..." "Применение настроек реестра для текущего пользователя..." 
::Disable tasks # Отключение задач
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable>nul 2>&1
::Disable SmartScreen for Microsoft Store apps # Отключение SmartScreen для приложений Microsoft Store
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d 0 /f>nul 2>&1
::SmartScreen setting in Security Health # Настройки SmartScreen в центре безопасности
%reg% add "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_EdgeSmartScreenOff" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_StoreAppsSmartScreenOff" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_PuaSmartScreenOff" /t REG_DWORD /d 1 /f>nul 2>&1
::Disable warning and scanning for downloaded files # Отключение предупреждения и сканирования для скачанных файлов
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "ScanWithAntiVirus" /t REG_DWORD /d 1 /f>nul 2>&1
::Disabling notifications # Отключение уведомлений
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
exit /b

:Registry
%msg% "Applying registry settings..." "Применение настроек реестра..."
::Disable SmartScreen for Microsoft Store apps # Отключение SmartScreen для приложений Microsoft Store
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f>nul 2>&1
::Disable shell extensions # Отключение расширений проводника
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t REG_SZ /d "" /f>nul 2>&1
%regsvr32% /u "%SystemDrive%\Program Files\Windows Defender\shellext.dll" /s>nul 2>&1
::Disable warning and scanning for downloaded files # Отключение предупреждения и сканирования для скачанных файлов
%reg% add "HKLM\SOFTWARE\Classes\exefile\shell\open" /v "NoSmartScreen" /t REG_SZ /d "" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\exefile\shell\runas" /v "NoSmartScreen" /t REG_SZ /d "" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\exefile\shell\runasuser" /v "NoSmartScreen" /t REG_SZ /d "" /f>nul 2>&1
::Disabling and Defender settings to minimum values in the Registry # Отключение и перевод в минимальные значения настроек Защитника в реестре
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "FilesBlockedNotificationDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "NoActionNotificationDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "SummaryNotificationDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "HybridModeEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "IsServiceRunning" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductType" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService">nul 2>&1||goto :SkipCoreService
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "DisableCoreService1DSTelemetry" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "DisableCoreServiceECSIntegration" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "MdDisableResController" /t REG_DWORD /d 1 /f>nul 2>&1
:SkipCoreService
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "EnableCACS" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "Protection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\SOFTWARE\Microsoft\Windows Defender\EcsConfigs">nul 2>&1||goto :SkipEcsConfigs
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "EnableAdsSymlinkMitigation_MpRamp" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "EnableBmProcessInfoMetastoreMaintenance_MpRamp" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "EnableCIWorkaroundOnCFAEnabled_MpRamp" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MdDisableResController" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpDisablePropBagNotification" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpDisableResourceMonitoring" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpEnableNoMetaStoreProcessInfoContainer" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpEnablePurgeHipsCache" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_AdvertiseLogonMinutesFeature" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_EnableCommonMetricsEvents" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_EnableImpersonationOnNetworkResourceScan" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_EnablePersistedScanV2" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_Kernel_EnableFolderGuardOnPostCreate" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_Kernel_SystemIoRequestWorkOnBehalfOf" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_MdDisable1ds" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_MdEnableCoreService" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_RtpEnableDefenderConfigMonitoring" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpForceDllHostScanExeOnOpen" /t REG_DWORD /d 0 /f>nul 2>&1
:SkipEcsConfigs
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAsyncScanOnOpen" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DpaDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /t REG_DWORD /d "10" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableEmailScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableRemovableDriveScanning" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "LowCpuPriority" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "MAPSconcurrency" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_MULTI_SZ /d "https://0.0.0.0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" /v "EnableASRConsumers" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t REG_DWORD /d 0 /f>nul 2>&1
::Disable Security Center Autorun # Отключение автозапуска центра безопасности
%reg% query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth">nul 2>&1&&(
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "SecurityHealth" /t REG_EXPAND_SZ /d "^%windir^%\system32\SecurityHealthSystray.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "FFFFFFFFFFFFFFFFFFFFFFFF" /f>nul 2>&1
)
::Disabling notifications # Отключение уведомлений
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
::Disabling SmartAppControl # Отключение Интелектуального управления приложениями
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f>nul 2>&1
::%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Protected" /v "VerifiedAndReputablePolicyStateMinValueSeen" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "SmartLockerMode" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "VerifiedAndReputableTrustModeEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
::Disbaling Virtualization Based Security # Отключение безопасности на основе виртуализации ядра
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Device security" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "WasEnabledBy" /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "WasEnabledBySysprep" /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "RequirePlatformSecurityFeatures" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "Locked" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "HVCIMATRequired" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Locked" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "AuditModeEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "WasEnabledBy" /t REG_DWORD /d 4 /f>nul 2>&1
::Disabling events and logs # Отключение логов и событий
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\Operational" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\WHC" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
::Delete WebThreat and Defender firewall rules groups # Удаление групп правил файрволла WebThreat и Защитника
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-1" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-2" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-3" /f>nul 2>&1
::Delete Defender's tasks from Background Process Manager setting # Удаление задач Защиткника из настроек Диспетчера фоновых процессов
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderCleanup" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderVerification" /f>nul 2>&1
::Delete registration of Smartscreen # Удаление регистрации SmartScreen
%reg% delete "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
::Disable SmartScreen for apps and files # Отключение SmartScreen для приложений и файлов
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AicEnabled" /t REG_SZ /d "Anywhere" /f>nul 2>&1
::Disabling the startup of the Defender service in safe mode # Отключение запуска службы Защитника в безопасном режиме
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\WinDefend" /f>nul 2>&1
exit /b

:Services
%msg% "Disabling the launch of services and drivers..." "Отключение запуска служб и драйверов..."
for %%s in (WinDefend MDCoreSvc WdNisSvc Sense wscsvc SgrmBroker SecurityHealthService webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdFilter SgrmAgent MsSecWfp MsSecFlt MsSecCore wtd) do (
%reg% query "HKLM\System\CurrentControlset\Services\%%~s">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\%%~s" /v "Start" /t REG_DWORD /d 4 /f>nul 2>&1
)
::Delete WebThreatDefense from Svchost launch list # Удаление WebThreatDefense из списка запуска через Svchost
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurentVersion\Svchost" /v "WebThreatDefense" /f>nul 2>&1
exit /b

:Block
%msg% "Block process launch via fake Debugger" "Блокировка запуска процессов через поддельный отладчик"
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpCmdRun.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpDefenderCoreService.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NisSrv.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsSense.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SgrmBroker.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecHealthUI.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecurityHealthService.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\smartscreen.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpSigStub.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\OfflineScannerShell.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-d.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-fe.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-fe_bd.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-d.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-fe.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-fe_bd.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-d.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-fe.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-fe_bd.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
if exist "%sysdir%\MRT.exe" %reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MRT.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
exit /b

:BlockProcess
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
exit /b %errorlevel%

:UnBlockProcess
set "unbl=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%~1"
%reg% delete "%unbl%" /v "Debugger" /f>nul 2>&1
%reg% query "%unbl%" /v *>nul 2>&1
if %errorlevel%==1 %reg% delete "%unbl%" /f>nul 2>&1
exit /b %errorlevel%

:RestoreCurrentUser
%regsvr32% /i "%SystemDrive%\Program Files\Windows Defender\shellext.dll" /s>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Enable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Enable>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_EdgeSmartScreenOff" /f>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_PuaSmartScreenOff" /f>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_StoreAppsSmartScreenOff" /f>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /f>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f>nul 2>&1
%reg% delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /f>nul 2>&1
%reg% delete "HKCU\Software\Policies\Microsoft\Edge" /f>nul 2>&1
if exist "%pth%MySecurityDefaults.reg" (
	%msg% "Restore %pth%MySecurityDefaults.reg" "Восстановление %pth%MySecurityDefaults.reg"
	%reg% import "%pth%MySecurityDefaults.reg">nul 2>&1
)
exit /b

:Restore
%msg% "Restore default setting..." "Восстановление настроек по умолчанию..."
set "HidePath=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
for /f "usebackq tokens=2*" %%A in (`reg query "%HidePath%" /v "SettingsPageVisibility" 2^>nul`) do (
    set "SettingsPageVisibility=%%B"
)
%ifnot% SettingsPageVisibility goto :SkipRestoreVisibility
echo %SettingsPageVisibility% | find /i "windowsdefender">nul 2>&1&&goto :SkipRestoreVisibility
set SettingsPageVisibility=%SettingsPageVisibility:windowsdefender;=%
set SettingsPageVisibility=%SettingsPageVisibility:windowsdefender=%
if "%SettingsPageVisibility%"=="hide:" set SettingsPageVisibility=
%reg% add "%HidePath%" /v "SettingsPageVisibility" /t REG_SZ /d "%SettingsPageVisibility%" /f>nul 2>&1
:SkipRestoreVisibility
%reg% add "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t REG_SZ /d "SmartScreen" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t REG_SZ /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /ve /t REG_SZ /d "%windir%\System32\smartscreenps.dll" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Both" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32" /ve /t REG_SZ /d "%windir%\System32\smartscreen.exe" /f>nul 2>&1
%ifnot% ProgramFiles(x86) goto :SkipRestoreSmartscreen
%reg% add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t REG_SZ /d "SmartScreen" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t REG_SZ /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /ve /t REG_SZ /d "C:\Windows\System32\smartscreenps.dll" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\InProcServer32" /v "ThreadingModel" /t REG_SZ /d "Both" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}\LocalServer32" /ve /t REG_SZ /d "%windir%\System32\smartscreen.exe" /f>nul 2>&1
:SkipRestoreSmartscreen
%reg% delete "HKLM\SOFTWARE\Classes\exefile\shell\open" /v "NoSmartScreen" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Classes\exefile\shell\runas" /v "NoSmartScreen" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Classes\exefile\shell\runasuser" /v "NoSmartScreen" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\RemovalTools\MpGears" /v "HeartbeatTrackingIndex" /t REG_DWORD /d "2" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Device security" /v "UILockdown" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "FilesBlockedNotificationDisabled" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "NoActionNotificationDisabled" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "SummaryNotificationDisabled" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "HybridModeEnabled" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "IsServiceRunning" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductType" /t REG_DWORD /d "2" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d "2" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "SmartLockerMode" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "VerifiedAndReputableTrustModeEnabled" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "SacLearningModeSwitch" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% query "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService">nul 2>&1||goto :SkipRestoreCoreService
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "DisableCoreService1DSTelemetry" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "DisableCoreServiceECSIntegration" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "MdDisableResController" /t REG_DWORD /d "0" /f>nul 2>&1
:SkipRestoreCoreService
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "EnableCACS" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "Protection" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d "5" /f>nul 2>&1
%reg% query "HKLM\SOFTWARE\Microsoft\Windows Defender\EcsConfigs">nul 2>&1||goto :SkipRestoreEcsConfigs
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "EnableAdsSymlinkMitigation_MpRamp" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "EnableBmProcessInfoMetastoreMaintenance_MpRamp" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "EnableCIWorkaroundOnCFAEnabled_MpRamp" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MdDisableResController" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpDisablePropBagNotification" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpDisableResourceMonitoring" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpEnableNoMetaStoreProcessInfoContainer" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpEnablePurgeHipsCache" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_AdvertiseLogonMinutesFeature" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_EnableCommonMetricsEvents" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_EnableImpersonationOnNetworkResourceScan" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_EnablePersistedScanV2" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_Kernel_EnableFolderGuardOnPostCreate" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_Kernel_SystemIoRequestWorkOnBehalfOf" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_MdDisable1ds" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_MdEnableCoreService" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpFC_RtpEnableDefenderConfigMonitoring" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features\EcsConfigs" /v "MpForceDllHostScanExeOnOpen" /t REG_DWORD /d "1" /f>nul 2>&1
:SkipRestoreEcsConfigs
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAsyncScanOnOpen" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DpaDisabled" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AvgCPULoadFactor" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableEmailScanning" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableRemovableDriveScanning" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "LowCpuPriority" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "MAPSconcurrency" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d "2" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SpyNetReportingLocation" /t REG_SZ /d "SOAP:https://wdcp.microsoft.com/WdCpSrvc.asmx SOAP:https://wdcpalt.microsoft.com/WdCpSrvc.asmx REST:https://wdcp.microsoft.com/wdcp.svc/submitReport REST:https://wdcpalt.microsoft.com/wdcp.svc/submitReport BOND:https://wdcp.microsoft.com/wdcp.svc/bond/submitreport BOND:https://wdcpalt.microsoft.com/wdcp.svc/bond/submitreport" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" /v "EnableASRConsumers" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t REG_DWORD /d "0" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-d.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-fe.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpam-fe_bd.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-d.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-fe.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpas-fe_bd.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-d.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-fe.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\mpav-fe_bd.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpCmdRun.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpDefenderCoreService.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpSigStub.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SgrmBroker.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe" /v "Debugger" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsSense.exe" /v "Debugger" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecHealthUI.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NisSrv.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecurityHealthService.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\smartscreen.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /v "WebThreatDefense" /t REG_SZ /d "webthreatdefsvc" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AicEnabled" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "040000000000000000000000" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /t REG_SZ /d "C:\Windows\system32\SecurityHealthSystray.exe" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t REG_SZ /d "EPP" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\Operational" /v "Enabled" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\WHC" /v "Enabled" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /ve /t REG_SZ /d "SmartScreen" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /v "AppID" /t REG_SZ /d "{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\ControlSet001\Control\CI\Protected" /v "VerifiedAndReputablePolicyStateMinValueSeen" /t REG_DWORD /d "2" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Protected" /v "VerifiedAndReputablePolicyStateMinValueSeen" /t REG_DWORD /d "2" /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "Locked" /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%reg% delete "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderCleanup" /t REG_SZ /d "NT Task\Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderVerification" /t REG_SZ /d "NT Task\Microsoft\Windows\Windows Defender\Windows Defender Verification" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "1" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /t REG_SZ /d "v2.0|Action=Allow|Dir=In|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|LPort=443|Protocol=6|Name=Allow WebThreatDefSvc to receive from port 443|" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /t REG_SZ /d "v2.0|Action=Allow|Dir=Out|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|RPort=443|Protocol=6|Name=Allow WebThreatDefSvc to send to port 443|" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /t REG_SZ /d "v2.0|Action=Block|Dir=In|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|Name=Block inbound traffic to WebThreatDefSvc|" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /t REG_SZ /d "v2.0|Action=Block|Dir=Out|App=%%SystemRoot%%\system32\svchost.exe|Svc=WebThreatDefSvc|Name=Block outbound traffic to WebThreatDefSvc|" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-1" /t REG_SZ /d "v2.0|Action=Allow|Active=TRUE|Dir=Out|Protocol=6|App=%%ProgramFiles%%\Windows Defender\MsMpEng.exe|Svc=WinDefend|Name=Allow Out TCP traffic from WinDefend|" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-2" /t REG_SZ /d "v2.0|Action=Block|Active=TRUE|Dir=In|App=%%ProgramFiles%%\Windows Defender\MsMpEng.exe|Svc=WinDefend|Name=Block All In traffic to WinDefend|" /f>nul 2>&1
%reg% add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-3" /t REG_SZ /d "v2.0|Action=Block|Active=TRUE|Dir=Out|App=%%ProgramFiles%%\Windows Defender\MsMpEng.exe|Svc=WinDefend|Name=Block All Out traffic from WinDefend|" /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\MDCoreSvc">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\MDCoreSvc" /v "Start" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\MsSecCore">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\MsSecCore" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\MsSecFlt">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\MsSecFlt" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\MsSecWfp">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\MsSecWfp" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\SecurityHealthService">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\Sense">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\Sense" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\SgrmAgent">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\SgrmAgent" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\SgrmBroker">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\SgrmBroker" /v "Start" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\WdBoot">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\WdBoot" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\WdFilter">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\WdFilter" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\WdNisDrv">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\WdNisSvc">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\WdNisSvc" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\webthreatdefsvc">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\webthreatdefsvc" /v "Start" /t REG_DWORD /d 3 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\webthreatdefusersvc">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\webthreatdefusersvc" /v "Start" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\WinDefend">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\WinDefend" /v "Start" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\wscsvc">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\wscsvc" /v "Start" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% query "HKLM\System\CurrentControlset\Services\wtd">nul 2>&1&&%reg% add "HKLM\System\CurrentControlset\Services\wtd" /v "Start" /t REG_DWORD /d 2 /f>nul 2>&1
if exist "%pth%MySecurityDefaults.reg" (
	%msg% "Restore %pth%MySecurityDefaults.reg" "Восстановление %pth%MySecurityDefaults.reg"
	%reg% import "%pth%MySecurityDefaults.reg">nul 2>&1
)
exit /b

:WinRE
set winre=
for /f "delims=" %%i in ('%reagentc% /info ^| findstr /i "Enabled"') do (if not errorlevel 1 (set winre=1))
%ifnot% winre %reagentc% /enable>nul 2>&1
for /f "delims=" %%i in ('%reagentc% /info ^| findstr /i "Enabled"') do (if not errorlevel 1 (set winre=1))
%ifnot% winre %msg% "Windows Recovery Environment is missing or cannot be enabled" "В системе отсутсвует Среда восстановления Windows или её невозвможно включить"&exit /b
%reagentc% /boottore>nul 2>&1
manage-bde -protectors c: -disable -rebootcount 2>nul 2>&1
%msg% "The computer will now reboot intoWindows Recovery Environment" "Компьютер сейчас перезагрузиться в Среду восстановления Windows"
%shutdown% -r -f -t 5
%timeout% 4
exit /b

:SAC
reg load HKLM\sac c:\windows\system32\config\system
reg add hklm\sac\controlset001\control\ci\policy /v VerifiedAndReputablePolicyState /t REG_DWORD /d {VALUE} /f 
reg add hklm\sac\controlset001\control\ci\protected /v VerifiedAndReputablePolicyStateMinValueSeen /t REG_DWORD /d {VALUE} /f
reg unload hklm\sac
reg load HKLM\sac2 C:\windows\system32\config\SOFTWARE
reg add "hklm\sac2\Microsoft\Windows Defender" /v SacLearningModeSwitch /t REG_DWORD /d 0
reg unload hklm\sac2
exit /b