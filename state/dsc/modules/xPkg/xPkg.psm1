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

    [DscProperty()]
    [string] $If

    [DscProperty(Mandatory)]
    [string] $Name

    [DscProperty(Mandatory)]
    [InstallerType] $InstallerType

    [DscProperty(Mandatory)]
    [string] $Url

    [DscProperty()]
    [System.Collections.Generic.Dictionary[String, String]] $Headers

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
            $uninstallers = Get-ItemProperty "$keyPath\*" | Where-Object { $_.DisplayName -like "*$programName*" }
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
        $shouldRun = Invoke-Expression $this.If
        if (!$shouldRun) { return $true }

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

                switch ($this.InstallerType) {
                    [InstallerType]::MSI {
                        $installerPath += ".msi";
                    }
                    [InstallerType]::EXE {
                        $installerPath += ".exe";
                    }
                    [InstallerType]::ZIP {
                        Write-Error "ZIP installer type is not supported yet."

                        return
                    }
                    [InstallerType]::MSIX {
                        Write-Error "ZIP installer type is not supported yet."

                        return
                    }
                    default {
                        Write-Error "Unknown installer type."

                        return
                    }
                }

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
                    $uninstallers = Get-ItemProperty "$keyPath\*" | Where-Object { $_.DisplayName -like "*$programName*" }
                    if ($uninstallers) {
                        $foundUninstallers += $uninstallers
                    }
                }

                foreach ($uninstaller in $foundUninstallers) {
                    Invoke-Expression "& '$($uninstaller.UninstallString)'"
                }
            }
        }
    }
}
