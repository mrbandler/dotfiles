@{
    RootModule           = 'xDebloat.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'efa04e70-a44b-458e-9a30-db6b87d14ae6'
    Author               = 'mrbandler <me@mrbandler.dev>'
    CompanyName          = 'N/A'
    Copyright            = '(c) mrbandler. All rights reserved.'
    Description          = 'PowerShell Module with DSC resources related to debloating Windows 10/11.'
    CompatiblePSEditions = 'Core'
    PowerShellVersion    = '5.1'
    DscResourcesToExport = @(
        'Debloat'
    )
}
