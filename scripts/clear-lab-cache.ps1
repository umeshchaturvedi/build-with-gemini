# Clear stale Qwiklabs credentials and cache for a clean session
Write-Host "==> Revoking stale gcloud credentials..." -ForegroundColor Cyan
gcloud auth revoke --all --quiet 2>$null
gcloud auth application-default revoke --quiet 2>$null

Write-Host "==> Unsetting gcloud core configurations..." -ForegroundColor Cyan
gcloud config unset core/account --quiet 2>$null
gcloud config unset core/project --quiet 2>$null
gcloud config unset billing/quota_project --quiet 2>$null

Write-Host "==> Cleaning cached token databases..." -ForegroundColor Cyan
$gcloudPaths = @(
    "$env:APPDATA\gcloud\credentials.db",
    "$env:APPDATA\gcloud\access_tokens.db",
    "$env:APPDATA\gcloud\application_default_credentials.json",
    "$env:USERPROFILE\.config\gcloud\credentials.db",
    "$env:USERPROFILE\.config\gcloud\access_tokens.db",
    "$env:USERPROFILE\.config\gcloud\application_default_credentials.json"
)

foreach ($path in $gcloudPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "    Deleted: $path" -ForegroundColor Gray
    }
}

Write-Host "==> Clean slate ready. Please provide the new student username and project ID." -ForegroundColor Green
