# Builds a release Android App Bundle (AAB) for Google Play.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/build-release-aab.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/build-release-aab.ps1 -ApiBaseUrl "https://your-api.onrender.com"
param(
    [string]$ApiBaseUrl = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$frontend = Join-Path $repoRoot "frontend"
$configPath = Join-Path $frontend "config\release.json"

if ($ApiBaseUrl -ne "") {
    $normalized = $ApiBaseUrl.TrimEnd("/")
    @{ API_BASE_URL = $normalized } | ConvertTo-Json | Set-Content -Path $configPath -Encoding utf8
    Write-Host "Updated $configPath with API_BASE_URL=$normalized"
} elseif (-not (Test-Path $configPath)) {
    throw "Missing $configPath. Pass -ApiBaseUrl or create the file."
}

Push-Location $frontend
try {
    flutter pub get
    flutter build appbundle --release --dart-define-from-file=config/release.json
    $aab = Join-Path $frontend "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aab) {
        Write-Host ""
        Write-Host "AAB ready (upload to Play Console):"
        Write-Host $aab
    }
} finally {
    Pop-Location
}
