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

    if ([string]::IsNullOrEmpty($ConfigPath)) {
        Write-Warning "The provided configuration path is empty or null."
        return @{}
    }

    $absolutePath = (Resolve-Path -Path $ConfigPath).Path
    if ($imported.ContainsKey($absolutePath)) {
        Write-Warning "File $absolutePath already imported, skipping to avoid duplication."
        return @{}
    }
    $imported[$absolutePath] = $true

    $content = Get-Content -Path $absolutePath -Raw
    $yaml = $content | ConvertFrom-Yaml
    if ($null -eq $yaml) {
        Write-Warning "Failed to load YAML content from $absolutePath."
        return @{}
    }

    $resolved = $yaml.Clone()
    if ($null -ne $resolved.imports) {
        foreach ($import in $resolved.imports) {
            $importPath = Join-Path -Path (Split-Path -Path $absolutePath -Parent) -ChildPath $import
            if (-not (Test-Path $importPath)) {
                Write-Warning "Unable to import $importPath for $absolutePath"
            }
            else {
                $importedConfig = Resolve-Config -ConfigPath $importPath
                if ($null -ne $importedConfig) {
                    if ($null -ne $importedConfig.properties.assertions) {
                        $resolved.properties.assertions += $importedConfig.properties.assertions
                    }
                    if ($null -ne $importedConfig.properties.resources) {
                        $resolved.properties.resources += $importedConfig.properties.resources
                    }
                    if ($null -ne $importedConfig.properties.parameters) {
                        $resolved.properties.parameters += $importedConfig.properties.parameters
                    }
                }
            }
        }
    }

    $resolved.Remove("imports")
    return $resolved
}

if ([string]::IsNullOrEmpty($Path)) {
    Write-Warning "The input file path (Path) is not provided."
    exit
}
if ([string]::IsNullOrEmpty($Output)) {
    Write-Warning "The output file path (Output) is not provided."
    exit
}

$merged = Resolve-Config -ConfigPath $Path
if ($null -ne $merged) {
    $merged | ConvertTo-Yaml | Set-Content -Path $Output -Force
}
else {
    Write-Warning "No merged configuration to save."
}

# Load the base file
# $absoluteFilePath = (Resolve-Path -Path $File).Path
# $basePath = Split-Path -Path $absoluteFilePath -Parent
# $baseContent = Get-Content -Path $absoluteFilePath -Raw
# $base = $baseContent | ConvertFrom-Yaml

# # Load all import files
# $base.imports | ForEach-Object {
#     $importPath = Join-Path -Path $basePath -ChildPath $_
#     if (-not (Test-Path $importPath)) {
#         Write-Warning "Unable to import $importPath for $File"
#     }
#     else {
#         $importContent = Get-Content -Path $importPath -Raw
#         $imported = $importContent | ConvertFrom-Yaml

#         if ($imported.properties.assertions.Count -ne 0) { $base.properties.assertions += $imported.properties.assertions }
#         if ($imported.properties.resources.Count -ne 0) { $base.properties.resources += $imported.properties.resources }
#         if ($imported.properties.parameters.Count -ne 0) { $base.properties.parameters += $imported.properties.parameters }
#     }
# }

# Merge and save
# $base.Remove("imports")
# $base | ConvertTo-Yaml | Set-Content -Path $Output -Force
