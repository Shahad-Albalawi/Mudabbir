# Migrate Mudabbir from Render SQLite to Neon PostgreSQL.
param(
    [Parameter(Mandatory = $true)]
    [string]$DatabaseUrl,

    [Parameter(Mandatory = $true)]
    [string]$SqliteSource
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Backend = Join-Path $Root "backend"

if ($DatabaseUrl -notmatch "pooler") {
    Write-Warning "DATABASE_URL should use Neon POOLED host (-pooler) for Laravel."
}

if (-not (Test-Path $SqliteSource)) {
    throw "SQLite file not found: $SqliteSource"
}

$env:DATABASE_URL = $DatabaseUrl
$env:DB_CONNECTION = "pgsql"
$env:DB_SSLMODE = "require"
$env:HEALTH_DB_TIMEOUT_SECONDS = "5"

function Get-NeonDirectDatabaseUrl([string]$Url) {
    if ($Url -match "-pooler") {
        Write-Host "Neon: migrate uses direct connection (pooler stripped from host)." -ForegroundColor Yellow
        return ($Url -replace "-pooler", "")
    }
    return $Url
}

Push-Location $Backend
try {
    Write-Host "=== 1/4 migrate schema on Neon ===" -ForegroundColor Cyan
    $migrateUrl = Get-NeonDirectDatabaseUrl $DatabaseUrl
    $env:DATABASE_URL = $migrateUrl
    php artisan migrate --force
    $env:DATABASE_URL = $DatabaseUrl

    Write-Host "=== 2/4 copy SQLite to PostgreSQL ===" -ForegroundColor Cyan
    php artisan mudabbir:migrate-sqlite-to-pgsql --sqlite="$SqliteSource"

    Write-Host "=== 3/4 legacy JSON import (optional) ===" -ForegroundColor Cyan
    try { php artisan mudabbir:import-legacy-json } catch { Write-Warning $_ }

    Write-Host "=== 4/4 done ===" -ForegroundColor Green
    Write-Host "Set Render DATABASE_URL + redeploy, then run check-production-api.ps1"
} finally {
    Pop-Location
}
