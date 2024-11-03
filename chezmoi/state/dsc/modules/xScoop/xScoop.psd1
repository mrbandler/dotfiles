@{
    RootModule           = 'xScoop.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = '0ac21b52-3429-4ace-8095-8ad8c49e47a0'
    Author               = 'Michael Baudler <me@mrbandler.dev>'
    CompanyName          = 'N/A'
    Copyright            = '(c) Michael Baudler. All rights reserved.'
    Description          = 'PowerShell Module with DSC resources related to Scoop <scoop.sh>'
    CompatiblePSEditions = 'Core'
    PowerShellVersion    = '5.1'
    DscResourcesToExport = @(
        'ScoopInstall',
        'ScoopBucket',
        'ScoopApp'
    )
}
