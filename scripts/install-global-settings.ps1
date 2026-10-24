# Install Antigravity Qwiklabs rules and cache cleaner to your machine's global AGY config
$GlobalGemini = "$env:USERPROFILE\.gemini\config"
$GlobalRules  = "$GlobalGemini\rules"
$GlobalScripts = "$GlobalGemini\scripts"

Write-Host "==> Installing global Antigravity rules to $GlobalRules..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $GlobalRules | Out-Null
New-Item -ItemType Directory -Force -Path $GlobalScripts | Out-Null

# Copy auth rule
Copy-Item "$PSScriptRoot\..\.agents\rules\auth-rule.md" -Destination "$GlobalRules\qwiklabs-auth.md" -Force
Write-Host "    [OK] Installed rule: $GlobalRules\qwiklabs-auth.md" -ForegroundColor Green

# Copy cache clearing script
Copy-Item "$PSScriptRoot\clear-lab-cache.ps1" -Destination "$GlobalScripts\clear-lab-cache.ps1" -Force
Write-Host "    [OK] Installed script: $GlobalScripts\clear-lab-cache.ps1" -ForegroundColor Green

Write-Host "`nAll set! These rules will now apply globally to ALL your Antigravity sessions and projects." -ForegroundColor Green
