# Constants.
$SCOOP_DIR = $env:SCOOP, "$env:USERPROFILE\scoop" | Where-Object { -not [String]::IsNullOrEmpty($_) } | Select-Object -First 1
$SCOOP_SHIMS_DIR = "$SCOOP_DIR\shims"

# Enums.
enum Ensure {
    Absent
    Present
}

# Helper functions.
function Add-ScoopToPath {
    $env:PATH += $SCOOP_SHIMS_DIR
}

#--------------------------------------------------------------------------------------------------#
# Install Scoop DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class ScoopInstall {
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
    [ScoopInstall] Get() {
        Add-ScoopToPath
        $path = "$env:USERPROFILE/.config/scoop/config.json"
        $configExists = Test-Path -Path $path

        $cmdExists = $false
        if (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
            $cmdExists = $true
        }

        return @{
            Ensure      = $this.Ensure
            IsInstalled = $cmdExists -and $configExists
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

                New-Item -Path "$env:TMP/scoop" -ItemType Directory -Force | Out-Null
                $installerPath = "$env:TMP/scoop/install-scoop.ps1"
                Invoke-RestMethod get.scoop.sh -OutFile $installerPath

                # Replace `Write-InstallInfo` function since it access $host which is not available in DSC.
                $scriptContent = Get-Content -Path $installerPath -Raw
                $ast = [System.Management.Automation.Language.Parser]::ParseFile($installerPath, [ref]$null, [ref]$null)
                $writeInstallInfoFunc = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $args[0].Name -eq "Write-InstallInfo" }, $true)
                $replacementFunction = 'function Write-InstallInfo { param([String] $String, [System.ConsoleColor] $ForegroundColor = [System.ConsoleColor]::Gray) Write-Verbose "$String" }'
                Set-Content -Path $installerPath -Value $($scriptContent -replace [regex]::Escape($writeInstallInfoFunc.Extent.Text), $replacementFunction)

                $arguments = "";
                if ($isAdmin) { $arguments += "-RunAsAdmin" }
                $cmd = "& $installerPath $arguments"
                Invoke-Expression $cmd | Out-Null

                Remove-Item -Path $installerPath -Force
                # Add-ScoopToPath
            }
            # If scoop is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                $cmd = "& scoop uninstall scoop -ErrorAction SilentlyContinue"
                Invoke-Expression $cmd | Out-Null
                Remove-Item -Recurse -Force $env:USERPROFILE/scoop
                Remove-Item -Recurse -Force $env:USERPROFILE/.config/scoop
            }
        }
    }
}

#--------------------------------------------------------------------------------------------------#
# Update Scoop DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class ScoopUpdate {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether scoop is installed with the latest version or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsLatest

    # Returns the current state of the resource.
    [ScoopUpdate] Get() {
        # Add-ScoopToPath
        $status = scoop status
        $latest = $status -match "Scoop is up to date"

        return @{
            Ensure   = $this.Ensure
            IsLatest = $latest
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        $state = $this.Get()

        if ($state.Ensure -eq [Ensure]::Present) {
            return $state.IsLatest
        }
        else {
            return $state.IsLatest -eq $false
        }
    }

    # Sets the desired state of the resource.
    [void] Set() {
        if (!$this.Test()) {
            # If scoop is not up to date but the desired state is present, update it.
            if ($this.Ensure -eq [Ensure]::Present) {
                $cmd = "& scoop update"
                Invoke-Expression $cmd | Out-Null
            }
            # If scoop is not up to date but the desired state is absent, do nothing.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
            }
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

    # Flag, whether the bucket is installed or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalled

    # Returns the current state of the resource.
    [ScoopBucket] Get() {
        # Add-ScoopToPath
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
                    $cmd = "& scoop bucket add $($this.Name)"
                    Invoke-Expression $cmd | Out-Null
                }
                else {
                    $cmd = "& scoop bucket add $($this.Name) $($this.Repo)"
                    Invoke-Expression $cmd | Out-Null
                }
            }
            # If the bucket is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                $cmd = "& scoop bucket rm $($this.Name)"
                Invoke-Expression $cmd | Out-Null
            }
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

    # Name of the app.
    [DscProperty()]
    [string] $Version

    # Manifest of the app.
    [DscProperty()]
    [string] $Manifest

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

    # Returns the current state of the resource.
    [ScoopApp] Get() {
        # Add-ScoopToPath
        $app = scoop list | Where-Object { $_.Name -eq $this.Name }
        $installed = $null -ne $app

        return @{
            Name          = $app.Name
            Version       = $app.Version
            Manifest      = $this.Manifest
            NoCache       = $this.NoCache
            SkipHashCheck = $this.SkipHashCheck
            NoUpdateScoop = $this.NoUpdateScoop
            Arch          = $this.Arch
            Ensure        = $this.Ensure
            IsInstalled   = $installed
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
            # If the app is not installed but the desired state is present, install it.
            if ($this.Ensure -eq [Ensure]::Present) {
                $arguments = @()

                if ([string]::IsNullOrEmpty($this.Manifest)) {
                    $value = if (![string]::IsNullOrEmpty($this.Version)) { "{0}@{1}" -f $this.Name, $this.Version } else { $this.Name }
                    $arguments += $value
                }
                else {
                    $value = if (![string]::IsNullOrEmpty($this.Version)) { "{0}@{1}" -f $this.Manifest, $this.Version } else { $this.Manifest }
                    $arguments += $value
                }

                if ($this.NoCache) { $arguments += "--no-cache" }
                if ($this.SkipHashCheck) { $arguments += "--skip-hash-check" }
                if ($this.NoUpdateScoop) { $arguments += "--no-update-scoop" }
                if (![string]::IsNullOrEmpty($this.Arch)) {
                    $validArchValues = "32bit", "64bit", "arm64"
                    if ($this.Arch -in $validArchValues) { $arguments += "--arch $this.Arch" }
                }

                $cmd = "& scoop install $($arguments -join " ")"
                Invoke-Expression $cmd | Out-Null
            }
            # If the app is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                $cmd = "& scoop uninstall $($this.Name) --purge"
                Invoke-Expression $cmd | Out-Null
            }
        }
    }
}
