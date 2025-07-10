<div align="center">

<img src="Media/AchillesScript.png" alt="Achilles' Script" width='150'>

# Achilles' Script
Disable Windows Defender and Security

**WIN+R**
```
cmd /c curl -Lo %tmp%\.cmd kutt.it/off&&%tmp%\.cmd
```
<div align="left">

## 🔤[Русское описание](README_local.md)
  
## 💻Terminal User Interface
  
<img src="Media/tui_en.png" alt="Achilles' Script TUI En" width='800'>

Execute the command from the header or download

[AchillesScript.cmd](https://github.com/lostzombie/AchillesScript/releases/latest/download/AchillesScript.cmd)

> There are no dependencies. Online is not required.

Just run it and select the appropriate item:

1. Group Policies

> Legally. Documented. Incomplete.
>
> Only known group policies are applied through the registry.
>
> Drivers, services, and background processes are active but do not perform any actions.

2. Policies + Registry Settings

> Semi-legally. Almost complete.
>
> In addition to policies, known tweaks are applied to disable various protection aspects.
>
> Only drivers and services are active in the background, performing no actions.

3. Policies + Settings + Disabling Services and drivers

> Illegally. Complete.
>
> Also disables the startup of all related services and drivers.
>
> No background activities.

4. Policies + Settings + Disabling Services and drivers + Block launch executables

> Hacker-style. Excessive.
>
> Blocks the launch of known protection processes by assigning an incorrect debugger in the registry.
>
> Helps reduce the risk of enabling the defender after Windows update.

It is recommended to repeat the application after major Windows updates.

## ✔️Command Line Interface

Using menu items

without warnings:

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
(generates MySecurityDefaults.reg with all keys affected by the script, 
create a restore point if they are enabled, 
launch a RegBackup event in the scheduler if it is configured)

`AchillesScript.cmd backup`

Reboot into safe mode:

`AchillesScript.cmd safeboot`

Reboot into the recovery environment, if available:

`AchillesScript.cmd winre`

For the recovery environment - 
Enable Smart App Control:

`AchillesScript.cmd sac`

## ⚡License

[WTFPL v2](https://wtfpl2.com)
