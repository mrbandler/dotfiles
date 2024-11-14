# 1. Start apps that need to be configured
Import-Module "powershell-yaml"
$content = Get-Content -Path "$PSScriptRoot/../../state/dsc/configuration.dsc.yml" -Raw
$config = $content | ConvertFrom-Yaml

$startMenuPaths = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
)
foreach ($item in $config.resouces) {
    if ($null -eq $item.config) { continue }
    if ($null -eq $item.config.name) { continue }
    if ($null -eq $item.config.boostrap) { continue }
    if ($null -eq $item.config.bootstrap.startAfter -or $item.bootstrap.startAfter -eq $false) { continue }

    $name = $item.config.name
    foreach ($startMenuPath in $startMenuPaths) {
        $appPath = Get-ChildItem -Path $startMenuPath -Recurse -Filter "$name.lnk" -ErrorAction SilentlyContinue
        if ($appPath) {
            Start-Process -FilePath $appPath.FullName
            break
        }
    }
}

# 2. Install and setup WSL
wsl --install --no-distribution
wsl --set-default-version 2
wsl --install Ubuntu --no-launch
ubuntu install --root

# 3. Create default user and set it for WSL
$user = $env:USERNAME.ToLower()
wsl -d Ubuntu -u root adduser --gecos GECOS --disabled-password $user
wsl -d Ubuntu -u root usermod -aG sudo $user
& ubuntu config --default-user $user
wsl --set-default Ubuntu

# 4. Unregister this scheduled task
Unregister-ScheduledTask -TaskName "AfterBootstrap" -Confirm:$false

# 5. Finalize boostrapping
Read-Host "Finalized boostrapping. Press Enter to continue."
