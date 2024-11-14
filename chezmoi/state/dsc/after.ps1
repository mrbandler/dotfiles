# 1. Remove all desktop icons
$userDesktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$publicDesktopPath = "C:\Users\Public\Desktop"
$desktopPaths = @(
    $userDesktopPath,
    $publicDesktopPath
)
foreach ($desktopPath in $desktopPaths) {
    Get-ChildItem -Path $desktopPath -Filter *.lnk | ForEach-Object { Remove-Item $_.FullName -Force }
}

# 2. Remove all auto start entries that are not whitelisted
Import-Module "powershell-yaml"
$content = Get-Content -Path "$PSScriptRoot/configuration.dsc.yml" -Raw
$config = $content | ConvertFrom-Yaml

# 3. Create or enable autostart entries
foreach ($item in $config.properties.resources) {
    if ($null -eq $item.config) { continue }
    if ($null -eq $item.config.name) { continue }
    if ($null -eq $item.config.autostart) { continue }

    if ($item.config.autostart.type = "shortcut") {
        $shortcut = Get-ChildItem -Path $item.config.autostart.from -Recurse -Filter '*.lnk' |
        Where-Object { $_.BaseName -like $item.config.name } |
        Select-Object -First 1

        if ($null -eq $shortcut) { continue }

        $destinationPath = Join-Path -Path $userStartupFolderPath -ChildPath $shortcut.Name
        Copy-Item -Path $shortcut.FullName -Destination $destinationPath -Force
    }
    elseif ($item.config.autostart.type = "exe") {
        $executable = Get-ChildItem -Path $item.config.autostart.from -Recurse -Filter '*.exe' |
        Where-Object { $_.BaseName -like $item.config.name } |
        Select-Object -First 1

        if ($null -eq $executable) { continue }

        $destinationPath = Join-Path -Path $userStartupFolderPath -ChildPath "$($executable.BaseName).lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($destinationPath)
        $Shortcut.TargetPath = $executable.FullName
        $Shortcut.Save()
    }
}

# 4. Ask user to open the Task Manager to manage startup entries
$userInput = Read-Host "Do you want to open the Task Manager now, to manage Start Up entries? [Y/n]"
if ($userInput -match '^(Y|y)$') {
    Start-Process -FilePath "taskmgr"
    Write-Output "Opening Task Manager..."
}
