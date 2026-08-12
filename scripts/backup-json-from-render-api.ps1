#Requires -Version 5.1
<#
.SYNOPSIS
  Export Mudabbir JSON-shaped data from production API (Render server copy).

  Render free tier has no Shell/SSH — this script captures live server data
  via authenticated API calls and writes JSON files matching store layout.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts/backup-json-from-render-api.ps1
    powershell -ExecutionPolicy Bypass -File scripts/backup-json-from-render-api.ps1 `
      -ApiBaseUrl "https://mudabbir-backend-api.onrender.com" `
      -Email "you@example.com" -Password "your-password"

  Env vars (optional): MUDABBIR_API_URL, MUDABBIR_BACKUP_EMAIL, MUDABBIR_BACKUP_PASSWORD
#>
param(
    [string] $ApiBaseUrl = $(if ($env:MUDABBIR_API_URL) { $env:MUDABBIR_API_URL } else { "https://mudabbir-backend-api.onrender.com" }),
    [string] $Email = $env:MUDABBIR_BACKUP_EMAIL,
    [string] $Password = $env:MUDABBIR_BACKUP_PASSWORD,
    [string] $OutRoot = $(Join-Path $env:USERPROFILE "mudabbir-json-backups")
)

$ErrorActionPreference = "Stop"
$dateStamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd-HHmmss") + "Z"
$exportDir = Join-Path $OutRoot "render-server-export-$dateStamp"
$storageDir = Join-Path $exportDir "storage-app"
New-Item -ItemType Directory -Force -Path $storageDir | Out-Null

function Write-JsonFile {
    param([string] $Path, $Object)
    $json = $Object | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($Path, $json, [System.Text.UTF8Encoding]::new($false))
}

Write-Host "Production API: $ApiBaseUrl"
Write-Host "Export dir: $exportDir"

# Health snapshot (no auth)
try {
    $health = Invoke-RestMethod -Uri "$ApiBaseUrl/api/health" -Method Get -TimeoutSec 120
    Write-JsonFile (Join-Path $exportDir "health-snapshot.json") $health
    Write-Host "Health: $($health.data.status)"
} catch {
    Write-Warning "Health check failed (cold start?): $_"
}

if (-not $Email -or -not $Password) {
    $registerEmail = "mudabbir-backup-$(Get-Date -Format 'yyyyMMdd')@backup.local"
    $Password = "Backup_" + [guid]::NewGuid().ToString("N").Substring(0, 16) + "!"
    Write-Host "No credentials — registering temporary backup user: $registerEmail"
    try {
        $reg = Invoke-RestMethod -Uri "$ApiBaseUrl/api/register" -Method Post -ContentType "application/json" `
            -Body (@{ name = "Backup Bot"; email = $registerEmail; password = $Password; password_confirmation = $Password } | ConvertTo-Json) `
            -TimeoutSec 120
        $Email = $registerEmail
        Write-Host "Registered backup user on server."
    } catch {
        Write-Error "Cannot register backup user. Set MUDABBIR_BACKUP_EMAIL / MUDABBIR_BACKUP_PASSWORD. $_"
    }
}

$login = Invoke-RestMethod -Uri "$ApiBaseUrl/api/login" -Method Post -ContentType "application/json" `
    -Body (@{ email = $Email; password = $Password } | ConvertTo-Json) -TimeoutSec 120
$token = $login.data.token.plainTextToken
if (-not $token) { $token = $login.token.plainTextToken }
if (-not $token) { throw "Login succeeded but no token in response." }

$headers = @{ Authorization = "Bearer $token" }

function Get-ApiData {
    param([string] $Path)
    $resp = Invoke-RestMethod -Uri "$ApiBaseUrl$Path" -Headers $headers -Method Get -TimeoutSec 120
    if ($null -ne $resp.data) { return $resp.data }
    return $resp
}

$expenses = @(Get-ApiData "/api/expenses?per_page=100")
$page = 1
while ($expenses.Count -ge 100) {
    $page++
    $next = @(Get-ApiData "/api/expenses?per_page=100&page=$page")
    if ($next.Count -eq 0) { break }
    $expenses += $next
}

$goals = @(Get-ApiData "/api/goals")
$budgets = @(Get-ApiData "/api/budgets")
$challenges = @(Get-ApiData "/api/challenges")

$maxExpenseId = 1
foreach ($e in $expenses) {
    $id = [int]$e.id
    if ($id -ge $maxExpenseId) { $maxExpenseId = $id + 1 }
}

Write-JsonFile (Join-Path $storageDir "expenses.json") @{
    next_expense_id = $maxExpenseId
    expenses        = @($expenses | ForEach-Object {
            @{
                id                  = [int]$_.id
                user_id             = [int]$_.user_id
                amount              = [double]$_.amount
                date                = [string]$_.date
                type                = [string]$_.type
                notes               = $_.notes
                account_id          = [int]$_.account_id
                category_id         = [int]$_.category_id
                account_name        = [string]$_.account_name
                category_name       = [string]$_.category_name
                is_recurring        = [bool]$_.is_recurring
                recurrence_interval = $_.recurrence_interval
                created_at          = $_.created_at
                updated_at          = $_.updated_at
            }
        })
}

$maxGoalId = 1
foreach ($g in $goals) {
    $id = [int]$g.id
    if ($id -ge $maxGoalId) { $maxGoalId = $id + 1 }
}
Write-JsonFile (Join-Path $storageDir "goals.json") @{
    next_goal_id           = $maxGoalId
    next_contribution_id   = 1
    next_milestone_id      = 1
    goals                  = @($goals)
}

$maxBudgetId = 1
foreach ($b in $budgets) {
    $id = [int]$b.id
    if ($id -ge $maxBudgetId) { $maxBudgetId = $id + 1 }
}
Write-JsonFile (Join-Path $storageDir "budgets.json") @{
    next_budget_id = $maxBudgetId
    budgets        = @($budgets)
}

$maxChallengeId = 1
foreach ($c in $challenges) {
    $id = [int]$c.id
    if ($id -ge $maxChallengeId) { $maxChallengeId = $id + 1 }
}
Write-JsonFile (Join-Path $storageDir "challenges.json") @{
    next_challenge_id = $maxChallengeId
    next_user_id      = 1000
    challenges        = @($challenges)
}

$manifest = @"
mudabbir-render-server-export
created_utc=$dateStamp
api_base_url=$ApiBaseUrl
backup_email=$Email
note=Render free tier has no Shell; this export uses authenticated API (single-user scope).
expenses=$($expenses.Count) goals=$($goals.Count) budgets=$($budgets.Count) challenges=$($challenges.Count)
"@
Set-Content -Path (Join-Path $exportDir "manifest.txt") -Value $manifest -Encoding UTF8

# Tar via Git Bash if available
$gitBash = "C:\Program Files\Git\bin\bash.exe"
$archivePath = Join-Path $OutRoot "mudabbir-json-render-$dateStamp.tar.gz"
if (Test-Path $gitBash) {
    $winExport = $exportDir -replace '\\', '/'
    $winArchive = $archivePath -replace '\\', '/'
    & $gitBash -lc "tar -czf '$winArchive' -C '$winExport' ."
    Write-Host "Server export archive: $archivePath"
} else {
    Write-Host "Git Bash not found — export folder only: $exportDir"
}

Write-Host "Render server backup done."
Write-Host "  Folder: $exportDir"
if (Test-Path $archivePath) { Write-Host "  Archive: $archivePath" }
