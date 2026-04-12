# Mudabbir — Laravel API

REST API for the Flutter app: **chatbot** (`POST /api/generate-content`, OpenAI) and **challenges** (`/api/challenges`, …).

## Requirements

- **PHP** 8.3+ and [Composer](https://getcomposer.org/)
- **Node.js** + npm (for Vite assets: `npm run build` / `npm run dev`)

If `php` or `composer` are missing or broken on Windows, use **WSL**, **Docker**, or install PHP via [windows.php.net](https://windows.php.net/download/) and fix your PATH.

## Quick start

```bash
cd apps/backend
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

Set **`OPENAI_API_KEY`** in `.env` for the chatbot. Optional **`GEMINI_*`** keys are documented in `.env.example` (Gemini is not wired to the default routes).

## Useful Composer scripts

| Command | Purpose |
|--------|---------|
| `composer run setup` | Install deps, `.env`, key, migrate, npm install, `npm run build` |
| `composer run dev` | Serve + queue + logs + Vite (see `composer.json`) |
| `composer run test` | Clear config cache and run PHPUnit |

Code style (when PHP works): `./vendor/bin/pint`

## Deploy

See **`../../docs/`** (e.g. Render) and repo root **`README.md`**.
