# 1. Remove all desktop icons
$userDesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$publicDesktopPath = "C:\Users\Public\Desktop"
Get-ChildItem -Path $userDesktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }
Get-ChildItem -Path $publicDesktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }

# 2. Remove all auto start entries that are not whitelisted
Import-Module "powershell-yaml"
$content = Get-Content -Path "$PSScriptRoot/settings/autostart.yml" -Raw
$autoStart = $content | ConvertFrom-Yaml

function Test-Whitelisted {
    param (
        [string]$EntryName
    )

    foreach ($item in $autoStart.whitelist) {
        if ($entryName -like "*$($item.name)*") {
            return $true;
        }
    }

    return $false
}

$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"
)
foreach ($registryPath in $registryPaths) {
    if (Test-Path -Path $registryPath) {
        $entries = Get-ItemProperty -Path $registryPath
        foreach ($entry in $entries.PSObject.Properties) {
            if (-not (Test-Whitelisted -EntryName $entry.Name)) {
                Remove-ItemProperty -Path $registryPath -Name $entry.Name -ErrorAction SilentlyContinue
            }
        }
    }
}

$machineStartupFolderPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup";
$userStartupFolderPath = [System.Environment]::GetFolderPath('Startup')
$startupFolderPaths = @(
    $machineStartupFolderPath,
    $userStartupFolderPath
)
foreach ($startupFolderPath in $startupFolderPaths) {
    Get-ChildItem -Path $startupFolderPath -Filter '*.lnk' | ForEach-Object {
        if (-not (Test-Whitelisted -EntryName $_.BaseName)) {
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}

# 3. Create or enable autostart entries
foreach ($item in $autoStart.whitelist) {
    if ($item.type = "shortcut") {
        $shortcut = Get-ChildItem -Path $item.From -Recurse -Filter '*.lnk' |
        Where-Object { $_.BaseName -like $item.name } |
        Select-Object -First 1

        if ($null -eq $shortcut) { continue }

        $destinationPath = Join-Path -Path $userStartupFolderPath -ChildPath $shortcut.Name
        Copy-Item -Path $shortcut.FullName -Destination $destinationPath -Force
    }
    elseif ($item.type = "exe") {
        $executable = Get-ChildItem -Path $item.From -Recurse -Filter '*.exe' |
        Where-Object { $_.BaseName -like $item.name } |
        Select-Object -First 1

        if ($null -eq $executable) { continue }

        $destinationPath = Join-Path -Path $userStartupFolderPath -ChildPath "$($executable.BaseName).lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($destinationPath)
        $Shortcut.TargetPath = $executable.FullName
        $Shortcut.Save()
    }
}
