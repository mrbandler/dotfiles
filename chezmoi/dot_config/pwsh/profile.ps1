# Environment check.
$isCore = $PSVersionTable.PSEdition -eq "Core"

# Variables.
$env:PATH += ";$env:USERPROFILE\.local\bin"
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"

# Aliases.
Set-Alias ll ls
Set-Alias find where.exe

# # Import modules.
# Import-Module PSReadLine
# Import-Module posh-git
# Import-Module Terminal-Icons

# # Set PSReadLine options.
# Set-PSReadLineOption -PredictionViewStyle ListView
# Set-PSReadLineOption -EditMode Emacs
# Set-PSReadLineOption -BellStyle None
# Set-PSReadLineOption -PredictionSource History
# Set-PSReadlineOption -Color @{
#     "Command"   = [ConsoleColor]::Green
#     "Parameter" = [ConsoleColor]::Gray
#     "Operator"  = [ConsoleColor]::Magenta
#     "Variable"  = [ConsoleColor]::White
#     "String"    = [ConsoleColor]::Yellow
#     "Number"    = [ConsoleColor]::Blue
#     "Type"      = [ConsoleColor]::Cyan
#     "Comment"   = [ConsoleColor]::DarkCyan
# }

# Customize prompt.
Invoke-Expression (&starship init powershell)
