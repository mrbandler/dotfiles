# Enums.
enum Ensure {
    Absent
    Present
}

#--------------------------------------------------------------------------------------------------#
# Windows Optional Feature DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class WindowsOptionalFeature {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # Name of the feature.
    [DscProperty(Mandatory)]
    [string] $Name

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether the feature is enabled or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsEnabled

    hidden [string] GetDismPath() {
        return Join-Path $env:SystemRoot "System32\dism.exe"
    }

    # Returns the current state of the resource.
    [WindowsOptionalFeature] Get() {
        $dismPath = $this.GetDismPath()
        $result = & $dismPath /Online /Get-FeatureInfo /FeatureName:$($this.Name) 2>&1

        return @{
            Ensure = $this.Ensure
            IsEnabled = $result | Select-String "State : Enabled" -Quiet
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $state = $this.Get()

        if ($state.Ensure -eq [Ensure]::Present) {
            return $state.IsEnabled
        }
        else {
            return $state.IsEnabled -eq $false
        }
    }

    # Sets the desired state of the resource.
    [void] Set() {
        if (!$this.Test()) {
            $dismPath = $this.GetDismPath()

            # If feature is not enabled but the desired state is present, install it.
            if ($this.Ensure -eq [Ensure]::Present) {
                & $dismPath /Online /Enable-Feature /FeatureName:$($this.Name) /NoRestart
            }
            # If feature is enabled but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                & $dismPath /Online /Disable-Feature /FeatureName:$($this.Name) /NoRestart
            }
        }
    }
}
