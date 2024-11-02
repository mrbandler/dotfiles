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
winget configure --enable
winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements

# 3. Apply DSC configuration
$env:PATH += ";C:\Program Files\PowerShell\7"
pwsh "$HOME\.local\share\chezmoi\state\dsc\apply.ps1"

# 4. Setup PowerShell profile stubs.
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell" -Force
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\PowerShell" -Force

Set-Content -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'
Set-Content -Path "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'

# 5. Delete all shortcuts from the desktop
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
Get-ChildItem -Path $desktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }

# 6. Remove all pinned items from the taskbar
$taskbandRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
Remove-Item -Path $taskbandRegistryPath -Force -ErrorAction SilentlyContinue

$taskbarPinnedItemsPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
Remove-Item -Path "$taskbarPinnedItemsPath\*" -Force -Recurse -ErrorAction SilentlyContinue

Stop-Process -Name explorer -Force
Start-Process explorer

# 7. Prompt for restart
Write-Output "Windows environment bootstrapped."

$restartResponse = Read-Host "Restart required. Do you want to restart the computer now? (Y/N)"
if ($restartResponse -match '^(y|Y)') {
    Write-Output "Restarting the computer..."
    Restart-Computer
} else {
    Write-Output "Restart skipped. Please restart the computer manually to complete the setup."
}
