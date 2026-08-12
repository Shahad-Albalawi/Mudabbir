#Requires -Version 5.1
<#
.SYNOPSIS
  Push JSON backups to GitHub as an orphan branch (off-site copy #3).

  Creates a temporary repo with ONLY backup archives — no project source code.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts/push-backup-branch.ps1
#>
param(
    [string] $BranchName = "backup/json-$(Get-Date -Format 'yyyy-MM-dd')",
    [string] $BackupDir = $(Join-Path $env:USERPROFILE "mudabbir-json-backups"),
    [string] $RemoteUrl = "https://github.com/Shahad-Albalawi/Mudabbir.git"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path $PSScriptRoot -Parent
$tempRoot = Join-Path $env:TEMP "mudabbir-backup-git-$([guid]::NewGuid().ToString('N').Substring(0,8))"

New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
    $localArchive = Get-ChildItem $BackupDir -Filter "mudabbir-json-*.tar.gz" |
        Where-Object { $_.Name -notmatch 'render' } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $localArchive) {
        throw "No local backup archive found in $BackupDir. Run scripts/backup-json.sh first."
    }

    Copy-Item $localArchive.FullName -Destination $tempRoot
    Copy-Item "$($localArchive.FullName).sha256" -Destination $tempRoot -ErrorAction SilentlyContinue

    $health = Join-Path $BackupDir "render-health-2026-08-12.json"
    if (Test-Path $health) {
        Copy-Item $health -Destination (Join-Path $tempRoot "render-health-snapshot.json")
    }

    @"
Mudabbir JSON backups — pre-migration baseline
Created: $(Get-Date -Format o)
Branch: $BranchName

Files in this branch ONLY:
- $($localArchive.Name) — local storage/app snapshot (tar.gz)
- render-health-snapshot.json — Render production /api/health (if present)

Do NOT merge into main. Download and verify SHA256 before migration.
"@ | Set-Content (Join-Path $tempRoot "README.txt") -Encoding UTF8

    Push-Location $tempRoot
    git init | Out-Null
    git config user.email "mudabbir-backup@users.noreply.github.com"
    git config user.name "Mudabbir Backup Bot"
    git checkout -b $BranchName | Out-Null
    git add --all
    git commit -m "backup: JSON stores pre-migration $(Get-Date -Format 'yyyy-MM-dd')" | Out-Null
    git remote add origin $RemoteUrl
    git push -u origin $BranchName --force
    if ($LASTEXITCODE -ne 0) { throw "git push failed with exit code $LASTEXITCODE" }
    Write-Host "Pushed orphan backup branch: $BranchName"
    Write-Host "GitHub: $RemoteUrl/tree/$($BranchName -replace '/','%2F')"
}
finally {
    Pop-Location
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
