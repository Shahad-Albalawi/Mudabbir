# Mudabbir — Laravel API

REST API for the Flutter app: **chatbot** (`POST /api/generate-content`, OpenAI) and **challenges** (`/api/challenges`, …).

## Requirements

- **PHP** 8.3+ and [Composer](https://getcomposer.org/)
- **Node.js** + npm (for Vite assets: `npm run build` / `npm run dev`)

If `php` or `composer` are missing or broken on Windows, pick one path below.

### Option 0 — Dev Container (Cursor / VS Code)

With **Docker Desktop** installed: open the **repository root** in Cursor/VS Code → Command Palette → **Dev Containers: Reopen in Container**. After the image builds, in a terminal:

```bash
cd backend
php artisan serve
```

`composer install` runs once in **postCreate**. Copy `.env` / add **`OPENAI_API_KEY`**, then `php artisan key:generate` and `touch database/database.sqlite && php artisan migrate` if you have not already.

**One command on Windows (no PHP on PATH):** from repo root run `scripts/run-backend-docker.ps1` in PowerShell.

### Option A — Docker (no local PHP)

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows, then from **`backend/`**:

```bash
docker compose build
docker compose run --rm api composer install
docker compose run --rm api sh -c "test -f .env || cp .env.example .env"
docker compose run --rm api php artisan key:generate --force
docker compose run --rm api sh -c "test -f database/database.sqlite || touch database/database.sqlite"
docker compose run --rm api php artisan migrate --force
docker compose up
```

API on **http://127.0.0.1:8000** (Flutter emulator: use `USE_LOCAL_API` / host `10.0.2.2` as in `frontend/README.md`). Put **`OPENAI_API_KEY`** in `.env` on the host (same folder; bind-mounted).

### Option B — WSL (Ubuntu)

```bash
sudo apt update && sudo apt install -y php8.3 php8.3-sqlite3 php8.3-xml php8.3-mbstring php8.3-curl unzip
# Composer: https://getcomposer.org/download/
cd /path/to/repo/backend && composer install
```

### Option C — Fix Windows / Scoop PHP

Errors like **“Cannot open shim file for read”** usually mean a broken Scoop shim or removed app folder.

1. `scoop uninstall php` then `scoop install php` (or reinstall **Composer** the same way).  
2. Or install the **VS16 x64 Non Thread Safe** ZIP from [windows.php.net](https://windows.php.net/download/), unzip to e.g. `C:\php`, add `C:\php` to **PATH**, and download **`composer.phar`** from getcomposer.org.

---

## Quick start (PHP on PATH)

```bash
cd backend
composer install
cp .env.example .env          # Windows CMD: copy .env.example .env
php artisan key:generate
```

**SQLite (default):** create an empty DB file, then migrate:

```bash
# macOS / Linux / Git Bash
touch database/database.sqlite

# PowerShell
New-Item -ItemType File -Path database/database.sqlite -Force
```

```bash
php artisan migrate
php artisan serve
```

Set **`OPENAI_API_KEY`** in `.env` for the chatbot.

## Useful Composer scripts

| Command | Purpose |
|--------|---------|
| `composer run setup` | Install deps, `.env`, key, migrate, npm install, `npm run build` |
| `composer run dev` | Serve + queue + logs + Vite (see `composer.json`) |
| `composer run test` | Clear config cache and run PHPUnit |

Code style (when PHP works): `./vendor/bin/pint`

## Deploy

See **`../docs/`** (e.g. Render) and repo root **`../README.md`**.
