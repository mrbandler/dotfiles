# Variables.
$env:PATH += ";$env:USERPROFILE\.local\bin"
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"

# Aliases.
Set-Alias ll ls
Set-Alias find where.exe

# Functions.
function config {
    $params = @("--git-dir=$HOME\.dotfiles", "--work-tree=$HOME")
    $params += $args

    for ($i = 0; $i -lt $params.count; $i++)
    {
        $param = $params[$i]
        if (($param -replace "[^\s]").length -gt 0) { $params[$i] = "`"$param`"" }
    }

    Start-Process -NoNewWindow -FilePath $(Get-Command git).Source -ArgumentList $params -Wait
}

function cheat {
    Invoke-RestMethod cheat.sh/$($args -join " ")
}

# Import modules.
Import-Module PSReadLine
Import-Module posh-git
Import-Module Terminal-Icons

# Set PSReadLine options.
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineOption -Color @{
    "Command"   = [ConsoleColor]::Green
    "Parameter" = [ConsoleColor]::Gray
    "Operator"  = [ConsoleColor]::Magenta
    "Variable"  = [ConsoleColor]::White
    "String"    = [ConsoleColor]::Yellow
    "Number"    = [ConsoleColor]::Blue
    "Type"      = [ConsoleColor]::Cyan
    "Comment"   = [ConsoleColor]::DarkCyan
}

# Customize prompt.
Invoke-Expression (&starship init powershell)
