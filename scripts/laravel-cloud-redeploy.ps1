# Trigger Laravel Cloud redeploy via deploy hook.
param(
    [string]$DeployHookUrl = $env:LARAVEL_CLOUD_DEPLOY_HOOK,
    [string]$CommitHash = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DeployHookUrl)) {
    Write-Host @"
Missing deploy hook URL.

Get it from Laravel Cloud:
  Environment → Settings → Deployments → Deploy hook → Enable

Then either:
  `$env:LARAVEL_CLOUD_DEPLOY_HOOK = 'https://...'
  powershell -File scripts/laravel-cloud-redeploy.ps1

Or add GitHub secret LARAVEL_CLOUD_DEPLOY_HOOK and run workflow
  "Laravel Cloud redeploy" from Actions tab.
"@
    exit 1
}

$url = $DeployHookUrl.Trim()
if ($CommitHash -ne "") {
    $sep = if ($url.Contains("?")) { "&" } else { "?" }
    $url = "$url$sep" + "commit_hash=$CommitHash"
}

Write-Host "Triggering Laravel Cloud deploy..."
Invoke-WebRequest -Uri $url -Method POST -UseBasicParsing | Out-Null
Write-Host "Deploy hook accepted. Wait 2–5 minutes, then run:"
Write-Host "  scripts/check-production-api.ps1"
