# This script is meant to be run once to bootstrap the Windows environment.

echo "Bootstrapping Windows environment..."

# 1. Check for admin rights, if not elevate
# 2. Install WinRM (this is needed to apply DSC configurations) -> winrm quickconfig
# 3. Install package managers (scoop, choco, winget)
# 4. Apply DSC configuration
