# 1. Install and setup WSL
wsl --update
wsl --install --no-distribution
wsl --install Ubuntu --no-launch
ubuntu install --root

$user = $env:USERNAME.ToLower()
wsl -d Ubuntu -u root adduser --gecos GECOS --disabled-password $user
wsl -d Ubuntu -u root usermod -aG sudo $user
& ubuntu config --default-user $user
wsl --set-default Ubuntu

# 2. Start apps that need to be configured
Import-Module "powershell-yaml"
$content = Get-Content -Path "$PSScriptRoot/../../state/dsc/configuration.dsc.yml" -Raw
$config = $content | ConvertFrom-Yaml

$startMenuPaths = @(
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
)
foreach ($item in $config.properties.resources) {
    if ($null -eq $item.config) { continue }
    if ($null -eq $item.config.name) { continue }
    if ($null -eq $item.config.bootstrap) { continue }
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

# 3. Unregister this scheduled task
Unregister-ScheduledTask -TaskName "AfterBootstrap" -Confirm:$false

# 4. Finalize boostrapping
Read-Host "Finalized boostrapping [Enter]"
