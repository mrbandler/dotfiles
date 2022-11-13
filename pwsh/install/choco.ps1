# Install CLI.
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco feature enable -n=allowGlobalConfirmation

# Install packages.

# Essentials.
choco install 7zip
choco install git
choco install git-lfs
choco install files
choco install cryptomator
choco install ueli
choco install greenshot
choco install powertoys
choco install brave
choco install obsidian
choco install spotify
choco install spotify-tui
choco install spicetify-cli
choco install voicemeeter-banana
choco install eartrumpet
choco install geforce-game-ready-driver
choco install geforce-experience
choco install googledrive
choco install grammarly-for-windows
choco install betterdiscord
choco install telegram
choco install whatsapp

# Development.
choco install jetbrainsmononf
choco install dotnet-sdk
choco install jdk8
choco install docker-desktop
choco install jetbrains-rider
choco install vscode
choco install unity-hub
choco install gitkraken
choco install sourcetree
choco install starship
choco install adobe-creative-cloud

# Gaming.
choco install steam-client
choco install steam-cleaner
choco install epicgameslauncher
choco install goggalaxy
choco install battle.net
choco install obs-studio
choco install chatterino
