# 1. Install and setup WSL
wsl --install --no-distribution
wsl --set-default-version 2
wsl --install Ubuntu --no-launch
ubuntu install --root

# 2. Create default user and set it for WSL
$user = $env:USERNAME.ToLower()
wsl -d Ubuntu -u root adduser --gecos GECOS --disabled-password $user
wsl -d Ubuntu -u root usermod -aG sudo $user
& ubuntu config --default-user $user
wsl --set-default Ubuntu

# 3. Start apps that need to be configured
$startMenuPaths = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
)
$apps = @(
    "Flow Launcher",
    "Voicemeeter Banana",
    "EarTrumpet",
    "1Password",
    "Proton Drive",
    "Google Drive"
)

foreach ($app in $apps) {
    foreach ($startMenuPath in $startMenuPaths) {
        $appPath = Get-ChildItem -Path $startMenuPath -Recurse -Filter "$app.lnk" -ErrorAction SilentlyContinue
        if ($appPath) {
            Start-Process -FilePath $appPath.FullName
            break
        }
    }
}

# 4. Unregister this scheduled task
Unregister-ScheduledTask -TaskName "AfterBootstrap" -Confirm:$false

# 5. Finalize boostrapping
Read-Host "Finalized boostrapping. Press Enter to continue."
