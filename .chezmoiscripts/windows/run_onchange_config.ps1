# iac/dsc hash: {{ include "iac/dsc/root.ps1" "iac/dsc/test.txt" | sha256sum }}

echo "Applying Windows configuration..."

# 1. Check for admin rights, if not elevate
# 2. Apply DSC configuration
