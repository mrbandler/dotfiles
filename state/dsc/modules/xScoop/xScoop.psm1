# Define Enums
enum Ensure {
    Absent
    Present
}

enum Arch {
    bit32
    bit64
    arm64
}

#--------------------------------------------------------------------------------------------------#
# Scoop DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class Scoop {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Returns the current state of the resource.
    [Scoop] Get() {
        $resource = [Scoop]::new()

        if ($resource.Test()) {
            $resource.Ensure = [Ensure]::Present
        } else {
            $resource.Ensure = [Ensure]::Absent
        }

        return $resource
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $path = "$env:USERPROFILE/.config/scoop/config.json"
        $configExists = Test-Path -Path $path
        $commandExists = $false
        if (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
            $commandExists = $true
        }

        if (PsDscContext.RunAsUser) {
            Write-Verbose "Config exists: $configExists";
            Write-Verbose "Command exists: $commandExists";
        }

        return $commandExists -and $configExists
    }

    # Sets the desired state of the resource.
    [void] Set() {
        $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $windowsPrincipal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList @( $windowsIdentity )
        $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
        $isAdmin = $windowsPrincipal.IsInRole($adminRole)
        $isInstalled = $this.Test()

        # If scoop is not installed but the desired state is present, install it.
        if ($this.Ensure -eq [Ensure]::Present -and -not $isInstalled) {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
            $cmd = "& {$(Invoke-RestMethod get.scoop.sh)}"
            $cmd += " -RunAsAdmin"

            Invoke-Expression $cmd | Out-Null
        }
        # If scoop is installed but the desired state is absent, uninstall it.
        elseif (this.Ensure -eq [Ensure]::Absent -and $isInstalled) {
            scoop uninstall scoop -ErrorAction SilentlyContinue | Out-Null
            Remove-Item -Recursive -Force $env:USERPROFILE/scoop
            Remove-Item -Recursive -Force $env:USERPROFILE/.config/scoop
        }
    }
}

#--------------------------------------------------------------------------------------------------#
# Scoop Bucket DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class ScoopBucket {
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

    # Returns the current state of the resource.
    [ScoopBucket] Get() {
        $resource = [Scoop]::new()

        if ($resource.Test()) {
            $resource.Ensure = [Ensure]::Present
        } else {
            $resource.Ensure = [Ensure]::Absent
        }

        return $resource
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $bucket = scoop bucket list | Where-Object { $_.Name -eq $this.Name }
        return $bucket -ne $null
    }

    # Sets the desired state of the resource.
    [void] Set() {
        $isInstalled = $this.Test()

        # If the bucket is not installed but the desired state is present, install it.
        if ($this.Ensure -eq [Ensure]::Present -and -not $isInstalled) {
            if ($this.Repo -ne $null) {
                scoop bucket add $this.Name $this.Repo
            } else {
                scoop bucket add $this.Name
            }
        }
        # If the bucket is installed but the desired state is absent, uninstall it.
        elseif ($this.Ensure -eq [Ensure]::Absent -and $isInstalled) {
            scoop bucket remove $this.Name
        }
    }
}

#--------------------------------------------------------------------------------------------------#
# Scoop App DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class ScoopApp {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # Name of the app.
    [DscProperty()]
    [string] $Name

    # Manifest of the app.
    [DscProperty()]
    [string] $Manifest

    # Flag, whether to install the app globally or not.
    [DscProperty()]
    [bool] $Global

    # Flag, whether to install dependencies automatically.
    [DscProperty()]
    [bool] $Independent

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
    [Arch] $Arch

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Returns the current state of the resource.
    [ScoopApp] Get() {
        $resource = [Scoop]::new()

        if ($resource.Test()) {
            $resource.Ensure = [Ensure]::Present
        } else {
            $resource.Ensure = [Ensure]::Absent
        }

        return $resource
    }

    # Tests the current state of the resource.
    [bool] Test() {
        # TODO: Implement Test-TargetResource
        return $false;
    }

    # Sets the desired state of the resource.
    [void] Set() {
        # TODO: Implement Set-TargetResource
    }
}
