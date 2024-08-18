$configPath = "$PSScriptRoot/configuration.dsc.yml"
$resourcesPath = "$PSScriptRoot/resources"
$modules = Get-ChildItem -Path $resourcesPath -Recurse -Include *.psd1
foreach ($module in $modules) {
    try {
        Import-Module -Name $module.FullName -ErrorAction Stop
    } catch {
        Write-Error "Failed to import module: $($module.FullName). Error: $_"
    }
}

winget configure test -f $configPath --verbose --accept-configuration-agreements
