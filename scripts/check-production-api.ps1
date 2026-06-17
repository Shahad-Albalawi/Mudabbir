# Probes Mudabbir production API reachability (health + optional register smoke test).
param(
    [string]$ApiBaseUrl = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot "frontend\config\release.json"

if ($ApiBaseUrl -eq "" -and (Test-Path $configPath)) {
    $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($cfg.API_BASE_URL) {
        $ApiBaseUrl = [string]$cfg.API_BASE_URL
    }
}

if ($ApiBaseUrl -eq "") {
    throw "Pass -ApiBaseUrl or set API_BASE_URL in frontend/config/release.json"
}

$base = $ApiBaseUrl.TrimEnd("/")
$healthUrl = "$base/api/health"

Write-Host "Checking: $healthUrl"
Write-Host ""

try {
    $health = Invoke-WebRequest -Uri $healthUrl -Method GET -UseBasicParsing -TimeoutSec 30
    Write-Host "GET /api/health -> $($health.StatusCode)"
    Write-Host $health.Content
} catch {
    $resp = $_.Exception.Response
    if ($resp) {
        $code = [int]$resp.StatusCode
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $body = $reader.ReadToEnd()
        Write-Host "GET /api/health -> $code"
        Write-Host $body
        if ($code -eq 530 -or $body -match "1016") {
            Write-Host ""
            Write-Host "DIAGNOSIS: Cloudflare 530 / error 1016 = origin DNS/routing failure."
            Write-Host "The hostname resolves to Cloudflare but Laravel Cloud origin is unreachable."
            Write-Host "See docs/PRODUCTION_API.md for remediation (redeploy Laravel Cloud or use Render)."
            exit 1
        }
        exit 1
    }
    Write-Host "Request failed: $_"
    exit 1
}

if ($health.StatusCode -ne 200) {
    exit 1
}

Write-Host ""
Write-Host "OK - production API is reachable."
