# Define Enums
enum Ensure {
    Absent
    Present
}

#--------------------------------------------------------------------------------------------------#
# Install Scoop DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class Install {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether scoop is installed or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalled

    # Returns the current state of the resource.
    [Install] Get() {
        $path = "$env:USERPROFILE/.config/scoop/config.json"
        $configExists = Test-Path -Path $path

        $commandExists = $false
        if (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
            $commandExists = $true
        }

        return @{
            Ensure      = $this.Ensure
            IsInstalled = $commandExists -and $configExists
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $state = $this.Get()

        if ($state.Ensure -eq [Ensure]::Present) {
            return $state.IsInstalled
        }
        else {
            return $state.IsInstalled -eq $false
        }
    }

    # Sets the desired state of the resource.
    [void] Set() {
        if (!$this.Test()) {
            # If scoop is not installed but the desired state is present, install it.
            if ($this.Ensure -eq [Ensure]::Present) {
                $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
                $windowsPrincipal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList @( $windowsIdentity )
                $isAdmin = $windowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

                $installerPath = "$env:TMP/install-scoop.ps1"
                Invoke-RestMethod get.scoop.sh -OutFile $installerPath

                $arguments = @(
                    "-NoProfile"
                    "-ExecutionPolicy Bypass"
                    "-File"
                    $installerPath
                )
                if ($isAdmin) { $arguments += "-RunAsAdmin" }
                Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Wait
                Remove-Item -Path $installerPath -Force
            }
            # If scoop is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                scoop uninstall scoop -ErrorAction SilentlyContinue | Out-Null
                Remove-Item -Recurse -Force $env:USERPROFILE/scoop
                Remove-Item -Recurse -Force $env:USERPROFILE/.config/scoop
            }
        }
    }
}

#--------------------------------------------------------------------------------------------------#
# Scoop Bucket DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class Bucket {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # Name of the bucket.
    [DscProperty(Mandatory)]
    [string] $Name

    # Repository of the bucket.
    [DscProperty()]
    [string] $Repo

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether the bucket is installed or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalled

    # Returns the current state of the resource.
    [Bucket] Get() {
        $bucket = scoop bucket list | Where-Object { $_.Name -eq $this.Name }

        return @{
            Name        = $bucket.Name
            Repo        = $bucket.Repo
            Ensure      = $this.Ensure
            IsInstalled = $null -ne $bucket
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $state = $this.Get()

        if ($state.Ensure -eq [Ensure]::Present) {
            return $state.IsInstalled
        }
        else {
            return $state.IsInstalled -eq $false
        }
    }

    # Sets the desired state of the resource.
    [void] Set() {
        if (!$this.Test()) {
            # If the bucket is not installed but the desired state is present, install it.
            if ($this.Ensure -eq [Ensure]::Present) {
                if ([string]::IsNullOrEmpty($this.Repo)) {
                    scoop bucket add $this.Name | Out-Null
                }
                else {
                    scoop bucket add $this.Name $this.Repo | Out-Null
                }
            }
            # If the bucket is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                scoop bucket rm $this.Name | Out-Null
            }
        }
    }
}

#--------------------------------------------------------------------------------------------------#
# Scoop App DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class App {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # Name of the app.
    [DscProperty()]
    [string] $Name

    # Name of the app.
    [DscProperty()]
    [string] $Version

    # Manifest of the app.
    [DscProperty()]
    [string] $Manifest

    # Flag, whether to install the app globally or not.
    [DscProperty()]
    [bool] $Global

    # Flag, whether to skip the download cache.
    [DscProperty()]
    [bool] $NoCache

    # Flag, whether to skip the hash validation (use with caution!).
    [DscProperty()]
    [bool] $SkipHashCheck

    # Flag, whether to skip the Scoop update before installing if it's outdated.
    [DscProperty()]
    [bool] $NoUpdateScoop

    # Architecture of the app.
    [DscProperty()]
    [string] $Arch

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether the app is installed or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalled

    # Flag, whether the app is installed globally or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalledGlobal

    # Returns the current state of the resource.
    [App] Get() {
        $app = scoop list | Where-Object { $_.Name -eq $this.Name }
        $installed = $null -ne $app
        $globallyInstalled = $false

        if ($installed) {
            $infoOutput = scoop info make -v
            $infoMap = @{}

            foreach ($line in $infoOutput) {
                $key, $value = $line -split ':\s+', 2
                if ($key -and $value) { $infoMap[$key.Trim()] = $value.Trim() }
            }

            $info = New-Object PSObject -Property $infoMap
            $globallyInstalled = $info.Installed -match "C:\\ProgramData\\scoop\\apps\\$($this.Name)"
        }

        return @{
            Name              = $app.Name
            Version           = $app.Version
            Manifest          = $this.Manifest
            Global            = $this.Global
            Independent       = $this.Independent
            NoCache           = $this.NoCache
            SkipHashCheck     = $this.SkipHashCheck
            NoUpdateScoop     = $this.NoUpdateScoop
            Arch              = $this.Arch
            Ensure            = $this.Ensure
            IsInstalled       = $installed
            IsInstalledGlobal = $globallyInstalled
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $state = $this.Get()

        if ($state.Ensure -eq [Ensure]::Present) {
            if ($state.IsInstalled) {
                return ($state.IsInstalledGlobal -eq $this.Global)
            }

            return $state.IsInstalled
        }
        else {
            return $state.IsInstalled -eq $false
        }
    }

    # Sets the desired state of the resource.
    [void] Set() {
        if (!$this.Test()) {
            # If the app is not installed but the desired state is present, install it.
            if ($this.Ensure -eq [Ensure]::Present) {
                # Uninstall if it's installed but with the wrong scope
                if ($this.IsInstalled -and (($this.IsGlobal -ne $this.Global))) {
                    $arguments = "--purge $($this.Name)"
                    $arguments = if ($this.IsGlobal) { "--global $arguments" } else { $arguments }
                    scoop uninstall $arguments | Out-Null
                }

                $arguments = if ([string]::IsNullOrEmpty($this.Manifest)) { $this.Name } else { $this.Manifest }
                $arguments = if ([string]::IsNullOrEmpty($this.Version)) { $arguments } else { "{0}@{1}" -f $arguments, $this.Version }
                $arguments = if ($this.Global) { "$arguments --global " } else { $arguments }
                $arguments = if ($this.NoCache) { "$arguments --no-cache " } else { $arguments }
                $arguments = if ($this.SkipHashCheck) { "$arguments --skip-hash-check" } else { $arguments }
                $arguments = if ($this.NoUpdateScoop) { "$arguments --no-update-scoop" } else { $arguments }
                if (![string]::IsNullOrEmpty($this.Arch)) {
                    $validArchValues = "bit32", "bit64", "arm64"
                    if ($this.Arch -in $validArchValues) { $arguments = "$arguments --arch $this.Arch" }
                }

                scoop install $arguments | Out-Null
            }
            # If the app is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                $arguments = "--purge $($this.Name)"
                $arguments = if ($this.IsGlobal) { "--global $arguments" } else { $arguments }

                scoop uninstall $arguments | Out-Null
            }
        }
    }
}
