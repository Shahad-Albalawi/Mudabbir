#Requires -Version 5.1
<#
.SYNOPSIS
  Start Laravel API on http://127.0.0.1:8000
  Run from repo root: powershell -ExecutionPolicy Bypass -File scripts/start-backend.ps1
#>
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Backend = Join-Path $Root "backend"
$Php = Join-Path $Backend "tools\php\php.exe"

if (-not (Test-Path $Php)) {
    Write-Error "Portable PHP not found. Run scripts/setup-backend.ps1 first."
}

if (-not (Test-Path (Join-Path $Backend "vendor\autoload.php"))) {
    Write-Error "Vendor not found. Run scripts/setup-backend.ps1 first."
}

Set-Location $Backend
Write-Host "Starting Mudabbir API on http://0.0.0.0:8000 (emulator: http://10.0.2.2:8000)" -ForegroundColor Green
& $Php artisan serve --host=0.0.0.0 --port=8000
