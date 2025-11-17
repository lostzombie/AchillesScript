<img align="right" src="Media/AchillesScript.png" alt="Achilles' Script" width='150'>

![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/lostzombie/AchillesScript/total?style=for-the-badge&color=blue)
![Windows 11 25h2](https://img.shields.io/badge/windows_11_25h2-compatible-teal?style=for-the-badge)
![Bypass](https://img.shields.io/badge/Microsoft_Defender-bypass-green?style=for-the-badge)
<br>
<br>
<br>

# Achilles' Script

Disable Microsoft Windows Defender, Security app, Smartscreen, completely without remove and broke Windows image integrity

**WIN+R**

```
cmd /c curl -Lo %tmp%\.cmd kutt.it/off&&%tmp%\.cmd
```

### 🔤 Russian readme [[Русское описание](README_local.md)]

---

## 🖥 Terminal User Interface
  
<img src="Media/tui_en.png" alt="Achilles' Script TUI En" width='683'>

Execute the command from the header or download [AchillesScript.cmd](https://github.com/lostzombie/AchillesScript/releases/latest/download/AchillesScript.cmd)

*If your browser is blocking the download, use this command Win+R:*

`cmd /c curl -Lo %USERPROFILE%\Downloads\AchillesScript.cmd kutt.it/off&start %USERPROFILE%\Downloads`

> [!TIP]
> There are no dependencies. Online is not required.

Just run it and select the appropriate item:

---
#### 1. Group Policies

> [!NOTE]
> Legally. Documented. Incomplete.
>
> Only known group policies are applied through the registry and .pol files
>
> Drivers, services, and background processes are active but do not perform any actions.
---
#### 2. Policies + Registry Settings

> [!NOTE]
> Semi-legally. Almost complete.
>
> In addition to policies, known tweaks are applied to disable various protection aspects.
>
> Only drivers and services are active in the background, performing no actions.
---
#### 3. Policies + Settings + Disabling Services and drivers

> [!NOTE]
> Illegally. Complete.
>
> Also disables the startup of all related services and drivers.
>
> No background activities.
---
#### 4. Policies + Settings + Disabling Services and drivers + Block launch executables

> [!NOTE]
> Hacker-style. Excessive.
>
> Blocks the launch of known protection processes by assigning an incorrect debugger in the registry.
>
> Helps reduce the risk of enabling the defender after Windows update.

---
> [!WARNING]
> It is recommended to repeat the application after major Windows updates.

https://github.com/user-attachments/assets/8461752a-a097-4c95-8882-78f884f2a361

---

## ⚙️ Setting

Uncoment in script or set in cmd before launch:

`set NoBackup=1`

to disable backup of your settings

`set NoWarn=1`

to disable warning before reboot

`set NotDisableSecHealth=1`

if you don't want to disable the Security app

`set NotDisableWscsvc=1`

if you don't want to disable the Security Center service 

Only the assignment of the variable is checked, the value is not checked.

---

## 💻 Command Line Interface

Using menu items without warnings:

Policies

`AchillesScript.cmd apply 1`

Policies + Registry settings

`AchillesScript.cmd apply 2`

Policies + Settings + Disabling services

`AchillesScript.cmd apply 3`

Policies + Settings + disabling services + blocking startup

`AchillesScript.cmd apply 4`

Applying individual categories independently (for tests):

`AchillesScript.cmd apply policies`

`AchillesScript.cmd apply setting`

`AchillesScript.cmd apply services`

`AchillesScript.cmd apply block`

Applying individual categories together to choose from (for tests):

`AchillesScript.cmd multi policies services`

`AchillesScript.cmd multi setting block`

`AchillesScript.cmd multi setting services block`

Restoring default settings:

`AchillesScript.cmd restore`

Additional functions:

Blocking / unblocking process startup:

`AchillesScript.cmd block process.exe`

`AchillesScript.cmd unblock process.exe`

Blocking / unblocking preinstalled UWP apps by mask:

`AchillesScript.cmd uwpoff calc`

`AchillesScript.cmd uwpon calc`

Running with Trusted Installer privileges:

`AchillesScript.cmd ti "path with space\process.exe"`

`AchillesScript.cmd ti process.exe param1 param2`

Backup of current security settings:
Generates MySecurityDefaults.reg with all keys affected by the script, create a restore point if they are enabled, export full registry hives HKLM\SYSTEM, HKLM\SOFTWARE

`AchillesScript.cmd backup`

Reboot into safe mode:

`AchillesScript.cmd safeboot`

Reboot into the recovery environment, if available:

`AchillesScript.cmd winre`

For the recovery environment - Enable Smart App Control:

`AchillesScript.cmd sac`

---

## ⚖️ License

[WTFPL v2](https://wtfpl2.com)
