@echo off
cls
::Switch codepage to unicode
::Переключение кодировку на юникод
chcp 65001>nul 2>&1
::Change background and font colors
::Изменение цвета фона и шрифта
color 0F
::Init x64 system utils
::Назначение 64х битных системных утилит
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
set "script=%~0"
set "param=%~1"
::Check russian keyboard layout
::Проверка наличия русской раскладки
%reg% query "HKCU\Control Panel\International\User Profile\ru">nul 2>&1&&set RU=ru
::Set title
::Установка заголовка
if defined RU (title Ахилесов Скрипт) else (title Achilles' Script)
::Check if bath launched in safe boot mode
::Проверяем запущен ли скрипт в безопасном режиме
if not defined SAFEBOOT_OPTION goto :SKIPSAFE
 if [%param%] == [] if defined RU (echo Запустите скрипт в нормальном режиме, скрипт сам перезагрузится в безопасный режим&pause&exit) else (echo Launch the script in normal mode, the script itself will restart into a safe mode&pause&exit)
::Restore default boot parameters
::Восстановление параметров стандартной загрузки
 %reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe" /f>nul 2>&1
 %bcdedit% /deletevalue {default} safeboot>nul 2>&1
 dir "%SystemDrive%\System Volume Information">nul 2>&1||(call :TRUSTED&&exit)
:SKIPSAFE
if [%param%] neq [] if [%param%] neq [1] if [%param%] neq [2] if [%param%] neq [3] if [%param%] neq [4] if [%param%] neq [5] if [%param%] neq [6] if [%param%] neq [7] if [%param%] neq [8] exit
if [%param%] neq [] set menu=%param%&goto :MENU%param%
::Detect is Windows version
::Определение версии Windows
for /f "tokens=4 delims= " %%v in ('ver') do set "win=%%v"
for /f "tokens=3 delims=." %%v in ('echo  %win%') do set /a "build=%%v"
for /f "tokens=1 delims=." %%v in ('echo  %win%') do set /a "win=%%v"
for /f "tokens=4" %%a in ('ver') do set "WindowsBuild=%%a"
set "WindowsBuild=%WindowsBuild:~5,-1%"
if [%win%] lss [10] if defined RU (echo Этот скрипт разработан для Windows 10 и новее)&echo.&pause&exit else (echo This script is designed for Windows 10 and newer)&echo.&pause&exit
::Detect is admin account
::Определение учетки администратора
%whoami% /groups | find "S-1-5-32-544" >nul 2>&1||if defined RU (echo Запустите этот файл из под учетной записи с правами администратора)&pause&exit else (echo Run this file under an account with administrator rights)&pause&exit
::Check if exist %sysdir%\WindowsPowerShell\v1.0\powershell.exe or Windows broken
::Проверка существует ли %sysdir%\WindowsPowerShell\v1.0\powershell.exe или Windows поломана
if not exist "%powershell%" if defined RU (echo Ошибка файл %powershell% не найден&pause&exit) else (echo Error %powershell% file not exist&pause&exit)
::Check if you have administrator rights and restart with a UAC prompt if you do not have them
::Проверка наличия прав администратора и перезапуск в запросом UAC в случае их отсутсвия
dir "%windir%\system32\config\systemprofile">nul 2>&1||(%powershell% -ExecutionPolicy Bypass -Command Start-Process %cmd% -ArgumentList '/c', '%script%' -Verb RunAs&exit)
::Main screen and menu
::Главный экран и меню
for /f "tokens=3,*" %%a in ('%reg% query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do set "WindowsVersion=%%a %%b"
if [%build%] gtr [22000] set WindowsVersion=%WindowsVersion:10=11%
:MAIN
cls
			   echo [36m┌──────────────────────────────────────────┐[0m
			   echo [36m│ [96m┌─┐┌─┐┬ ┬┬┬  ┬  ┌─┐┌─┐┐ ┌─┐┌─┐┬─┐┬┌─┐┌┬┐[0m [36m│[0m
               echo [36m│ [96m├─┤│  ├─┤││  │  ├┤ └─┐  └─┐│  ├┬┘│├─┘ │ [0m [36m│[0m
               echo [36m│ [96m┴ ┴└─┴┴ ┴┴┴─┘┴─┘└─┘└─┘  └─┘└─┘┴└─┴┴   ┴ [0m [36m│[0m
			   echo [36m│                [96mfor Windows[0m               [36m│[0m
			   echo [36m└──────────────────────────────────────────┘[0m
if defined RU (echo  [96mНеразрушающее отключение защит Windows[0m
) else (
               echo [96m Non distructive disabling Windows defenses [0m)
			   echo [36m┌────────────────────────────┬─────────────┐[0m
               echo [36m│[0m [92mMade with love of Windows*[0m [36m│   [0m[93mver 1.0[0m   [36m│[0m
			   echo [36m└────────────────────────────┴─────────────┘[0m		
               echo [90m *pure unprotected love[0m			   
		   
echo.
               echo  [4;93m%WindowsVersion% build %WindowsBuild%[0m
echo.
if defined RU (echo  Отключить защиты используя:) else (echo  Disable defenses using:)
echo.
if defined RU (echo  [92m[1][0m Групповые политики)                                                       else (echo  [92m[1][0m Group Policies)
if defined RU (echo  [92m[2][0m Настройки реестра)                                                        else (echo  [92m[2][0m Registry Settings)
if defined RU (echo  [92m[3][0m Политики + Настройки)                                                     else (echo  [92m[3][0m Policies + Settings)
if defined RU (echo  [92m[4][0m Политики + Настройки + Отключение служб и драйверов)                      else (echo  [92m[4][0m Policies + Settings + Disabling services and drivers)
if defined RU (echo  [92m[5][0m Политики + Настройки + Отключение служб и драйверов + Блокировка запуска) else (echo  [92m[5][0m Policies + Settings + Disabling services and drivers + Block launch executables)
if defined RU (echo [36m─────────────────────────────────────────────────────────────────────────────[0m
)        else (echo [36m────────────────────────────────────────────────────────────────────────────────────[0m)
if defined RU (echo  [93m[6][0m Помощь)                     else (echo  [93m[6][0m Info)
if defined RU (echo  [93m[7][0m Восстановить по умолчанию)  else (echo  [93m[7][0m Restore Defaults)
if defined RU (echo  [93m[8][0m Сохранить текущие настройки) else (echo  [93m[8][0m Save current settings)
if defined RU (echo  [93m[0][0m Выход)                      else (echo  [93m[0][0m Exit)
echo.
if defined RU (set /p menu="Введите номер пункта меню используя клавиатуру [0-8]:") else (set /p menu="Enter menu item number using your keyboard [0-8]:")
if [%menu%] neq [0] if [%menu%] neq [1] if [%menu%] neq [2] if [%menu%] neq [3] if [%menu%] neq [4] if [%menu%] neq [5] if [%menu%] neq [6] if [%menu%] neq [7] if [%menu%] neq [8] goto :MAIN
if [%menu%] == [0] exit
if [%menu%] == [1] call :MENU1
if [%menu%] == [2] call :MENU2
if [%menu%] == [3] call :MENU3
if [%menu%] == [4] call :MENU4
if [%menu%] == [5] call :MENU5
if [%menu%] == [6] call :MENU6
if [%menu%] == [7] call :MENU7
if [%menu%] == [8] call :MENU8

:MENU1
if [%param%] == [] call :WARNING
call :BACKUP
call :POLICIES
if defined RU (set "msg=Компьютер сейчас перезагрузится") else (set "msg=The computer will now reboot")
echo.&echo %msg%
%shutdown% -r -f -t 4 -c "%msg%"
%timeout% 3
exit

:MENU2
if not defined SAFEBOOT_OPTION (
 if [%param%] == [] call :WARNING
 call :BACKUP
 call :SETTING1
 call :REBOOT2SAFE
)
call :SETTING2
call :REBOOT2NORMAL

:MENU3
if not defined SAFEBOOT_OPTION (
 if [%param%] == [] call :WARNING
 call :BACKUP
 call :POLICIES
 call :SETTING1
 call :REBOOT2SAFE
)
call :SETTING2
call :REBOOT2NORMAL

:MENU4
if not defined SAFEBOOT_OPTION (
 if [%param%] == [] call :WARNING
 call :BACKUP
 call :POLICIES
 call :SETTING1
 call :REBOOT2SAFE
)
call :SETTING2
call :SERVICES
call :REBOOT2NORMAL

:MENU5
if not defined SAFEBOOT_OPTION (
 if [%param%] == [] call :WARNING
 call :POLICIES
 call :SETTING1
 call :REBOOT2SAFE
)
call :SETTING2
call :SERVICES
call :BLOCK
call :REBOOT2NORMAL

:MENU6
echo Menu 6 Under construction
exit /b

:MENU7
echo Menu 7 Under construction
exit /b

:MENU8
echo Menu 8 Under construction
exit /b

:WARNING
cls
echo.
if defined RU (echo Компьютер будет перезагружен.) else (echo The computer will be rebooted.)
echo.
if defined RU (choice /m "Вы действительно хотите отключить защиты Windows?" /c "дн") else (choice /m "You really want to disable Windows defences" /c "yn")
if [%errorlevel%]==[2] goto :MAIN
exit /b

:REBOOT2SAFE
::Enabling Safe Mode Boot
::Включение загрузки в безопасный режим
%bcdedit% /set {default} safeboot minimal>nul 2>&1||(echo.&echo [91mError enabling Safe Mode boot[0m&echo.&pause&exit)
::Add to autorun and enable auto logon
::Добавление в автозагрузку и включение автовхода в систему
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "%script% %menu%" /f>nul 2>&1||(echo.&echo [91mError add parameters in registry [Shell][0m&echo.&pause&exit)
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d 1 /f>nul 2>&1||(echo.&echo [91mError add parameters in registry [AutoAdminLogon][0m&echo.&pause&exit)
::Restart
::Перезагрузка
if defined RU (set "msg=Компьютер сейчас перезагрузиться в безопасный режим") else (set "msg=The computer will now reboot into safe mode")
cls
echo.
echo %msg%
%shutdown% -r -f -t 4 -c "%msg%"
%timeout% 3
exit

:REBOOT2NORMAL
::Reboot
::Перезагрузка
if defined RU (set "msg=Компьютер сейчас перезагрузиться в обычный режим") else (set "msg=The computer will now reboot into default mode")
echo %msg%
%shutdown% -r -f -t 4 -c "%msg%"
%timeout% 3
exit

:TRUSTED
::Getting Trusted Installer rights
::Получение прав Trusted Installer
%sc% config RpcEptMapper start= auto>nul 2>&1
%sc% start RpcEptMapper>nul 2>&1
%sc% config DcomLaunch start= auto>nul 2>&1
%sc% start DcomLaunch>nul 2>&1
%sc% config RpcSs start= auto>nul 2>&1
%sc% start RpcSs>nul 2>&1
%sc% config TrustedInstaller start= demand>nul 2>&1
%sc% start TrustedInstaller>nul 2>&1
del /f /q "%~dp0ti.ps1">nul 2>&1
set RunAsTrustedInstaller="%script% %param%"
echo $AppFullPath=[System.Environment]::GetEnvironmentVariable('RunAsTrustedInstaller')>>"%~dp0ti.ps1"
echo [string]$GetTokenAPI=@'>>"%~dp0ti.ps1"
echo using System;using System.ServiceProcess;using System.Diagnostics;using System.Runtime.InteropServices;using System.Security.Principal;namespace WinAPI{internal static class WinBase{[StructLayout(LayoutKind.Sequential)]internal struct SECURITY_ATTRIBUTES{public int nLength;public IntPtr lpSecurityDescriptor;public bool bInheritHandle;}[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]internal struct STARTUPINFO{public Int32 cb;public string lpReserved;public string lpDesktop;public string lpTitle;public uint dwX;public uint dwY;public uint dwXSize;public uint dwYSize;public uint dwXCountChars;public uint dwYCountChars;public uint dwFillAttribute;public uint dwFlags;public Int16 wShowWindow;public Int16 cbReserved2;public IntPtr lpReserved2;public IntPtr hStdInput;public IntPtr hStdOutput;public IntPtr hStdError;}[StructLayout(LayoutKind.Sequential)]internal struct PROCESS_INFORMATION{public IntPtr hProcess;public IntPtr hThread;public uint dwProcessId;public uint dwThreadId;}}internal static class WinNT{public enum TOKEN_TYPE{TokenPrimary=1,TokenImpersonation}public enum SECURITY_IMPERSONATION_LEVEL{SecurityAnonymous,SecurityIdentification,SecurityImpersonation,SecurityDelegation}[StructLayout(LayoutKind.Sequential,Pack=1)]internal struct TokPriv1Luid{public uint PrivilegeCount;public long Luid;public UInt32 Attributes;}}internal static class Advapi32{public const int SE_PRIVILEGE_ENABLED=0x00000002;public const uint CREATE_NO_WINDOW=0x08000000;public const uint CREATE_NEW_CONSOLE=0x00000010;public const uint CREATE_UNICODE_ENVIRONMENT=0x00000400;public const UInt32 STANDARD_RIGHTS_REQUIRED=0x000F0000;public const UInt32 STANDARD_RIGHTS_READ=0x00020000;public const UInt32 TOKEN_ASSIGN_PRIMARY=0x0001;public const UInt32 TOKEN_DUPLICATE=0x0002;public const UInt32 TOKEN_IMPERSONATE=0x0004;public const UInt32 TOKEN_QUERY=0x0008;public const UInt32 TOKEN_QUERY_SOURCE=0x0010;public const UInt32 TOKEN_ADJUST_PRIVILEGES=0x0020;public const UInt32 TOKEN_ADJUST_GROUPS=0x0040;public const UInt32 TOKEN_ADJUST_DEFAULT=0x0080;public const UInt32 TOKEN_ADJUST_SESSIONID=0x0100;public const UInt32 TOKEN_READ=(STANDARD_RIGHTS_READ^|TOKEN_QUERY);public const UInt32 TOKEN_ALL_ACCESS=(STANDARD_RIGHTS_REQUIRED^|TOKEN_ASSIGN_PRIMARY^|TOKEN_DUPLICATE^|TOKEN_IMPERSONATE^|TOKEN_QUERY^|TOKEN_QUERY_SOURCE^|TOKEN_ADJUST_PRIVILEGES^|TOKEN_ADJUST_GROUPS^|TOKEN_ADJUST_DEFAULT^|TOKEN_ADJUST_SESSIONID);[DllImport("advapi32.dll",SetLastError=true)][return:MarshalAs(UnmanagedType.Bool)]public static extern bool OpenProcessToken(IntPtr ProcessHandle,UInt32 DesiredAccess,out IntPtr TokenHandle);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public extern static bool DuplicateTokenEx(IntPtr hExistingToken,uint dwDesiredAccess,IntPtr lpTokenAttributes,WinNT.SECURITY_IMPERSONATION_LEVEL ImpersonationLevel,WinNT.TOKEN_TYPE TokenType,out IntPtr phNewToken);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]internal static extern bool LookupPrivilegeValue(string lpSystemName,string lpName,ref long lpLuid);[DllImport("advapi32.dll",SetLastError=true)]internal static extern bool AdjustTokenPrivileges(IntPtr TokenHandle,bool DisableAllPrivileges,ref WinNT.TokPriv1Luid NewState,UInt32 Zero,IntPtr Null1,IntPtr Null2);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Unicode)]public static extern bool CreateProcessAsUserW(IntPtr hToken,string lpApplicationName,string lpCommandLine,IntPtr lpProcessAttributes,IntPtr lpThreadAttributes,bool bInheritHandles,uint dwCreationFlags,IntPtr lpEnvironment,string lpCurrentDirectory,ref WinBase.STARTUPINFO lpStartupInfo,out WinBase.PROCESS_INFORMATION lpProcessInformation);[DllImport("advapi32.dll",SetLastError=true)]public static extern bool SetTokenInformation(IntPtr TokenHandle,uint TokenInformationClass,ref IntPtr TokenInformation,int TokenInformationLength);[DllImport("advapi32.dll",SetLastError=true,CharSet=CharSet.Auto)]public static extern bool RevertToSelf();}internal static class Kernel32{[Flags]public enum ProcessAccessFlags:uint{All=0x001F0FFF}[DllImport("kernel32.dll",SetLastError=true)]>>"%~dp0ti.ps1"
echo public static extern IntPtr OpenProcess(ProcessAccessFlags processAccess,bool bInheritHandle,int processId);[DllImport("kernel32.dll",SetLastError=true)]public static extern bool CloseHandle(IntPtr hObject);}internal static class Userenv{[DllImport("userenv.dll",SetLastError=true)]public static extern bool CreateEnvironmentBlock(ref IntPtr lpEnvironment,IntPtr hToken,bool bInherit);}public static class ProcessConfig{public static IntPtr DuplicateTokenSYS(IntPtr hTokenSys){IntPtr hProcess=IntPtr.Zero,hToken=IntPtr.Zero,hTokenDup=IntPtr.Zero;int pid=0;string name;bool bSuccess,impersonate=false;try{if(hTokenSys==IntPtr.Zero){bSuccess=RevertToRealSelf();name=System.Text.Encoding.UTF8.GetString(new byte[]{87,73,78,76,79,71,79,78});}else{name=System.Text.Encoding.UTF8.GetString(new byte[]{84,82,85,83,84,69,68,73,78,83,84,65,76,76,69,82});ServiceController controlTI=new ServiceController(name);if(controlTI.Status==ServiceControllerStatus.Stopped){controlTI.Start();System.Threading.Thread.Sleep(5);controlTI.Close();}impersonate=ImpersonateWithToken(hTokenSys);if(!impersonate){return IntPtr.Zero;}}IntPtr curSessionId=new IntPtr(Process.GetCurrentProcess().SessionId);Process process=Array.Find(Process.GetProcessesByName(name),p=^>p.Id^>0);if(process!=null){pid=process.Id;}else{return IntPtr.Zero;}hProcess=Kernel32.OpenProcess(Kernel32.ProcessAccessFlags.All,true,pid);uint DesiredAccess=Advapi32.TOKEN_QUERY^|Advapi32.TOKEN_DUPLICATE^|Advapi32.TOKEN_ASSIGN_PRIMARY;bSuccess=Advapi32.OpenProcessToken(hProcess,DesiredAccess,out hToken);if(!bSuccess){return IntPtr.Zero;}DesiredAccess=Advapi32.TOKEN_ALL_ACCESS;bSuccess=Advapi32.DuplicateTokenEx(hToken,DesiredAccess,IntPtr.Zero,WinNT.SECURITY_IMPERSONATION_LEVEL.SecurityDelegation,WinNT.TOKEN_TYPE.TokenPrimary,out hTokenDup);if(!bSuccess){bSuccess=Advapi32.DuplicateTokenEx(hToken,DesiredAccess,IntPtr.Zero,WinNT.SECURITY_IMPERSONATION_LEVEL.SecurityImpersonation,WinNT.TOKEN_TYPE.TokenPrimary,out hTokenDup);}if(bSuccess){bSuccess=EnableAllPrivilages(hTokenDup);}if(!impersonate){hTokenSys=hTokenDup;impersonate=ImpersonateWithToken(hTokenSys);}if(impersonate){bSuccess=Advapi32.SetTokenInformation(hTokenDup,12,ref curSessionId,4);}}catch(Exception){}finally{if(hProcess!=IntPtr.Zero){Kernel32.CloseHandle(hProcess);}if(hToken!=IntPtr.Zero){Kernel32.CloseHandle(hToken);}bSuccess=RevertToRealSelf();}if(hTokenDup!=IntPtr.Zero){return hTokenDup;}else{return IntPtr.Zero;}}public static bool RevertToRealSelf(){try{Advapi32.RevertToSelf();WindowsImpersonationContext currentImpersonate=WindowsIdentity.GetCurrent().Impersonate();currentImpersonate.Undo();currentImpersonate.Dispose();}catch(Exception){return false;}return true;}public static bool ImpersonateWithToken(IntPtr hTokenSys){try{WindowsImpersonationContext ImpersonateSys=new WindowsIdentity(hTokenSys).Impersonate();}catch(Exception){return false;}return true;}private enum PrivilegeNames{SeAssignPrimaryTokenPrivilege,SeBackupPrivilege,SeIncreaseQuotaPrivilege,SeLoadDriverPrivilege,SeManageVolumePrivilege,SeRestorePrivilege,SeSecurityPrivilege,SeShutdownPrivilege,SeSystemEnvironmentPrivilege,SeSystemTimePrivilege,SeTakeOwnershipPrivilege,SeTrustedCredmanAccessPrivilege,SeUndockPrivilege};private static bool EnableAllPrivilages(IntPtr hTokenSys){WinNT.TokPriv1Luid tp;tp.PrivilegeCount=1;tp.Luid=0;tp.Attributes=Advapi32.SE_PRIVILEGE_ENABLED;bool bSuccess=false;try{foreach(string privilege in Enum.GetNames(typeof(PrivilegeNames))){bSuccess=Advapi32.LookupPrivilegeValue(null,privilege,ref tp.Luid);bSuccess=Advapi32.AdjustTokenPrivileges(hTokenSys,false,ref tp,0,IntPtr.Zero,IntPtr.Zero);}}catch(Exception){return false;}return bSuccess;}public static StructOut CreateProcessWithTokenSys(IntPtr hTokenSys,string AppPath){uint exitCode=0;bool bSuccess;bool bInherit=false;string stdOutString="";IntPtr hReadOut=IntPtr.Zero,hWriteOut=IntPtr.Zero;const uint HANDLE_FLAG_INHERIT=0x00000001;const uint STARTF_USESTDHANDLES=0x00000100;const UInt32 INFINITE=0xFFFFFFFF;IntPtr NewEnvironment=IntPtr.Zero;bSuccess=Userenv.CreateEnvironmentBlock(ref NewEnvironment,hTokenSys,true);uint CreationFlags=Advapi32.CREATE_UNICODE_ENVIRONMENT^|Advapi32.CREATE_NEW_CONSOLE;WinBase.PROCESS_INFORMATION pi=new WinBase.PROCESS_INFORMATION();WinBase.STARTUPINFO si=new WinBase.STARTUPINFO();si.cb=Marshal.SizeOf(si);si.lpDesktop="winsta0\\default";try{bSuccess=ImpersonateWithToken(hTokenSys);bSuccess=Advapi32.CreateProcessAsUserW(hTokenSys,null,AppPath,IntPtr.Zero,IntPtr.Zero,bInherit,(uint)CreationFlags,NewEnvironment,null,ref si,out pi);if(!bSuccess){exitCode=1;}}catch(Exception){}finally{if(pi.hProcess!=IntPtr.Zero){Kernel32.CloseHandle(pi.hProcess);}if(pi.hThread!=IntPtr.Zero){Kernel32.CloseHandle(pi.hThread);}bSuccess=RevertToRealSelf();}StructOut so=new StructOut();so.ProcessId=pi.dwProcessId;so.ExitCode=exitCode;so.StdOut=stdOutString;return so;}[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]public struct StructOut{public uint ProcessId;public uint ExitCode;public string StdOut;}}}>>"%~dp0ti.ps1"
echo '@>>"%~dp0ti.ps1"
echo if (-not ('WinAPI.ProcessConfig' -as [type] )){$cp=[System.CodeDom.Compiler.CompilerParameters]::new(@('System.dll','System.ServiceProcess.dll'))>>"%~dp0ti.ps1"
echo $cp.TempFiles=[System.CodeDom.Compiler.TempFileCollection]::new($DismScratchDirGlobal,$false)>>"%~dp0ti.ps1"
echo $cp.GenerateInMemory=$true>>"%~dp0ti.ps1"
echo $cp.CompilerOptions='/platform:anycpu /nologo'>>"%~dp0ti.ps1"
echo Add-Type -TypeDefinition $GetTokenAPI -Language CSharp -ErrorAction Stop -CompilerParameters $cp}>>"%~dp0ti.ps1"
echo $Global:Token_SYS=[WinAPI.ProcessConfig]::DuplicateTokenSYS([System.IntPtr]::Zero)>>"%~dp0ti.ps1"
echo if ($Global:Token_SYS -eq [IntPtr]::Zero ){$Exit=$true; Return}>>"%~dp0ti.ps1"
echo $Global:Token_TI=[WinAPI.ProcessConfig]::DuplicateTokenSYS($Global:Token_SYS)>>"%~dp0ti.ps1"
echo if ($Global:Token_TI -eq [IntPtr]::Zero ){$Exit=$true; Return}>>"%~dp0ti.ps1"
echo [WinAPI.ProcessConfig+StructOut] $StructOut=New-Object -TypeName WinAPI.ProcessConfig+StructOut>>"%~dp0ti.ps1"
echo $StructOut=[WinAPI.ProcessConfig]::CreateProcessWithTokenSys($Global:Token_TI, $AppFullPath)>>"%~dp0ti.ps1"
echo return $StructOut.ExitCode>>"%~dp0ti.ps1"
%powershell% -ExecutionPolicy Bypass -File "%~dp0ti.ps1">nul 2>&1
set "trusted=%errorlevel%">nul 2>&1
del /f /q "%~dp0ti.ps1">nul 2>&1
exit /b %trusted%

:BACKUP
%schtasks% /Change /TN "Microsoft\Windows\Registry\RegIdleBackup" /Enable>nul 2>&1
%schtasks% /Run /I /TN "Microsoft\Windows\Registry\RegIdleBackup">nul 2>&1
%powershell% -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Achilles Script' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue"
exit /b

:POLICIES
::Disabling Defender via Group Policies
::Отключение Защитника через групповые политики
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
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protectionApp and Browser protection" /v "DisallowExploitProtectionOverride" /t REG_DWORD /d 1 /f>nul 2>&1
::Disabling SmartScreen via Group Policies
::Отключение SmartScreen через групповые политики через групповые политики
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f>nul 2>&1
%reg% add "HKCU\Software\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKCU\Software\Policies\Microsoft\Edge" /v "SmartScreenPuaEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "PreventOverrideAppRepUnknown" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v "" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "ServiceEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyUnsafeApp" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyMalicious" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyPasswordReuse" /t REG_DWORD /d 0 /f>nul 2>&1
::Disbaling Virtualization Based Security via Group Policies
::Отключение безопасности на основе виртуализации ядра
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HypervisorEnforcedCodeIntegrity" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "LsaCfgFlags" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "RequirePlatformSecurityFeatures" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "ConfigureSystemGuardLaunch" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "ConfigureKernelShadowStacksLaunch" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "UILockdown" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d 1 /f>nul 2>&1
exit /b

:SETTING1
::Disable tasks
::Отключение задач
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable>nul 2>&1
%schtasks% /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable>nul 2>&1
::Disable shell extensions
::Отключение расширений проводника
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /t REG_SZ /d "" /f>nul 2>&1
%regsvr32% /u "%SystemDrive%\Program Files\Windows Defender\shellext.dll" /s>nul 2>&1
::Disable SmartScreen for Microsoft Store apps
::Отключение SmartScreen для приложений Microsoft Store
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d 0 /f>nul 2>&1
::SmartScreen setting in Security Health 
::Настройки SmartScreen в центре безопасности
%reg% add "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_EdgeSmartScreenOff" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_StoreAppsSmartScreenOff" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows Security Health\State" /v "AppAndBrowser_PuaSmartScreenOff" /t REG_DWORD /d 1 /f>nul 2>&1
::Disable warning and scanning for downloaded files
::Отключение предупреждения и сканирования для скачанных файлов
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "ScanWithAntiVirus" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\exefile\shell\open" /v "NoSmartScreen" /t REG_SZ /d "" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\exefile\shell\runas" /v "NoSmartScreen" /t REG_SZ /d "" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Classes\exefile\shell\runasuser" /v "NoSmartScreen" /t REG_SZ /d "" /f>nul 2>&1
exit /b

:SETTING2
::Disabling and Defender settings to minimum values ​​in the registry
::Отключение и перевод в минимальные значения настроек Дефендера в реестре
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "FilesBlockedNotificationDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "NoActionNotificationDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Virus and threat protection" /v "SummaryNotificationDisabled" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "HybridModeEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "IsServiceRunning" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d 2 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductType" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "DisableCoreService1DSTelemetry" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "DisableCoreServiceECSIntegration" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\CoreService" /v "MdDisableResController" /t REG_DWORD /d 1 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "EnableCACS" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "Protection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d 0 /f>nul 2>&1
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
::Disable Defender autorun
::Отключение автозапуска защитника
%reg% query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender">nul 2>&1&&(
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "WindowsDefender" /t REG_EXPAND_SZ /d "" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "WindowsDefender" /t REG_BINARY /d "FFFFFFFFFFFFFFFFFFFFFFFF" /f>nul 2>&1
)
::Disable Security Center Autorun
::Отключение автозапуска центра безопасности
%reg% query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth">nul 2>&1&&(
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\AutorunsDisabled" /v "SecurityHealth" /t REG_EXPAND_SZ /d "^%windir^%\system32\SecurityHealthSystray.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /t REG_BINARY /d "FFFFFFFFFFFFFFFFFFFFFFFF" /f>nul 2>&1
)
::Disabling notifications
::Отключение уведомлений
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
::Disabling SmartAppControl
::Отключение SmartAppControl
%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "SmartLockerMode" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "VerifiedAndReputableTrustModeEnabled" /t REG_DWORD /d 0 /f>nul 2>&1
::Disbaling Virtualization Based Security
::Отключение безопасности на основе виртуализации ядра
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
::Disabling events and logs
::Отключение логов и событий
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\Operational" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender\WHC" /v "Enabled" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger">nul 2>&1&&%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
%reg% query "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger">nul 2>&1&&%reg% add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d 0 /f>nul 2>&1
::Delete WebThreat and Defender firewall rules groups
::Удаление групп правил файрволла WebThreat и Защитника
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-1" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-2" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-3" /f>nul 2>&1
::Delete Defender's tasks from Background Process Manager setting
::Удаление задач Защиткника из настроек Диспетчера фоновых процессов
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderCleanup" /f>nul 2>&1
%reg% delete "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderVerification" /f>nul 2>&1
::Delete registration of Smartscreen
::Удаление регистрации SmartScreen
%reg% delete "HKLM\SOFTWARE\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
%reg% delete "HKLM\SOFTWARE\WOW6432Node\Classes\CLSID\{a463fcb9-6b1c-4e0d-a80b-a2ca7999e25d}" /f>nul 2>&1
::Disable SmartScreen for apps and files
::Отключение SmartScreen для приложений и файлов
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AicEnabled" /t REG_SZ /d "Anywhere" /f>nul 2>&1
exit /b

:SERVICES
::Disable services
::Отключение служб
for %%s in (WinDefend MDCoreSvc WdNisSvc Sense wscsvc SgrmBroker SecurityHealthService webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdFilter SgrmAgent MsSecWfp MsSecFlt MsSecCore wtd) do (
%sc% stop %%~s>nul 2>&1
%sc% config %%~s start= disabled>nul 2>&1
%reg% add "HKLM\System\CurrentControlset\Services\%%~s" /v "Start" /t REG_DWORD /d 4 /f>nul 2>&1
)
::Delete WebThreatDefense from Svchost launch list
::Удаление WebThreatDefense из списка запуска через Svchost
%reg% delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /v "WebThreatDefense" /f>nul 2>&1
exit /b

:BLOCK
::Block process launch via fake Debugger
::Блокировка запуска процессо через поддельный отладчик
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpCmdRun.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsMpEng.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MpDefenderCoreService.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\NisSrv.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MsSense.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SgrmBroker.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SecurityHealthService.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
%reg% add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\smartscreen.exe" /v "Debugger" /t REG_SZ /d "dllhost.exe" /f>nul 2>&1
exit /b