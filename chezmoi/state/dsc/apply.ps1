$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

$hostName = $env:COMPUTERNAME.ToLower()
./merge.ps1 -File "$PSScriptRoot/hosts/$hostName.yml" -Output $configPath

winget configure -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
