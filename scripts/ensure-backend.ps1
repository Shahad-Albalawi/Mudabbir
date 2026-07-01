#Requires -Version 5.1
<#
.SYNOPSIS
  Ensure Laravel API is running on http://127.0.0.1:8000 (idempotent).
#>
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Backend = Join-Path $Root "backend"
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
    & (Join-Path $Root "scripts\setup-backend.ps1")
}

if (Test-BackendUp) {
    Write-Host "Backend already running on http://127.0.0.1:8000"
    exit 0
}

Write-Host "Starting backend..."
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-ExecutionPolicy", "Bypass",
    "-File", (Join-Path $Root "scripts\start-backend.ps1")
) | Out-Null

$deadline = (Get-Date).AddSeconds(45)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 1
    if (Test-BackendUp) {
        Write-Host "Backend ready."
        exit 0
    }
}

Write-Error "Backend failed to start within 45s."
exit 1
