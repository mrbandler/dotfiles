$modulesPath = "$PSScriptRoot/modules"
$modules = Get-ChildItem -Path $modulesPath -Recurse -Include *.psd1

foreach ($module in $modules) {
    try {
        Write-Host "Importing module: $($module.FullName)"
        Import-Module -Name $module.FullName -Verbose -ErrorAction Stop -Force
    }
    catch {
        Write-Error "Failed to import module: $($module.FullName). Error: $_"
    }
}

$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

$hostName = $env:COMPUTERNAME.ToLower()
$hostConfigPath = "$PSScriptRoot/hosts/$hostName.yml"

if (-not (Test-Path $hostConfigPath)) {
    Write-Warning "No configuration found for host $hostName. Falling back to default configuration."
    $hostName = "default"
}

Remove-Item -Path $configPath -Force -ErrorAction SilentlyContinue
./build.ps1 -Path "$PSScriptRoot/hosts/$hostName.yml" -Output $configPath
winget configure test -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
