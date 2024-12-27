param (
    [string]$PrebuiltConfig = $null,
    [switch]$RunBefore = $false,
    [switch]$RunAfter = $false
)

$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

if ($PrebuiltConfig) {
    if (-not (Test-Path $PrebuiltConfig)) {
        Write-Error "The provided pre-built configuration file '$PrebuiltConfig' does not exist."
        exit 1
    }

    Write-Host "Using pre-built configuration file: $PrebuiltConfig."
    Set-Content -Path $configPath -Value $(Get-Content -Path $PrebuiltConfig -Raw) -Encoding UTF8
}
else {
    $hostName = $env:COMPUTERNAME.ToLower()
    $hostConfigPath = "$PSScriptRoot/hosts/$hostName.yml"

    if (-not (Test-Path $hostConfigPath)) {
        Write-Warning "No configuration found for host $hostName. Falling back to default configuration."
        $hostName = "default"
    }
    else {
        Write-Host "Using configuration for host $hostName."
    }

    Write-Host "Building configuration..."
    Remove-Item -Path $configPath -Force -ErrorAction SilentlyContinue
    & "$PSScriptRoot/build.ps1" -Path "$PSScriptRoot/hosts/$hostName.yml" -Output $configPath
}


if ($RunBefore) {
    Write-Host "Running before script..."
    & "$PSScriptRoot/before.ps1"
}

Write-Host "Applying configuration..."
winget configure -f $configPath --verbose --disable-interactivity --accept-configuration-agreements

if ($RunAfter) {
    Write-Host "Running after script..."
    & "$PSScriptRoot/after.ps1"
}
