# 1. Remove all desktop icons
$userDesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$publicDesktopPath = "C:\Users\Public\Desktop"
Get-ChildItem -Path $userDesktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }
Get-ChildItem -Path $publicDesktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }

# 2. Remove all auto start entries that are not whitelisted
Import-Module "powershell-yaml"
$content = Get-Content -Path "$PSScriptRoot/autostart.yml" -Raw
$autoStart = $content | ConvertFrom-Yaml

function Is-Whitelisted {
    param (
        [string]$EntryName
    )

    foreach ($item in $autoStart.whitelist) {
        if ($entryName -like "*$($item.name)*") {
            if ($null -eq $item.hosts) { return $true }
            else { return $item.hosts -contains $env:COMPUTERNAME.ToLower() }
        }
    }

    return $false
}

$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)
foreach ($path in $registryPaths) {
    $entries = Get-ItemProperty -Path $path
    foreach ($entry in $entries.PSObject.Properties) {
        if (-not (Is-Whitelisted -EntryName $entry.Name)) {
            Remove-ItemProperty -Path $path -Name $entry.Name -ErrorAction SilentlyContinue
        }
    }
}

$startupFolderPath = [System.Environment]::GetFolderPath('Startup')
Get-ChildItem -Path $startupFolderPath -Filter '*.lnk' | ForEach-Object {
    if (-not (Is-Whitelisted -EntryName $_.BaseName)) {
        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
    }
}

# 3. Create custom autostart entries
foreach ($item in $autoStart.custom) {
    if ($item.type = "shortcut") {
        $startMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
        $shortcut = Get-ChildItem -Path $startMenuPath -Recurse -Filter '*.lnk' |
            Where-Object { $_.BaseName -like $item.name } |
            Select-Object -First 1

        $destinationPath = Join-Path -Path $startupFolderPath -ChildPath $shortcut.Name
        Copy-Item -Path $shortcut.FullName -Destination $destinationPath -Force
    }
}
