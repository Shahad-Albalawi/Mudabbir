#Requires -Version 5.1
<#
.SYNOPSIS
  Full backend setup: portable PHP 8.0, composer install, .env, migrate, tests.
  Run from repo root: powershell -ExecutionPolicy Bypass -File scripts/setup-backend.ps1
#>
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Backend = Join-Path $Root "backend"
$Tools = Join-Path $Backend "tools"
$PhpDir = Join-Path $Tools "php"
$Php = Join-Path $PhpDir "php.exe"
$Composer = Join-Path $Root "composer.phar"

function Ensure-PortablePhp {
    New-Item -ItemType Directory -Force -Path $PhpDir | Out-Null
    if (Test-Path $Php) { return }

    Write-Host "Downloading PHP 8.0..."
    $Zip = Join-Path $Tools "php.zip"
    Invoke-WebRequest -Uri "https://windows.php.net/downloads/releases/archives/php-8.0.30-Win32-vs16-x64.zip" -OutFile $Zip -UseBasicParsing
    Expand-Archive -Path $Zip -DestinationPath $PhpDir -Force
    Remove-Item $Zip -Force

    Copy-Item (Join-Path $PhpDir "php.ini-development") (Join-Path $PhpDir "php.ini") -Force
    $IniPath = Join-Path $PhpDir "php.ini"
    $ExtDir = Join-Path $PhpDir "ext"
    $Ini = Get-Content $IniPath -Raw
    $Ini = $Ini -replace ';extension=openssl','extension=openssl'
    $Ini = $Ini -replace ';extension=curl','extension=curl'
    $Ini = $Ini -replace ';extension=mbstring','extension=mbstring'
    $Ini = $Ini -replace ';extension=fileinfo','extension=fileinfo'
    $Ini = $Ini -replace ';extension=pdo_sqlite','extension=pdo_sqlite'
    $Ini = $Ini -replace ';extension=sqlite3','extension=sqlite3'
    if ($Ini -notmatch '(?m)^\s*extension_dir\s*=') {
        $Ini += "`nextension_dir=`"$ExtDir`"`n"
    } else {
        $Ini = $Ini -replace '(?m)^;?\s*extension_dir\s*=.*', "extension_dir=`"$ExtDir`""
    }
    Set-Content -Path $IniPath -Value $Ini -Encoding ASCII
}

function Ensure-CaBundle {
    $CaFile = Join-Path $PhpDir "cacert.pem"
    $IniPath = Join-Path $PhpDir "php.ini"
    if (-not (Test-Path $CaFile)) {
        Write-Host "Downloading CA bundle for SSL..."
        Invoke-WebRequest -Uri "https://curl.se/ca/cacert.pem" -OutFile $CaFile -UseBasicParsing
    }
    $CaPath = $CaFile -replace '\\', '/'
    $Ini = Get-Content $IniPath -Raw
    if ($Ini -match '(?m)^;?\s*curl\.cainfo\s*=') {
        $Ini = $Ini -replace '(?m)^;?\s*curl\.cainfo\s*=.*', "curl.cainfo=`"$CaPath`""
    } else {
        $Ini += "`ncurl.cainfo=`"$CaPath`"`n"
    }
    if ($Ini -match '(?m)^;?\s*openssl\.cafile\s*=') {
        $Ini = $Ini -replace '(?m)^;?\s*openssl\.cafile\s*=.*', "openssl.cafile=`"$CaPath`""
    } else {
        $Ini += "openssl.cafile=`"$CaPath`"`n"
    }
    Set-Content -Path $IniPath -Value $Ini -Encoding ASCII
}

function Ensure-Composer {
    if (Test-Path $Composer) { return }
    Write-Host "Downloading Composer..."
    Invoke-WebRequest -Uri "https://getcomposer.org/download/latest-2.x/composer.phar" -OutFile $Composer -UseBasicParsing
}

Ensure-PortablePhp
Ensure-CaBundle
Ensure-Composer

& $Php -v
Write-Host "PHP ready at $Php" -ForegroundColor Cyan

Set-Location $Backend

if (-not (Test-Path "vendor\autoload.php")) {
    Write-Host "Running composer install..."
    & $Php $Composer config policy.advisories.block false
    & $Php $Composer install --no-interaction --prefer-dist --optimize-autoloader
}

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created .env from .env.example"
}

# Relative DB_DATABASE breaks artisan serve on Windows — use Laravel default path.
$envPath = Join-Path $Backend ".env"
$envText = Get-Content $envPath -Raw
if ($envText -match '(?m)^DB_DATABASE=database/database\.sqlite\s*$') {
    $envText = $envText -replace '(?m)^DB_DATABASE=database/database\.sqlite\s*$', '# DB_DATABASE='
    Set-Content -Path $envPath -Value $envText -Encoding UTF8
    Write-Host "Fixed DB_DATABASE in .env (use database_path default)"
}

& $Php artisan key:generate --force

$Db = Join-Path $Backend "database\database.sqlite"
if (-not (Test-Path $Db)) {
    New-Item -ItemType File -Path $Db -Force | Out-Null
    Write-Host "Created database/database.sqlite"
}

& $Php artisan migrate --force
& $Php artisan config:clear
& $Php artisan test

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Start API: powershell -ExecutionPolicy Bypass -File scripts/start-backend.ps1" -ForegroundColor Green
Write-Host "API URL:   http://127.0.0.1:8000" -ForegroundColor Green
