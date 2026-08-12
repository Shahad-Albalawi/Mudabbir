# Backend migration checklist — production 100%

## Code (done after push)

- [x] Expenses / goals / budgets / challenges → Eloquent
- [x] Dual-write JSON safety window (controllers)
- [x] Legacy JSON import on deploy
- [x] Neon config + `migrate-to-neon` scripts
- [x] Daily `pg_dump` GitHub Action
- [x] Telescope (local) + Sentry (production) + CI tests

## Render Dashboard (manual — required for full production DB)

1. **Neon** — create project + production branch
2. Copy **pooled** `DATABASE_URL` → Render Environment
3. Set `DB_CONNECTION=pgsql`
4. Export Render `database.sqlite` (or use backup) → run `scripts/migrate-to-neon.ps1`
5. Redeploy — `render-start.sh` auto-selects Postgres when `DATABASE_URL` is set

## Sentry

1. Create free project at https://sentry.io
2. Render → `SENTRY_LARAVEL_DSN` = your DSN

## GitHub

1. Secret `NEON_DATABASE_URL_DIRECT` (direct URI, not pooler) for daily backups

## After 1–2 stable days

- `MUDABBIR_DUAL_WRITE_JSON=false` on Render

## Verify

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1
```

Expect `"driver":"pgsql"` after Neon is configured (until then `"sqlite"` is OK).
