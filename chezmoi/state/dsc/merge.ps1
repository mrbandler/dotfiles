param (
    [string] $File = $args[0],
    [string] $Output = $args[1]
)

# Install and import the powershell-yaml module
$moduleName = "powershell-yaml"
$module = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue

if ($null -eq $module) {
    Install-Module -Name $moduleName -Scope CurrentUser -Force
} else {
    $updateAvailable = (Find-Module -Name $moduleName).Version -gt $module.Version
    if ($updateAvailable) { Update-Module -Name $moduleName -Force }
}

Import-Module $moduleName

# Load the imports from base file
$absoluteFilePath = (Resolve-Path -Path $File).Path
$basePath = Split-Path -Path $absoluteFilePath -Parent
$baseContent = Get-Content -Path $absoluteFilePath -Raw
$base = $baseContent | ConvertFrom-Yaml

# Load all import files
$imported = $()
$base.imports | ForEach-Object {
    $importPath = Join-Path -Path $basePath -ChildPath $_
    $importContent = Get-Content -Path $importPath -Raw
    $imported = $importContent | ConvertFrom-Yaml

    if ($imported.properties.assertions.Count -ne 0) { $base.properties.assertions += $imported.properties.assertions }
    if ($imported.properties.resources.Count -ne 0) { $base.properties.resources += $imported.properties.resources }
    if ($imported.properties.parameters.Count -ne 0) { $base.properties.parameters += $imported.properties.parameters }
}

# Merge and save
$base.Remove("imports")
$base | ConvertTo-Yaml | Set-Content -Path $Output -Force
