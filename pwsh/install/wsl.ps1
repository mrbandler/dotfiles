Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi

Start-Process msiexec.exe -Wait -ArgumentList '/I wsl_update_x64.msi /quiet'
Remove-Item -Path .\wsl_update_x64.msi

wsl --set-default-version 2
wsl --install -d ubuntu
