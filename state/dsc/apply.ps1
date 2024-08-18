$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

winget configure validate -f $configPath --verbose
winget configure test -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
winget configure -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
