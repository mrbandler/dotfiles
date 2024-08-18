$modulesPath = "$PSScriptRoot/modules"
$modules = Get-ChildItem -Path $modulesPath -Recurse -Include *.psd1

foreach ($module in $modules) {
    try {
        Write-Host "Importing module: $($module.FullName)"
        Import-Module -Name $module.FullName -Verbose -ErrorAction Stop -Force
    } catch {
        Write-Error "Failed to import module: $($module.FullName). Error: $_"
    }
}