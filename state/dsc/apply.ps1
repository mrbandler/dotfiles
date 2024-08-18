$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

Import-Module -Name "$modulesPath/xScoop"

# winget configure -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
