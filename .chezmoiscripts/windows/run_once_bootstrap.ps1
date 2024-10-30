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
winget configure --enable

# 4. Apply DSC configuration
& "$HOME\.local\share\chezmoi\state\dsc\apply.ps1"

# 5. Restart
Write-Output "Windows environment bootstrapped. Restarting..."
Restart-Computer
