Import-Module "powershell-yaml"
$config = Get-Content -Path "$PSScriptRoot/configuration.dsc.yml" -Raw | ConvertFrom-Yaml

#--------------------------------------------------------------------------------------------------#
# winget package uninstallation.
#--------------------------------------------------------------------------------------------------#
$wingetPackageIdBlacklist = @(
    "Microsoft.WSL",
    "Microsoft.UI*"
    "Microsoft.VC*",
    "Microsoft.AppInstaller",
    "Microsoft.PowerShell",
    "Microsoft.DevHome",
    "Microsoft.Edge",
    "Canonical.Ubuntu",
    "FocusriteControl2",
    "Spotify.Spotify" # Is installed via choco, not winget.
)

Write-Host "Checking for uninstallable winget packages..."
winget export -o "$PSScriptRoot/winget.json" | Out-Null
$winget = Get-Content -Path "$PSScriptRoot/winget.json" -Raw | ConvertFrom-Json

$wingetPackages = $winget.Sources
| ForEach-Object {
    $_.Packages | ForEach-Object {
        [PSCustomObject]@{
            Id = $_.PackageIdentifier
        }
    }
}
| Where-Object {
    $isBlacklisted = $false
    foreach ($pattern in $wingetPackageIdBlacklist) {
        if ($_.Id -like $pattern) {
            $isBlacklisted = $true
            break
        }
    }
    -not $isBlacklisted
}

$wingetResources = $config.properties.resources | Where-Object { $_.resource -eq "Microsoft.WinGet.DSC/WinGetPackage" }
foreach ($wingetPackage in $wingetPackages) {
    $wingetResource = $wingetResources | Where-Object { $_.settings.Id -eq $wingetPackage.Id }
    if (-not $wingetResource) {
        Write-Host "Uninstalling $($wingetPackage.Id)"
        winget uninstall --id $wingetPackage.Id --silent
    }
}

Remove-Item -Path "$PSScriptRoot/winget.json"

#--------------------------------------------------------------------------------------------------#
# scoop package uninstallation.
#--------------------------------------------------------------------------------------------------#
$scoopBucketBlacklist = @(
    "main"
)

Write-Host "Checking for uninstallable scoop packages..."
$scoopExport = scoop export | ConvertFrom-Json
$scoopAppResources = $config.properties.resources | Where-Object { $_.resource -eq "xScoop/ScoopApp" }
$scoopBucketResources = $config.properties.resources | Where-Object { $_.resource -eq "xScoop/ScoopBucket" }

foreach ($app in $scoopExport.apps) {
    $scoopAppResource = $scoopAppResources | Where-Object { $_.settings.Name -eq $app.name }
    if (-not $scoopAppResource) {
        Write-Host "Uninstalling $($app.name)"
        scoop uninstall $app.name
    }
}

foreach ($bucket in $scoopExport.buckets) {
    if ($bucket.name -in $scoopBucketBlacklist) { continue }

    $scoopBucketResource = $scoopBucketResources | Where-Object { $_.settings.Name -eq $bucket.name }
    if (-not $scoopBucketResource) {
        Write-Host "Removing bucket $($bucket.name)"
        scoop rm $bucket.name
    }
}

#--------------------------------------------------------------------------------------------------#
# choco package uninstallation.
#--------------------------------------------------------------------------------------------------#
$chocoPackageIdBlacklist = @(
    "chocolatey*",
    "KB*"
    "dotnetfx",
    "vcredist*"
)

Write-Host "Checking for uninstallable choco packages..."
choco export -o "$PSScriptRoot/choco.xml" | Out-Null
$chocoExport = [xml](Get-Content -Path "$PSScriptRoot/choco.xml")

$chocoResouces = $config.properties.resources | Where-Object { $_.resource -eq "cChoco/cChocoPackageInstaller" }
foreach ($chocoPackage in $chocoExport.packages.package) {
    $isBlacklisted = $false
    foreach ($pattern in $chocoPackageIdBlacklist) {
        if ($chocoPackage.id -like $pattern) {
            $isBlacklisted = $true
            break
        }
    }
    if ($isBlacklisted) { continue }

    $chocoResource = $chocoResouces | Where-Object { $_.settings.Name -eq $chocoPackage.id }
    if (-not $chocoResource) {
        Write-Host "Uninstalling $($chocoPackage.id)"
        choco uninstall $chocoPackage.id -y
    }
}

Remove-Item -Path "$PSScriptRoot/choco.xml"
