# Constants.
$CONFIG_FILE = "$env:USERPROFILE\.config\debloat.json"

# Enums.
enum Ensure {
    Absent
    Present
}

# Utilities.
# Windows 11 specific debloat configuration.
class Win11Config {
    [Nullable[bool]]$ClearStart
    [Nullable[bool]]$ClearStartAllUsers
    [Nullable[bool]]$RevertContextMenu
    [Nullable[bool]]$TaskbarAlignLeft
    [Nullable[bool]]$HideSearchTb
    [Nullable[bool]]$ShowSearchIconTb
    [Nullable[bool]]$ShowSearchLabelTb
    [Nullable[bool]]$ShowSearchBoxTb
    [Nullable[bool]]$HideTaskview
    [Nullable[bool]]$DisableCopilot
    [Nullable[bool]]$DisableRecall
    [Nullable[bool]]$HideHome
    [Nullable[bool]]$HideGallery
}

# Windows 10 specific debloat configuration.
class Win10Config {
    [Nullable[bool]]$HideOnedrive
    [Nullable[bool]]$Hide3dObjects
    [Nullable[bool]]$HideMusic
    [Nullable[bool]]$HideIncludeInLibrary
    [Nullable[bool]]$HideGiveAccessTo
    [Nullable[bool]]$HideShare
}

# Overall debloat configuration.
class Config {
    [Nullable[bool]]$RunDefaults
    [Nullable[bool]]$RemoveApps
    [Nullable[bool]]$RemoveAppsCustom
    [string[]]$RemoveAppsCustomList
    [Nullable[bool]]$RemoveCommApps
    [Nullable[bool]]$RemoveW11Outlook
    [Nullable[bool]]$RemoveDevApps
    [Nullable[bool]]$RemoveGamingApps
    [Nullable[bool]]$ForceRemoveEdge
    [Nullable[bool]]$DisableDVR
    [Nullable[bool]]$DisableTelemetry
    [Nullable[bool]]$DisableBing
    [Nullable[bool]]$DisableSuggestions
    [Nullable[bool]]$DisableLockscreenTips
    [Nullable[bool]]$ShowHiddenFolders
    [Nullable[bool]]$ShowKnownFileExt
    [Nullable[bool]]$HideDupliDrive
    [Nullable[bool]]$HideChat
    [Nullable[bool]]$DisableWidgets
    [Win11Config]$Win11
    [Win10Config]$Win10
}

# Compares two given configurations.
function Compare-Config {
    param (
        [Config]$Left,
        [Config]$Right
    )

    if ($null -eq $Left -or $null -eq $Right) {
        return $false
    }

    $leftJson = $Left | ConvertTo-Json
    $rightJson = $Right | ConvertTo-Json

    return $($leftJson -eq $rightJson)
}

# Returns the flags given a configuration.
function Get-Flags {
    param(
        [Parameter(Mandatory = $true)]
        [Config] $Config
    )

    function ConvertTo-Flags {
        param (
            [Parameter(Mandatory = $true)]
            [Object] $Obj,
            [ref] $Flags
        )

        $properties = $Obj | Get-Member -MemberType Properties
        foreach ($property in $properties) {
            $propName = $property.Name
            $value = $Obj."$propName"

            if ($null -ne $value -and $value -is [bool] -and $value -eq $true) { $Flags.Value += "-$propName" }
        }
    }

    $flags = @()

    ConvertTo-Flags -Obj $Config -Flags ([ref] $flags)
    if ($null -ne $Config.Win11) { ConvertTo-Flags -Obj $Config.Win11 -Flags ([ref] $flags) }
    if ($null -ne $Config.Win10) { ConvertTo-Flags -Obj $Config.Win10 -Flags ([ref] $flags) }

    return $flags -join " "
}

# Saves the configuration to the system.
function Set-Config {
    param(
        [Parameter(Mandatory = $true)]
        [Config] $Config
    )

    if (-not (Test-Path $CONFIG_FILE)) {
        New-Item -ItemType File -Path $CONFIG_FILE -Force
    }

    $Config | ConvertTo-Json | Set-Content $CONFIG_FILE
}

# Loads the configuration from the system.
function Get-Config {
    if (-not (Test-Path $CONFIG_FILE)) {
        return $null;
    }

    $loaded = Get-Content $CONFIG_FILE | ConvertFrom-Json
    return [Config]$loaded
}

#--------------------------------------------------------------------------------------------------#
# Debloats the Windows install.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class Debloat {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # The desired state of the resource.
    [DscProperty(Mandatory)]
    [Config] $Config

    # Flag, whether the config is out of sync with the resource definition.
    [DscProperty(NotConfigurable)]
    [Config] $LoadedConfig

    # Returns the current state of the resource.
    [Debloat] Get() {
        $c = Get-Config
        return @{
            Config       = $this.Config
            LoadedConfig = $c
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $state = $this.Get()
        $outOfSync = Compare-Config -Left $state.Config -Right $state.LoadedConfig

        return $outOfSync
    }

    # Sets the desired state of the resource.
    [void] Set() {
        if (!$this.Test()) {
            $state = $this.Get()

            $path = "$env:TMP/debloat"
            $archive = "$path/debloat.zip"
            $expandedArchivePath = "$path/Win11Debloat-master"
            $script = "$expandedArchivePath/Win11Debloat.ps1"

            try {
                New-Item -Path $path -ItemType Directory -Force | Out-Null
                Invoke-WebRequest http://github.com/raphire/win11debloat/archive/master.zip -OutFile $archive
                Expand-Archive $archive $path
                Remove-Item $archive

                if ($null -ne $state.Config.RemoveAppsCustomList -and $state.Config.RemoveAppsCustomList.Count -gt 0) {
                    $customAppsListFile = "$expandedArchivePath/CustomAppsList"
                    if (Test-Path $customAppsListFile) { Remove-Item -Path $customAppsListFile -Force }
                    New-Item -Path $customAppsListFile -ItemType File -Force | Out-Null

                    $state.Config.RemoveAppsCustomList | ForEach-Object {
                        Add-Content -Path $customAppsListFile -Value $_
                    }
                }

                $flags = $(Get-Flags -Config $state.Config) + " -Silent"
                $arguments = "-NoProfile -ExecutionPolicy Bypass -File $script $flags"

                Start-Process powershell.exe -ArgumentList $arguments -Wait
                Set-Config -Config $state.Config
            }
            catch {
                throw $_
            }
            finally {
                Remove-Item -Path $path -Recurse -Force
            }
        }
    }
}
