param (
    [string] $Path = $args[0],
    [string] $Output = $args[1]
)

$moduleName = "powershell-yaml"
$module = Get-InstalledModule -Name $moduleName -ErrorAction SilentlyContinue

if ($null -eq $module) {
    Install-Module -Name $moduleName -Scope CurrentUser -Force
}
else {
    $updateAvailable = (Find-Module -Name $moduleName).Version -gt $module.Version
    if ($updateAvailable) { Update-Module -Name $moduleName -Force }
}

Import-Module $moduleName

$imported = @{}
function Resolve-Config {
    param (
        [string] $ConfigPath
    )

    Write-Verbose "Resolving configuration from $ConfigPath"

    if ([string]::IsNullOrEmpty($ConfigPath)) {
        Write-Error "The provided configuration path is empty or null."
        return @{}
    }

    $absolutePath = (Resolve-Path -Path $ConfigPath).Path
    if ($imported.ContainsKey($absolutePath)) {
        Write-Verbose "File $absolutePath already imported, skipping to avoid duplication."
        return @{}
    }
    $imported[$absolutePath] = $true

    $content = Get-Content -Path $absolutePath -Raw
    $yaml = $content | ConvertFrom-Yaml
    if ($null -eq $yaml) {
        Write-Error "Failed to load YAML content from $absolutePath."
        return @{}
    }

    $resolved = $yaml.Clone()
    if ($null -ne $resolved.imports) {
        foreach ($import in $resolved.imports) {
            $importPath = Join-Path -Path (Split-Path -Path $absolutePath -Parent) -ChildPath $import.Path
            if (-not (Test-Path $importPath)) {
                Write-Verbose "Unable to import $importPath for $absolutePath"
            }
            else {
                $importedConfig = Resolve-Config -ConfigPath $importPath
                if ($null -ne $importedConfig) {
                    if ($null -ne $importedConfig.properties.assertions) {
                        $filteredAssertions = $importedConfig.properties.assertions

                        if ($null -ne $import.exclude) { $filteredAssertions = $filteredAssertions | Where-Object { $_.id -notin $import.exclude } }
                        if ($null -ne $import.include) { $filteredAssertions = $filteredAssertions | Where-Object { $_.id -in $import.include } }

                        $resolved.properties.assertions += $filteredAssertions
                    }
                    if ($null -ne $importedConfig.properties.resources) {
                        $filteredResources = $importedConfig.properties.resources

                        if ($null -ne $import.exclude) { $filteredResources = $filteredResources | Where-Object { $_.id -notin $import.exclude } }
                        if ($null -ne $import.include) { $filteredResources = $filteredResources | Where-Object { $_.id -in $import.include } }

                        $resolved.properties.resources += $filteredResources
                    }
                    if ($null -ne $importedConfig.properties.parameters) {
                        $filteredParameters = $importedConfig.properties.parameters

                        if ($null -ne $import.exclude) { $filteredParameters = $filteredParameters | Where-Object { $_.id -notin $import.exclude } }
                        if ($null -ne $import.include) { $filteredParameters = $filteredParameters | Where-Object { $_.id -in $import.include } }

                        $resolved.properties.parameters += $filteredParameters
                    }
                }
            }
        }
    }

    $resolved.Remove("imports")
    return $resolved
}

if ([string]::IsNullOrEmpty($Path)) {
    Write-Error "The input file path (Path) is not provided."
    exit
}
if ([string]::IsNullOrEmpty($Output)) {
    Write-Error "The output file path (Output) is not provided."
    exit
}

$built = Resolve-Config -ConfigPath $Path
if ($null -ne $built) {
    $built | ConvertTo-Yaml | Set-Content -Path $Output -Force
}
else {
    Write-Error "Unable to build configuration."
}
