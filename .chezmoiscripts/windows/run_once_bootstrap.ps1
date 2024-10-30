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

# 2. Set PowerShell execution policy.
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 3. Make sure winget is up-to-date, installed and configure is enabled.
&([ScriptBlock]::Create((Invoke-RestMethod winget.pro))) -Force

# 4. Install enable winget configure and install the latest PowerShell
winget configure --enable
winget install --id Microsoft.PowerShell --silent

# 5. Setup PowerShell profile stubs.
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell" -Force
New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\PowerShell" -Force

Set-Content -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'
Set-Content -Path "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'

# 6. Apply DSC configuration
pwsh "$HOME\.local\share\chezmoi\state\dsc\apply.ps1"

# 7. Prompt for restart
Write-Output "Windows environment bootstrapped."

$restartResponse = Read-Host "Restart required. Do you want to restart the computer now? (Y/N)"
if ($restartResponse -match '^(y|Y)') {
    Write-Output "Restarting the computer..."
    Restart-Computer
} else {
    Write-Output "Restart skipped. Please restart the computer manually to complete the setup."
}
