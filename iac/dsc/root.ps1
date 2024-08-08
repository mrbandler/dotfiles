Configuration Root {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {
        File ExampleFile {
            DestinationPath = "C:\Users\mrbandler\example.txt"
            Contents        = "Hello, DSC!"
            Ensure          = "Present"
        }
    }
}

Root -OutputPath "$PSScriptRoot/config" | Out-Null
Start-DscConfiguration -Path "$PSScriptRoot/config" -Wait -Verbose
Remove-Item -Recurse -Path "$PSScriptRoot/config"
