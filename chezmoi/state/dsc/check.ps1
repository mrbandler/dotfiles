param (
    [string]$PrebuiltConfig = $null,
    [switch]$Verbose = $false
)

$modulesPath = "$PSScriptRoot/modules"
$modules = Get-ChildItem -Path $modulesPath -Recurse -Include *.psd1

foreach ($module in $modules) {
    try {
        if ($Verbose) {
            Write-Host "Importing module: $($module.FullName)"
            Import-Module -Name $module.FullName -Verbose -ErrorAction Stop -Force
        }
        else {
            Import-Module -Name $module.FullName -ErrorAction Stop -Force
        }
    }
    catch {
        Write-Error "Failed to import module: $($module.FullName). Error: $_"
    }
}

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

    Remove-Item -Path $configPath -Force -ErrorAction SilentlyContinue

    Write-Host "Building configuration..."
    & "$PSScriptRoot/build.ps1" -Path "$PSScriptRoot/hosts/$hostName.yml" -Output $configPath
}

Write-Host "Checking configuration..."
winget configure test -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
