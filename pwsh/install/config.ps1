# Create `.config` directory in home
if (-Not (Test-Path $env:USERPROFILE\.config)) {
    New-Item -ItemType Directory -Path $env:USERPROFILE\.config
}

# Add custom pwsh profile.
Add-Content $PROFILE.CurrentUserCurrentHost '. $env:USERPROFILE\.config\pwsh\profile.ps1'

# Install Spacemacs (https://www.spacemacs.org)
git clone https://github.com/syl20bnr/spacemacs $env:USERPROFILE\.config\.emacs.d

Move-Item $env:APPDATA\.emacs.d $env:APPDATA\.emacs.d.bak
New-Item -ItemType SymbolicLink -Path $env:APPDATA\.emacs.d -Target $env:USERPROFILE\.config\.emacs.d

# Install Astro Vim (https://astronvim.github.io)
git clone https://github.com/AstroNvim/AstroNvim $env:USERPROFILE\.config\nvim

Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak
New-Item -ItemType SymbolicLink -Path $env:LOCALAPPDATA\nvim -Target $env:USERPROFILE\.config\nvim

# Install node.js
nvm install 16.18.1
nvm install 18.12.1
nvm use 16.18.1

# Install Unison
Invoke-WebRequest -Uri https://github.com/unisonweb/unison/releases/download/latest/ucm-windows.zip -OutFile ucm.zip
7z x ucm.zip -oucm
New-Item -ItemType Directory -Path $env:USERPROFILE\.config\bin
Copy-Item -r ucm\* $env:USERPROFILE\.config\bin
Remove-Item -r .\ucm
Remove-Item .\ucm.zip
