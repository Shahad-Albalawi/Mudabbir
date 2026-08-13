# Backend migration checklist — production 100%

## Code (done)

- [x] Expenses / goals / budgets / challenges → Eloquent
- [x] Dual-write JSON safety window (controllers)
- [x] Legacy JSON import on deploy
- [x] Neon config + `migrate-to-neon` scripts
- [x] Daily `pg_dump` GitHub Action (`.github/workflows/neon-db-backup.yml`)
- [x] `mudabbir:verify-legacy-migration` (count + 10% sample + orphan check)
- [x] `scripts/backup-json.sh` (JSON off-site backup)
- [x] Telescope (local) + Sentry package + CI tests
- [x] `/notifications/test-push` disabled outside `local`
- [x] Laravel Policies (Expense, Goal, Budget, Challenge)
- [x] Eloquent Repositories (replaced `*Store` write layer)
- [x] SQLite → Neon script + `mudabbir:migrate-sqlite-to-pgsql`

## Render (done)

- [x] Neon production branch + pooled `DATABASE_URL`
- [x] `DB_CONNECTION=pgsql`
- [x] Deploy Live — expect `"driver":"pgsql"` on `/api/health`

## Manual — optional but recommended

### Sentry (free)

1. Create project at https://sentry.io
2. Render → Environment → `SENTRY_LARAVEL_DSN` = your DSN
3. Redeploy (no code change needed)

### GitHub — Neon daily backup

1. Neon Console → Connect → **Direct connection** (no `-pooler`)
2. GitHub repo → Settings → Secrets → `NEON_DATABASE_URL_DIRECT`
3. Workflow runs daily: `.github/workflows/neon-db-backup.yml`

### Verify legacy data (if JSON files exist)

```powershell
cd backend
php artisan mudabbir:verify-legacy-migration --all
```

### JSON backup (before any migration)

```bash
bash scripts/backup-json.sh
# Copy mudabbir-json-backup-*.tar.gz off the server
```

### After 1–2 stable days (from dual-write start)

Render → `MUDABBIR_DUAL_WRITE_JSON=false`

Then redeploy — legacy JSON mirror stops; Postgres is the only write target.

### Old Render SQLite data (if import returned 0 rows)

If production had real users/expenses on SQLite before Neon:

```powershell
# Export database.sqlite from old Render disk, then:
powershell -ExecutionPolicy Bypass -File scripts/migrate-to-neon.ps1 `
  -DatabaseUrl "postgresql://...pooler.../neondb?sslmode=require" `
  -SqliteSource "C:\path\to\database.sqlite"
```

## Verify production

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-production-api.ps1
```

Expect `"driver":"pgsql"`.
