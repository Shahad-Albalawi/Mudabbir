#Requires -Version 5.1
<#
.SYNOPSIS
  Start local Laravel API + Flutter app (debug uses http://127.0.0.1:8000 / 10.0.2.2:8000).
  Run from repo root: powershell -ExecutionPolicy Bypass -File scripts/run-dev.ps1
#>
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Backend = Join-Path $Root "backend"
$Frontend = Join-Path $Root "frontend"
$Php = Join-Path $Backend "tools\php\php.exe"

function Test-BackendUp {
    try {
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/health" -TimeoutSec 3
        return $r.status -eq "ok"
    } catch {
        return $false
    }
}

if (-not (Test-Path $Php)) {
    Write-Host "Backend not set up. Running setup-backend.ps1 ..." -ForegroundColor Yellow
    & (Join-Path $Root "scripts\setup-backend.ps1")
}

if (-not (Test-BackendUp)) {
    Write-Host "Starting backend on http://127.0.0.1:8000 ..." -ForegroundColor Cyan
    Start-Process powershell -ArgumentList @(
        "-NoExit",
        "-ExecutionPolicy", "Bypass",
        "-File", (Join-Path $Root "scripts\start-backend.ps1")
    ) | Out-Null

    $deadline = (Get-Date).AddSeconds(45)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 1
        if (Test-BackendUp) { break }
    }
    if (-not (Test-BackendUp)) {
        Write-Error "Backend did not start. Check the backend window for errors."
    }
    Write-Host "Backend is up." -ForegroundColor Green
} else {
    Write-Host "Backend already running." -ForegroundColor Green
}

Write-Host ""
Write-Host "IMPORTANT: Sign in or register in the app to use challenges, AI chat, and sync." -ForegroundColor Yellow
Write-Host "Guest mode only uses local demo data without the API." -ForegroundColor Yellow
Write-Host ""

Set-Location $Frontend
$device = if ($args.Count -gt 0) { $args[0] } else { "emulator-5554" }

Write-Host "Launching Flutter on $device (local API: http://10.0.2.2:8000 on emulator)..." -ForegroundColor Cyan
Write-Host "After code changes press R in this terminal for hot RESTART." -ForegroundColor Yellow
Write-Host ""

flutter run -d $device --dart-define=USE_LOCAL_API=true
