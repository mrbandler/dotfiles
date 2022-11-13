# Add custom pwsh profile.
Add-Content $PROFILE.CurrentUserCurrentHost '. $HOME\.config\pwsh\profile.ps1'

# Install modules.
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -Force
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
