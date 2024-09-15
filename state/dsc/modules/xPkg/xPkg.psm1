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

    # Command to install a zip.
    [DscProperty()]
    [string] $ZipInstall

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

                if ($this.Type -eq [InstallerType]::MSI) { 
                    $installerPath += ".msi"
                    $arguments = "$installerPath $($this.Arguments)"

                    Invoke-WebRequest -Uri $this.Url -OutFile $installerPath -Headers $this.Headers
                    Start-Process msiexec -ArgumentList $arguments -Wait
                } elseif ($this.Type -eq [InstallerType]::EXE) {
                     $installerPath += ".exe" 

                    Invoke-WebRequest -Uri $this.Url -OutFile $installerPath -Headers $this.Headers
                    Start-Process -FilePath $installerPath -ArgumentList $this.Arguments -Wait
                } elseif ($this.Type -eq [InstallerType]::ZIP) {
                    if (![string]::IsNullOrEmpty($this.ZipInstall)) throw "Unable to install, ZipInstall was not specified, "
                    
                    $installerPath += ".zip"
                    Invoke-WebRequest -Uri $this.Url -OutFile $installerPath -Headers $this.Headers
                    
                    $unzippedPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())
                    Expand-Archive -Path $installerPath -DestinationPath $unzippedPath

                    $cmd = $this.ZipInstall
                    $cmd = $cmd -replace '\$\{zip\}', $installerPath
                    $cmd = $cmd -replace '\$\{unzipped\}', $unzippedPath
                    Invoke-Expression $cmd | Out-Null

                    Remove-Item -Path $unzippedPath -Recurse -Force
                } elseif ($this.Type -eq [InstallerType]::MSIX) {
                    throw "MSIX installer type is not supported yet." 
                } else { throw "Unknown installer type." }

                Remove-Item -Path $installerPath -Force

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
                    $uninstallString = if (![string]::IsNullOrEmpty($uninstaller.QuietUninstallString)) {
                        $uninstaller.QuietUninstallString
                    }
                    else {
                        $uninstaller.UninstallString
                    }

                    if ($uninstallString -match '^(?:"([^"]+)"|([^\s]+))\s*(.*)$') {
                        $exePath = $matches[1]
                        if (-not $exePath) { $exePath = $matches[2] }
                        $uninstallArgs = $matches[3]

                        if ($exePath -notlike '"*"') { $exePath = '"' + $exePath + '"' }
                        if ($uninstallArgs) {
                            Start-Process -FilePath $exePath -ArgumentList $uninstallArgs -Wait
                        }
                        else {
                            Start-Process -FilePath $exePath -Wait
                        }
                    }
                    else {
                        throw "Failed to parse UninstallString: $uninstallString"
                    }
                }
            }
        }
    }
}
