#Requires -Version 5.1
<#
.SYNOPSIS
  Create all 3 pre-migration JSON backups (local, Render API, GitHub orphan branch).

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts/backup-all-three.ps1
#>
param(
    [switch] $SkipPush
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot

$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $gitBash)) {
    throw "Git Bash required at $gitBash"
}

Write-Host "=== 1/3 Local JSON backup (storage/app) ===" -ForegroundColor Cyan
& $gitBash -lc "cd '$($repoRoot -replace '\\','/')' && ./scripts/backup-json.sh"
$localBackupDir = Join-Path $env:USERPROFILE "mudabbir-json-backups"
$latestLocal = Get-ChildItem $localBackupDir -Filter "mudabbir-json-*.tar.gz" |
    Where-Object { $_.Name -notmatch 'render' } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

$docsBackup = Join-Path $env:USERPROFILE "Documents\Mudabbir-JSON-Backup"
New-Item -ItemType Directory -Force -Path $docsBackup | Out-Null
Copy-Item "$($latestLocal.FullName)*" -Destination $docsBackup -Force
Write-Host "Local copies:"
Write-Host "  $($latestLocal.FullName)"
Write-Host "  $docsBackup\$($latestLocal.Name)"

Write-Host "`n=== 2/3 Render server export (production API) ===" -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "backup-json-from-render-api.ps1")
$latestRender = Get-ChildItem $localBackupDir -Filter "mudabbir-json-render-*.tar.gz" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
Copy-Item "$($latestRender.FullName)*" -Destination $docsBackup -Force

Write-Host "`n=== 3/3 GitHub off-site (orphan branch + workflow) ===" -ForegroundColor Cyan
if (-not $SkipPush) {
    git add scripts/backup-json.sh scripts/backup-json-from-render-api.ps1 scripts/backup-all-three.ps1 `
        .github/workflows/backup-json-stores.yml docs/MIGRATION_SAFETY.md
    $status = git status --porcelain
    if ($status) {
        git commit -m @"
chore(migration): add JSON backup tooling and safety workflow

Three-copy backup: local tar.gz, Render API export, GitHub orphan branch.
"@
    }
    git push origin production-polish

    $branchName = "backup/json-$(Get-Date -Format 'yyyy-MM-dd')"
    $staging = Join-Path $env:TEMP "mudabbir-backup-branch"
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $staging | Out-Null

    Copy-Item $latestLocal.FullName -Destination $staging
    Copy-Item "$($latestLocal.FullName).sha256" -Destination $staging
    Copy-Item $latestRender.FullName -Destination $staging
    if (Test-Path "$($latestRender.FullName).sha256") {
        Copy-Item "$($latestRender.FullName).sha256" -Destination $staging
    }
    @"
Mudabbir JSON backups — pre-migration baseline
Created: $(Get-Date -Format o)

Files:
- $($latestLocal.Name) — local storage/app snapshot
- $($latestRender.Name) — Render production API export

Do not merge into main. Download archives and verify SHA256 before migration.
"@ | Set-Content (Join-Path $staging "README.txt") -Encoding UTF8

    git checkout --orphan $branchName
    git rm -rf --quiet . 2>$null
    Copy-Item (Join-Path $staging "*") -Destination $repoRoot -Force
    git add --all
    git commit -m "backup: JSON stores pre-migration $(Get-Date -Format 'yyyy-MM-dd')"
    git push -u origin $branchName
    git checkout production-polish
    Write-Host "Pushed orphan branch: $branchName"
}

Write-Host "`n=== DONE ===" -ForegroundColor Green
Write-Host "Copy A (server): $($latestRender.FullName)"
Write-Host "Copy B (local):  $($latestLocal.FullName) + Documents\Mudabbir-JSON-Backup"
Write-Host "Copy C (GitHub): branch backup/json-$(Get-Date -Format 'yyyy-MM-dd')"
