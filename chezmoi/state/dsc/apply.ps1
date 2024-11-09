$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

$hostName = $env:COMPUTERNAME.ToLower()
$hostConfigPath = "$PSScriptRoot/hosts/$hostName.yml"

if (-not (Test-Path $hostConfigPath)) {
    Write-Warning "No configuration found for host $hostName. Falling back to default configuration."
    $hostName = "default"
}

./merge.ps1 -Path "$PSScriptRoot/hosts/$hostName.yml" -Output $configPath
winget configure -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
