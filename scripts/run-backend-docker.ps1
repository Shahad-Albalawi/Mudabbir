#Requires -Version 5.1
<#
.SYNOPSIS
  Build and run the Laravel API in Docker (no local PHP required).
  Run from repo root:  powershell -ExecutionPolicy Bypass -File scripts/run-backend-docker.ps1
#>
$ErrorActionPreference = "Stop"
$Backend = (Resolve-Path (Join-Path $PSScriptRoot "..\backend")).Path

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "Docker is not installed or not in PATH. Install Docker Desktop, then retry."
}

Set-Location $Backend
docker compose build
docker compose run --rm api composer install
if (-not (Test-Path (Join-Path $Backend ".env"))) {
  Copy-Item (Join-Path $Backend ".env.example") (Join-Path $Backend ".env")
}
docker compose run --rm api php artisan key:generate --force
$db = Join-Path $Backend "database" "database.sqlite"
if (-not (Test-Path $db)) {
  New-Item -ItemType File -Path $db -Force | Out-Null
}
docker compose run --rm api php artisan migrate --force
Write-Host "Starting API on http://127.0.0.1:8000 — Ctrl+C to stop." -ForegroundColor Green
docker compose up
