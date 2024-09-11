# Enums.
enum Ensure {
    Absent
    Present
}

enum InstallerType {
    MSI
    EXE
    ZIP
    MSIX
}


#--------------------------------------------------------------------------------------------------#
# Install Scoop DSC Resource.
#--------------------------------------------------------------------------------------------------#
[DSCResource()]
class PkgDownloadAndInstall {
    # We need a key. Do not set.
    [DscProperty(Key)]
    [string]$SID

    # Condition to run the resource.
    [DscProperty()]
    [string] $If

    # Name of the package.
    [DscProperty(Mandatory)]
    [string] $Name

    # Type of the installer.
    [DscProperty(Mandatory)]
    [InstallerType] $Type

    # URL to download the package from.
    [DscProperty(Mandatory)]
    [string] $Url

    # Headers for the download request.
    [DscProperty()]
    [hashtable] $Headers = @{}

    # Arguments to pass to the installer.
    [DscProperty()]
    [string] $Arguments

    # State of the resouce.
    [DscProperty(Mandatory)]
    [Ensure] $Ensure = [Ensure]::Present

    # Flag, whether package is installed or not.
    [DscProperty(NotConfigurable)]
    [bool] $IsInstalled

    # Returns the current state of the resource.
    [PkgDownloadAndInstall] Get() {
        $uninstallKeyPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        )

        $foundUninstallers = @()
        foreach ($keyPath in $uninstallKeyPaths) {
            $uninstallers = Get-ItemProperty "$keyPath\*" | Where-Object { $_.DisplayName -like "*$($this.Name)*" }
            if ($uninstallers) {
                $foundUninstallers += $uninstallers
            }
        }

        return @{
            Ensure      = $this.Ensure
            IsInstalled = $foundUninstallers.Count -gt 0
        }
    }

    # Tests the current state of the resource.
    [bool] Test() {
        if (![string]::IsNullOrEmpty($this.If)) {
            $shouldRun = Invoke-Expression $this.If
            if (!$shouldRun) { return $true }
        }

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
            if ($this.Ensure -eq [Ensure]::Present) {
                $installerPath = [System.IO.Path]::GetTempFileName();

                if ($this.Type -eq [InstallerType]::MSI) { $installerPath += ".msi" }
                elseif ($this.Type -eq [InstallerType]::EXE) { $installerPath += ".exe" }
                elseif ($this.Type -eq [InstallerType]::ZIP) { throw "ZIP installer type is not supported yet." }
                elseif ($this.Type -eq [InstallerType]::MSIX) { throw "MSIX installer type is not supported yet." }
                else { throw "Unknown installer type." }

                Invoke-WebRequest -Uri $this.Url -OutFile $installerPath -Headers $this.Headers
                $process = Start-Process -FilePath $installerPath -ArgumentList $this.Arguments -PassThru
                $process.WaitForExit()

                Remove-Item -Path $installerPath

                if ($process.ExitCode -ne 0) {
                    Write-Error "Failed to install package."
                }
            }
            elseif ($this.Ensure -eq [Ensure]::Absent) {
                $uninstallKeyPaths = @(
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
                    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
                )

                $foundUninstallers = @()
                foreach ($keyPath in $uninstallKeyPaths) {
                    $uninstallers = Get-ItemProperty "$keyPath\*" | Where-Object { $_.DisplayName -like "*$($this.Name)*" }
                    if ($uninstallers) {
                        $foundUninstallers += $uninstallers
                    }
                }

                foreach ($uninstaller in $foundUninstallers) {
                    if ($uninstaller.UninstallString -match '^(?:"([^"]+)"|([^\s]+))\s*(.*)$') {
                        $exePath = $matches[1]
                        if (-not $exePath) {
                            $exePath = $matches[2]
                        }
                        $uninstallArgs = $matches[3]

                        # Ensure the executable path is properly quoted if not already
                        if ($exePath -notlike '"*"') {
                            $exePath = '"' + $exePath + '"'
                        }

                        # Start the uninstallation process using Start-Process
                        if ($uninstallArgs) {
                            Start-Process -FilePath $exePath -ArgumentList $uninstallArgs -Wait
                        }
                        else {
                            Start-Process -FilePath $exePath -Wait
                        }
                    }
                    else {
                        throw "Failed to parse UninstallString: $($uninstaller.UninstallString)"
                    }
                }
            }
        }
    }
}
