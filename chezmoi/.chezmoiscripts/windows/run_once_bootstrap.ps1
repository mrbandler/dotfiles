# This script is meant to be run once to bootstrap the Windows environment.
Write-Output "Bootstrapping Windows environment..."

# 1. Check for admin rights, if not elevate
$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$windowsPrincipal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList @( $windowsIdentity )
$isAdmin = $windowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not ($isAdmin)) {
    Write-Host "This script requires administrator privileges. Relaunching with elevated rights..."

    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# 2. Install enable winget configure and install the latest PowerShell
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$env:USERPROFILE\.config", [System.EnvironmentVariableTarget]::User)
winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements
winget configure --enable

# 3. Apply DSC configuration
$env:PATH += ";C:\Program Files\PowerShell\7"
pwsh "$HOME\.local\share\chezmoi\chezmoi\state\dsc\apply.ps1"

# 4. Setup PowerShell profile stubs.
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell" -Force | Out-Null
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\PowerShell" -Force | Out-Null

Set-Content -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'
Set-Content -Path "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'

# 5. Remove all pinned items from the taskbar
$taskbandRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
Remove-ItemProperty -Path $taskbandRegistryPath -Name "Favorites" -Force -ErrorAction SilentlyContinue

$taskbarPinnedItemsPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
Remove-Item -Path "$taskbarPinnedItemsPath\*" -Force -Recurse -ErrorAction SilentlyContinue

Stop-Process -Name explorer -Force
Start-Process explorer

# 6. Sign into 1Password CLI to allow the
$env:PATH += ";$env:LOCALAPPDATA\Microsoft\WinGet\Links"
Invoke-Expression $(op signin)

# 7. Schedule at logon after bootstrap script.
$chezmoiStorePath = "$HOME\.local\share\chezmoi\chezmoi"
$afterBootstrapScriptPath = [System.IO.Path]::Combine($chezmoiStorePath, "scripts\windows\after_bootstrap.ps1")
$trigger = New-ScheduledTaskTrigger -AtLogOn
$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$afterBootstrapScriptPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "AfterBootstrap" -Trigger $trigger -Action $action -Settings $settings -Description "After bootstrap setup" -User "$env:USERNAME" -RunLevel Highest | Out-Null

# 8. Ask for restart
Write-Output "Windows environment bootstrapped."
Write-Output "Restart is required to finalize bootstrapping. Please restart the computer manually to complete it."
