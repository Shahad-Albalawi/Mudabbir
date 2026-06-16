# Mudabbir — Laravel 9 API

REST API for the Flutter app: **AI coach bot** (`POST /api/generate-content`, OpenAI or Gemini via `.env`) and **challenges** (`/api/challenges`, invite/respond endpoints, …).

## Requirements

- **PHP** 8.0+ and [Composer](https://getcomposer.org/)

## Quick start (Windows — no PHP install needed)

From **repo root**:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup-backend.ps1
powershell -ExecutionPolicy Bypass -File scripts/start-backend.ps1
```

This downloads portable PHP 8.0, runs `composer install`, creates `.env`, migrates SQLite, and runs tests.

API: **http://127.0.0.1:8000**

## Quick start (PHP already on PATH)

```bash
cd backend
composer install
cp .env.example .env          # Windows: copy .env.example .env
php artisan key:generate
```

**SQLite (default):** create an empty DB file, then migrate:

```bash
# PowerShell
New-Item -ItemType File -Path database/database.sqlite -Force

php artisan migrate
php artisan serve
```

## AI coach configuration

Set provider and API key in `.env`:

```env
AI_PROVIDER=openai   # or gemini
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...
```

## Useful Composer scripts

| Command | Purpose |
|--------|---------|
| `composer run setup` | Install deps, `.env`, key, migrate |
| `composer run test` | Clear config cache and run PHPUnit |

## Docker (optional)

From `backend/` with Docker Desktop:

```bash
docker compose build
docker compose run --rm api composer install
docker compose run --rm api php artisan key:generate --force
docker compose run --rm api php artisan migrate --force
docker compose up
```

See repo root **`../README.md`** and **`../docs/`** for Flutter integration and deployment.
