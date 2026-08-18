# Generate an Android upload keystore for Play Store signing.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/generate-android-keystore.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $repoRoot "frontend\android"
$keystorePath = Join-Path $androidDir "upload-keystore.jks"
$keyPropsPath = Join-Path $androidDir "key.properties"

if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists: $keystorePath"
    exit 0
}

Write-Host "Creating upload keystore for Mudabbir..."
Write-Host "You will be prompted for passwords and certificate details."
Write-Host ""

$keytool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $keytool) {
    throw "keytool not found. Install JDK 17+ and ensure keytool is on PATH."
}

& keytool -genkey -v `
    -keystore $keystorePath `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias upload

Write-Host ""
Write-Host "Keystore created: $keystorePath"
Write-Host ""
Write-Host "Next: run scripts/setup-release-signing.ps1 to create key.properties"
