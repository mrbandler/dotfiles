Write-Output "Windows environment bootstrapped."

$restartResponse = Read-Host "Restart required. Do you want to restart the computer now? (Y/N)"
if ($restartResponse -match '^(y|Y)') {
    Write-Output "Restarting the computer..."
    Restart-Computer
}
else {
    Write-Output "Restart skipped. Please restart the computer manually to complete the setup."
}
