# Creates frontend/android/key.properties for release signing.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/setup-release-signing.ps1 `
#     -StorePassword "..." -KeyPassword "..." 

param(
    [string]$StorePassword = "",
    [string]$KeyPassword = "",
    [string]$KeyAlias = "upload"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $repoRoot "frontend\android"
$keyPropsPath = Join-Path $androidDir "key.properties"
$keystorePath = Join-Path $androidDir "upload-keystore.jks"
$examplePath = Join-Path $androidDir "key.properties.example"

if (-not (Test-Path $keystorePath)) {
    Write-Host "No keystore at $keystorePath"
    Write-Host "Run: scripts/generate-android-keystore.ps1"
    exit 1
}

if ($StorePassword -eq "") {
    $secureStore = Read-Host "Store password" -AsSecureString
    $StorePassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureStore)
    )
}

if ($KeyPassword -eq "") {
    $secureKey = Read-Host "Key password (Enter = same as store)" -AsSecureString
    if ($secureKey.Length -gt 0) {
        $KeyPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        )
    } else {
        $KeyPassword = $StorePassword
    }
}

$content = @"
storePassword=$StorePassword
keyPassword=$KeyPassword
keyAlias=$KeyAlias
storeFile=upload-keystore.jks
"@

Set-Content -Path $keyPropsPath -Value $content -Encoding utf8
Write-Host "Created $keyPropsPath (gitignored)."
Write-Host ""
Write-Host "Build release AAB:"
Write-Host "  powershell -ExecutionPolicy Bypass -File scripts/build-release-aab.ps1"
Write-Host ""
Write-Host "See docs/PLAY_STORE.md for Play Console steps."
