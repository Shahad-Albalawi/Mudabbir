# Backend closure checklist

Use this after deploying to Render (PostgreSQL / Neon).

## 1. Smoke test (production)

```bash
curl -s https://mudabbir-backend-api.onrender.com/api/health
```

Then from the app or API client:

1. Register / login
2. `POST /api/expenses`
3. `GET /api/statistics`
4. `POST /api/budgets`
5. `POST /api/goals/from-template` or `POST /api/goals`

All should return `success: true` (201 for creates).

## 2. Verify legacy JSON import (one-time)

On Render shell or locally with production `DATABASE_URL`:

```bash
php artisan mudabbir:verify-legacy-migration --all
```

Expect: `Legacy migration verification passed.`  
If JSON files are missing on the server, the command skips them (normal after dual-write is off).

## 3. GitHub scheduler secrets (budget push alerts)

Full guide: **[docs/SCHEDULER_SECRETS.md](./SCHEDULER_SECRETS.md)**

Repo → **Settings → Secrets and variables → Actions** → add:

| Secret | Value |
|--------|--------|
| `MUDABBIR_DATABASE_URL` | Neon **pooled** `DATABASE_URL` (same as Render) |
| `MUDABBIR_APP_KEY` | Same `APP_KEY` as Render |
| `MUDABBIR_FCM_SERVER_KEY` | Optional — FCM key for push notifications |

Workflow: `.github/workflows/laravel-scheduler.yml` (daily 08:00 UTC).

Manual run: **Actions → Laravel Scheduler → Run workflow**.

## 4. Environment (Render)

| Variable | Production value |
|----------|------------------|
| `MUDABBIR_DUAL_WRITE_JSON` | removed — PostgreSQL is sole store |
| `DB_EMULATE_PREPARES` | `true` (default — Neon pooler) |
| `APP_DEBUG` | `false` |

## 5. Done when

- [ ] Health OK, creates work (expense/goal/budget)
- [ ] CI `Backend Tests` green
- [ ] Legacy verify passed or skipped (no JSON on server)
- [ ] Scheduler secrets set (optional but recommended)
- [ ] Dual-write disabled
