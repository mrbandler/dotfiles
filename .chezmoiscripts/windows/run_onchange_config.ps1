# dconf.ini hash: {{ include "state/dsc/configuration.dsc.yml" | sha256sum }}
Write-Output "Applying Windows configuration..."

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

# 2. Apply DSC configuration
$env:PATH += ";C:\Program Files\PowerShell\7"
pwsh "$HOME\.local\share\chezmoi\state\dsc\apply.ps1"

# 3. Delete all shortcuts from the desktop
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
Get-ChildItem -Path $desktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }
