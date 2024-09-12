# Constants.
$CONFIG_FILE = "$env:USERPROFILE\config\debloat.json"

# Enums.
enum Ensure {
    Absent
    Present
}

# Utilities.
# Windows 11 specific debloat configuration.
class Win11Config {
    [bool]$ClearStart
    [bool]$ClearStartAllUsers
    [bool]$RevertContextMenu
    [bool]$TaskbarAlignLeft
    [bool]$HideSearchTb
    [bool]$ShowSearchIconTb
    [bool]$ShowSearchLabelTb
    [bool]$ShowSearchBoxTb
    [bool]$HideTaskview
    [bool]$DisableCopilot
    [bool]$DisableRecall
    [bool]$HideHome
    [bool]$HideGallery
}

# Windows 10 specific debloat configuration.
class Win10Config {
    [bool]$HideOnedrive
    [bool]$Hide3dObjects
    [bool]$HideMusic
    [bool]$HideIncludeInLibrary
    [bool]$HideGiveAccessTo
    [bool]$HideShare
}

# Overall debloat configuration.
class Config {
    [bool]$RunDefaults
    [bool]$RemoveApps
    [bool]$RemoveAppsCustom
    [string[]]$RemoveAppsCustomList
    [bool]$RemoveCommApps
    [bool]$RemoveOutlook
    [bool]$RemoveDevApps
    [bool]$RemoveGamingApps
    [bool]$ForceRemoveEdge
    [bool]$DisableDVR
    [bool]$DisableTelemetry
    [bool]$DisableBing
    [bool]$DisableSuggestions
    [bool]$DisableLockscreenTips
    [bool]$ShowHiddenFolders
    [bool]$ShowKnownFileExt
    [bool]$HideDupliDrive
    [bool]$HideChat
    [bool]$DisableWidgets
    [Win11Config]$Win11
    [Win10Config]$Win10
}

function Compare-Config {
    param (
        [Parameter(Mandatory = $true)]
        [Config]$Left,
        [Parameter(Mandatory = $true)]
        [Config]$Right
    )

    if ($null -eq $Left -or $null -eq $Right) {
        return $false
    }

    $leftJson = $Left | ConvertTo-Json
    $rightJson = $Right | ConvertTo-Json

    return $($leftJson -eq $rightJson)
}

function Get-Flags {
    param(
        [Parameter(Mandatory = $true)]
        [Config] $Config
    )

    $flags = @()

    function ConvertTo-Flags {
        param (
            [Parameter(Mandatory)]
            [Object]$obj
        )

        $properties = $obj | Get-Member -MemberType Properties
        foreach ($property in $properties) {
            $propName = $property.Name
            $value = $obj."$propName"

            if ($value -is [System.Boolean] -and $value -eq $true) {
                $flag = "-$propName"
                $flags += $flag
            }
        }
    }

    ConvertTo-Flags -obj $config
    if ($config.Win11) { ConvertTo-Flags -obj $config.Win11 }
    if ($config.Win10) { ConvertTo-Flags -obj $config.Win10 }

    return $flags -join " "
}

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

function Get-Config {
    param ()

    if (-not $(Test-Path $CONFIG_FILE)) {
        return $null;
    }

    $loaded = Get-Content $CONFIG_FILE | ConvertFrom-Json
    return [Config]::new(
        $loaded.RunDefaults,
        $loaded.RemoveApps,
        $loaded.RemoveAppsCustom,
        $loaded.RemoveAppsCustomList,
        $loaded.RemoveCommApps,
        $loaded.RemoveOutlook,
        $loaded.RemoveDevApps,
        $loaded.RemoveGamingApps,
        $loaded.ForceRemoveEdge,
        $loaded.DisableDVR,
        $loaded.DisableTelemetry,
        $loaded.DisableBing,
        $loaded.DisableSuggestions,
        $loaded.DisableLockscreenTips,
        $loaded.ShowHiddenFolders,
        $loaded.ShowKnownFileExt,
        $loaded.HideDupliDrive,
        $loaded.HideChat,
        $loaded.DisableWidgets,
        [Win11Config]::new(
            $loaded.Win11.ClearStart,
            $loaded.Win11.ClearStartAllUsers,
            $loaded.Win11.RevertContextMenu,
            $loaded.Win11.TaskbarAlignLeft,
            $loaded.Win11.HideSearchTb,
            $loaded.Win11.ShowSearchIconTb,
            $loaded.Win11.ShowSearchLabelTb,
            $loaded.Win11.ShowSearchBoxTb,
            $loaded.Win11.HideTaskview,
            $loaded.Win11.DisableCopilot,
            $loaded.Win11.DisableRecall,
            $loaded.Win11.HideHome,
            $loaded.Win11.HideGallery
        ),
        [Win10Config]::new(
            $loaded.Win10.HideOnedrive,
            $loaded.Win10.Hide3dObjects,
            $loaded.Win10.HideMusic,
            $loaded.Win10.HideIncludeInLibrary,
            $loaded.Win10.HideGiveAccessTo,
            $loaded.Win10.HideShare
        )
    )
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
        return @{
            Config       = $this.Config
            LoadedConfig = Get-Config
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

            $debloatPath = "$env:TEMP/Win11Debloat/Win11Debloat-master"
            $path = "$env:TMP/debloat";
            New-Item -Path $path -ItemType Directory -Force | Out-Null
            $script = "$path/run.ps1"
            Invoke-RestMethod win11debloat.raphi.re -OutFile $script

            if ($null -ne $state.Config.RemoveAppsCustomList -and $state.Config.RemoveAppsCustomList.Count -gt 0) {
                $customAppsListFile = "$debloatPath/CustomAppsList"
                if (Test-Path $customAppsListFile) { Remove-Item -Path $customAppsListFile -Force }
                New-Item -Path $customAppsListFile -ItemType File -Force | Out-Null

                $state.Config.RemoveAppsCustomList | ForEach-Object {
                    Add-Content -Path $customAppsListFile -Value $_
                }
            }

            $flags = $(Get-Flags -Config $state.Config) + " -Silent"
            $cmd = "& $script $flags"

            throw "About to run $cmd in $debloatPath"

            Invoke-Expression $cmd

            Remove-Item -Path $path -Force
            Set-Config -Config $state.Config
        }
    }
}
