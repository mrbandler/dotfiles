# 1. Install and setup WSL
wsl --install --no-distribution
wsl --set-default-version 2
wsl --install Ubuntu --no-launch
ubuntu install --root
wsl --set-default Ubuntu

# 2. Create default user and set it for WSL
$user = $env:USERNAME.ToLower()
wsl -d ubuntu -u root adduser --gecos GECOS --disabled-password $user
wsl -d ubuntu -u root usermod -aG sudo $user
& ubuntu config --default-user $user

# 3. Unregister this scheduled task
Unregister-ScheduledTask -TaskName "AfterBootstrap" -Confirm:$false

# 4. Finalize boostrapping
Read-Host "Finalized boostrapping. Press Enter to continue."
