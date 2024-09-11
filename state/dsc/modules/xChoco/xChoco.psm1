# Enums.
enum Ensure {
    Absent
    Present
}

# Utils.
function global:Write-Host {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalFunctions", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "NoNewLine")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "ForegroundColor")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "BackgroundColor")]
    Param(
        [Parameter(Mandatory, Position = 0)]
        $Object,
        [Switch]
        $NoNewLine,
        [ConsoleColor]
        $ForegroundColor,
        [ConsoleColor]
        $BackgroundColor
    )
    #Redirecting Write-Host -> Write-Verbose.
    Write-Verbose $Object
}

function Add-ChocoToPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($env:path -notlike "*$InstallDir*") {
        $env:Path += ";$InstallDir"
    }
}

#--------------------------------------------------------------------------------------------------#
# Install Choco DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class ChocoInstall {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether choco is installed or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalled

    # Returns the current state of the resource.
    [ChocoInstall] Get() {
        Add-ChocoToPath

        $cmdExists = $false
        if (Get-Command -Name "choco" -ErrorAction SilentlyContinue) {
            $cmdExists = $true
        }

        return @{
            Ensure      = $this.Ensure
            IsInstalled = $cmdExists
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
            # If choco is not installed but the desired state is present, install it.
            if ($this.Ensure -eq [Ensure]::Present) {
                New-Item -Path "$env:TMP/choco" -ItemType Directory -Force | Out-Null
                $installerPath = "$env:TMP/choco/install.ps1"
                Invoke-RestMethod chocolatey.org/install.ps1 -OutFile $installerPath

                # # Replace `Write-InstallInfo` function since it access $host which is not available in DSC.
                # $scriptContent = Get-Content -Path $installerPath -Raw
                # $ast = [System.Management.Automation.Language.Parser]::ParseFile($installerPath, [ref]$null, [ref]$null)
                # $writeInstallInfoFunc = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $args[0].Name -eq "Write-InstallInfo" }, $true)
                # $replacementFunction = 'function Write-InstallInfo { param([String] $String, [System.ConsoleColor] $ForegroundColor = [System.ConsoleColor]::Gray) Write-Verbose "$String" }'
                # Set-Content -Path $installerPath -Value $($scriptContent -replace [regex]::Escape($writeInstallInfoFunc.Extent.Text), $replacementFunction)

                $cmd = "& $installerPath"
                Invoke-Expression $cmd
                Remove-Item -Path $installerPath -Force
            }
            # If choco is installed but the desired state is absent, uninstall it.
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                $userKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
                $userPath = $userKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

                $machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\', $true)
                $machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

                $backupPATHs = @(
                    "User PATH: $userPath"
                    "Machine PATH: $machinePath"
                )
                $backupFile = "C:\PATH_backups_ChocolateyUninstall.txt"
                $backupPATHs | Set-Content -Path $backupFile -Encoding UTF8 -Force

                if ($userPath -like "*$env:ChocolateyInstall*") {
                    Write-Verbose "Chocolatey Install location found in User Path. Removing..."

                    $newUserPATH = @(
                        $userPath -split [System.IO.Path]::PathSeparator |
                        Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
                    ) -join [System.IO.Path]::PathSeparator

                    # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
                    # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
                    $userKey.SetValue('PATH', $newUserPATH, 'ExpandString')
                }

                if ($machinePath -like "*$env:ChocolateyInstall*") {
                    Write-Verbose "Chocolatey Install location found in Machine Path. Removing..."

                    $newMachinePATH = @(
                        $machinePath -split [System.IO.Path]::PathSeparator |
                        Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
                    ) -join [System.IO.Path]::PathSeparator

                    # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
                    # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
                    $machineKey.SetValue('PATH', $newMachinePATH, 'ExpandString')
                }

                # Adapt for any services running in subfolders of ChocolateyInstall
                $agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
                if ($agentService -and $agentService.Status -eq 'Running') {
                    $agentService.Stop()
                }

                Remove-Item -Path $env:ChocolateyInstall -Recurse -Force -WhatIf

                'ChocolateyInstall', 'ChocolateyLastPathUpdate' | ForEach-Object {
                    foreach ($scope in 'User', 'Machine') {
                        [Environment]::SetEnvironmentVariable($_, [string]::Empty, $scope)
                    }
                }

                $machineKey.Close()
                $userKey.Close()

                if ($env:ChocolateyToolsLocation -and (Test-Path $env:ChocolateyToolsLocation)) {
                    Remove-Item -Path $env:ChocolateyToolsLocation -Recurse -Force
                }

                foreach ($scope in 'User', 'Machine') {
                    [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, $scope)
                }
            }
        }
    }
}

#--------------------------------------------------------------------------------------------------#
# Choco Package DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class ChocoPackage {
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
    [ChocoPackage] Get() {
        Add-ChocoToPath

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
