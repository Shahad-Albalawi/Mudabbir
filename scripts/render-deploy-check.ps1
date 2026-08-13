# Render deploy checklist — Mudabbir API + Neon
#
# Run after pushing to main (Render auto-deploys) or Manual Deploy.

Write-Host "=== Mudabbir Render Deploy Check ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1) Render Environment (Dashboard -> mudabbir-backend-api -> Environment):" -ForegroundColor Yellow
Write-Host "   DATABASE_URL = postgresql://USER:PASS@ep-xxx-pooler.../neondb?sslmode=require"
Write-Host "   DB_CONNECTION = pgsql"
Write-Host "   APP_KEY = base64:... (from scripts/generate-app-key.ps1)"
Write-Host "   Remove channel_binding=require from DATABASE_URL if present"
Write-Host ""

Write-Host "2) Deploy:" -ForegroundColor Yellow
Write-Host "   Manual Deploy -> Clear build cache & deploy"
Write-Host ""

Write-Host "3) Wait for Live (5-10 min first time, free tier may sleep)"
Write-Host ""

$url = "https://mudabbir-backend-api.onrender.com/api/health"
Write-Host "4) Checking: $url" -ForegroundColor Yellow
Write-Host ""

try {
    $r = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 90
    Write-Host "Status: $($r.StatusCode)" -ForegroundColor Green
    Write-Host $r.Content
    if ($r.Content -match '"driver":"pgsql"') {
        Write-Host ""
        Write-Host "SUCCESS - Neon PostgreSQL is connected." -ForegroundColor Green
    } elseif ($r.Content -match '"driver":"sqlite"') {
        Write-Host ""
        Write-Host "WARN - Still SQLite. DATABASE_URL missing or deploy failed." -ForegroundColor Red
    }
} catch {
    Write-Host "Request failed (cold start? wait 60s and retry): $_" -ForegroundColor Red
}
