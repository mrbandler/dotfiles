# Variables.
$env:PATH += ";$env:USERPROFILE\.local\bin"
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"

# Aliases.
Set-Alias ll ls
Set-Alias find where.exe

# Customize prompt.
Invoke-Expression (&starship init powershell)

# Initialize zoxide.
Invoke-Expression (& { (zoxide init powershell | Out-String) })
