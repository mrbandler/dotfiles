# Install and setup WSL
wsl --update
wsl --install --no-distribution
wsl --install Ubuntu --no-launch
ubuntu install --root

$user = $env:USERNAME.ToLower()
wsl -d Ubuntu -u root adduser --gecos GECOS --disabled-password $user
wsl -d Ubuntu -u root usermod -aG sudo $user
& ubuntu config --default-user $user
wsl --set-default Ubuntu

# TODO: Run WSL bootstrapping here.

# Unregister this scheduled task
Unregister-ScheduledTask -TaskName "AfterBootstrap" -Confirm:$false

# Finalize boostrapping
Read-Host "Finalized boostrapping, press enter to close"
