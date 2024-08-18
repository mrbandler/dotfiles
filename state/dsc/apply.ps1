$configPath = "$PSScriptRoot/configuration.dsc.yml"
$modulesPath = "$PSScriptRoot/modules"
$env:PSModulePath = "$env:PSModulePath;$modulesPath"

winget configure test -f $configPath --verbose --disable-interactivity --accept-configuration-agreements
