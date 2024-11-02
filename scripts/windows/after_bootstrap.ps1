Read-Host "Yay, the after bootstrap script just ran. Close? [ENTER]"
Unregister-ScheduledTask -TaskName "AfterBootstrap" -Confirm:$false
