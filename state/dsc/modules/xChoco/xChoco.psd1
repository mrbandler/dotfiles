@{
    RootModule           = 'xChoco.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = '49e9bd99-3497-4b16-97ea-dd6727d3e16c'
    Author               = 'mrbandler <me@mrbandler.dev>'
    CompanyName          = 'N/A'
    Copyright            = '(c) mrbandler. All rights reserved.'
    Description          = 'PowerShell Module with DSC resources related to Chocolatey <chocolatey.org>'
    CompatiblePSEditions = 'Core'
    PowerShellVersion    = '5.1'
    DscResourcesToExport = @(
        'ChocoInstall'
    )
}
