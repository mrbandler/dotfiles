Configuration Config {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {
        # Ensure a file exists
        File ExampleFile {
            DestinationPath = "C:\example.txt"
            Contents        = "Hello, DSC!"
        }

        # Ensure a Windows feature is installed
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        # Ensure a Chocolatey package is installed
        Package Git {
            Name         = "git"
            Ensure       = "Present"
            Path         = "C:\ProgramData\chocolatey\choco.exe"
            ProductId   = ""
        }
    }
}

# Generate the MOF file
Config -OutputPath "."
