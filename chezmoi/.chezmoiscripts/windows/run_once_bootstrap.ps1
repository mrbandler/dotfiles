# Adding this since chezmoi runs it on every change when I use `apply`.
$response = Read-Host "Do you want to bootstrap your Windows environment? (Y/n)"
if ($response -match '^(n|no)$') { exit }

$completedInitialBootstrap = Test-Path "$HOME\.bootstrapped"

# This script is meant to be run once to bootstrap the Windows environment.
Write-Output "Bootstrapping Windows environment..."

# Check for admin rights, if not elevate
$windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$windowsPrincipal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList @( $windowsIdentity )
$isAdmin = $windowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not ($isAdmin)) {
    Write-Host "This script requires administrator privileges. Relaunching with elevated rights..."

    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Create dev drive.
$drivePath = "$env:USERPROFILE\dev.vhdx"
$driveLabel = "Dev"
$driveLetter = "D"
$size = 500GB

if (-not (Test-Path $drivePath)) {
    $autoMountRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $autoMountBackup = (Get-ItemProperty -Path $autoMountRegPath -Name NoDriveTypeAutoRun -ErrorAction SilentlyContinue).NoDriveTypeAutoRun
    Set-ItemProperty -Path $autoMountRegPath -Name NoDriveTypeAutoRun -Value 255

    Write-Output "Creating dev drive..."

    try {
        $vhd = New-VHD -Path $drivePath -Dynamic -SizeBytes $size
        $disk = $vhd | Mount-VHD -Passthru
        $init = $disk | Initialize-Disk -Passthru
        $part = $init | New-Partition -UseMaximumSize
        $part | Format-Volume -DevDrive -FileSystem ReFS -Confirm:$false -Force | Out-Null
        $part | Set-Partition -NewDriveLetter $driveLetter
        Set-Volume -DriveLetter $driveLetter -NewFileSystemLabel $driveLabel

        Write-Output "Registring dev drive to auto attach on startup..."

        $id = $vhd.DiskIdentifier.ToLower()
        $autoAttachVirtualDiskPath = "HKLM:\SYSTEM\CurrentControlSet\Control\AutoAttachVirtualDisks\{$id}"
        if (-not (Test-Path $autoAttachVirtualDiskPath)) { New-Item -Path $autoAttachVirtualDiskPath -Force | Out-Null }
        New-ItemProperty -Path $autoAttachVirtualDiskPath -Name "Path" -PropertyType String -Value $drivePath -Force | Out-Null
    }
    finally {
        if ($null -ne $autoMountBackup) {
            Set-ItemProperty -Path $autoMountRegPath -Name NoDriveTypeAutoRun -Value $autoMountBackup
        }
        else {
            Remove-ItemProperty -Path $autoMountRegPath -Name NoDriveTypeAutoRun -ErrorAction SilentlyContinue
        }
    }
}

if (-not $completedInitialBootstrap) {
    # Set and update environment variables
    Write-Output "Setting home based environment variables..."

    [System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$env:USERPROFILE\.config", [System.EnvironmentVariableTarget]::User)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$env:USERPROFILE\bin;$env:USERPROFILE\.local\bin", [System.EnvironmentVariableTarget]::User)
}

if (-not $completedInitialBootstrap) {
    # Install enable winget configure and install the latest PowerShell
    Write-Output "Installing pwsh..."
    winget install --id Microsoft.PowerShell --silent --accept-source-agreements --accept-package-agreements
    winget configure --enable
}

if (-not $completedInitialBootstrap) {
    # Apply DSC configuration
    $env:PATH += ";C:\Program Files\PowerShell\7"
    pwsh "$HOME\.local\share\chezmoi\chezmoi\state\dsc\apply.ps1" -RunAfter
}

if (-not $completedInitialBootstrap) {
    # Setup PowerShell profile stubs.
    Write-Output "Setting up PS profiles..."

    New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell" -Force | Out-Null
    New-Item -ItemType Directory -Path "C:\Users\$env:USERNAME\Documents\PowerShell" -Force | Out-Null

    Set-Content -Path "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'
    Set-Content -Path "C:\Users\$env:USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Value '. $HOME/.config/pwsh/profile.ps1'
}


# Remove all pinned items from the taskbar
Write-Output "Removing pinned items from the taskbar..."

$taskbandRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
Remove-ItemProperty -Path $taskbandRegistryPath -Name "Favorites" -Force -ErrorAction SilentlyContinue

$taskbarPinnedItemsPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
Remove-Item -Path "$taskbarPinnedItemsPath\*" -Force -Recurse -ErrorAction SilentlyContinue

Stop-Process -Name explorer -Force
Start-Process explorer

# Sign into 1Password CLI to allow the
$env:PATH += ";$env:LOCALAPPDATA\Microsoft\WinGet\Links"
try {
    Invoke-Expression $(op signin)
}
catch {
    # Intentionally left empty to suppress error output
}

# Transfer ownership of ~/.local/share/chezmoi to the current user
Write-Output "Taking ownership of .local\share\chezmoi..."

Takeown /F "$env:USERPROFILE\.local\share\chezmoi" /R /D Y | Out-Null
icacls "$env:USERPROFILE\.local\share\chezmoi" /grant "%USERNAME%:F" /T | Out-Null

# Change git remote URL to SSH
Write-Output "Changing git remote URL to SSH..."

# Save the current directory
$currentDir = Get-Location
Set-Location "$HOME/.local/share/chezmoi"

$remoteUrl = git remote get-url origin
if ($remoteUrl -match "^https://github.com/(.+)/(.+)\.git$") {
    $username = $matches[1]
    $repo = $matches[2]

    $sshUrl = "git@github.com:$username/$repo.git"
    git remote set-url origin $sshUrl
}
Set-Location $currentDir

if (-not $completedInitialBootstrap) {
    # Schedule at logon after bootstrap script.
    Write-Output "Scheduling after boot script..."

    $chezmoiStorePath = "$HOME\.local\share\chezmoi\chezmoi"
    $afterBootstrapScriptPath = [System.IO.Path]::Combine($chezmoiStorePath, "scripts\windows\after_bootstrap.ps1")
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$afterBootstrapScriptPath`""
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName "AfterBootstrap" -Trigger $trigger -Action $action -Settings $settings -Description "After bootstrap setup" -User "$env:USERNAME" -RunLevel Highest | Out-Null
}

# Write file to user directory to indicate that initial bootstrapping has been completed.
if (-not (Test-Path "$HOME\.bootstrapped")) {
    Write-Output "Writing bootstrapping completion file..."
    Set-Content -Path "$HOME\.bootstrapped" -Value "true"
}

# Ask for restart
Write-Output "Windows environment bootstrapped."
Write-Output "Restart is required to finalize bootstrapping. Please restart the computer manually to complete it."
