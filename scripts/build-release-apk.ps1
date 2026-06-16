# Builds a release APK with production API URL baked in.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/build-release-apk.ps1 -ApiBaseUrl "https://your-api.onrender.com"
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
    flutter build apk --release --dart-define-from-file=config/release.json
    $apk = Join-Path $frontend "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apk) {
        Write-Host ""
        Write-Host "APK ready:"
        Write-Host $apk
    }
} finally {
    Pop-Location
}
