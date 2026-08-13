#!/usr/bin/env bash
#
# Migrate Mudabbir data from Render (SQLite) to Neon (PostgreSQL).
#
# Render production uses SQLite — there is no pg_dump on Render.
# Export database/database.sqlite from the running container (or use a local copy),
# then run this script against Neon.
#
# Prerequisites:
#   1. Neon project with production branch + optional development branch
#   2. DATABASE_URL = pooled URI (-pooler host) for Laravel
#   3. SQLITE_SOURCE = path to exported database.sqlite from Render
#
# Usage:
#   export DATABASE_URL='postgresql://...@ep-xxx-pooler.../neondb?sslmode=require'
#   export DB_CONNECTION=pgsql
#   export SQLITE_SOURCE=/path/to/database.sqlite
#   ./scripts/migrate-to-neon.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND="${ROOT}/backend"

if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: Set DATABASE_URL to Neon POOLED connection string." >&2
  exit 1
fi

if echo "${DATABASE_URL}" | grep -qi pooler; then
  echo "OK: using pooled Neon connection."
else
  echo "WARN: DATABASE_URL does not contain 'pooler' — use pooled URI for Laravel." >&2
fi

if [ -z "${SQLITE_SOURCE:-}" ] || [ ! -f "${SQLITE_SOURCE}" ]; then
  echo "ERROR: Set SQLITE_SOURCE to exported Render SQLite file." >&2
  exit 1
fi

export DB_CONNECTION=pgsql
export DB_SSLMODE="${DB_SSLMODE:-require}"
export HEALTH_DB_TIMEOUT_SECONDS="${HEALTH_DB_TIMEOUT_SECONDS:-5}"

cd "${BACKEND}"

MIGRATE_URL="${NEON_DATABASE_URL_DIRECT:-${DATABASE_URL}}"
if echo "${MIGRATE_URL}" | grep -qi pooler; then
  MIGRATE_URL="$(echo "${MIGRATE_URL}" | sed 's/-pooler//')"
  echo "Neon: migrate uses direct connection (pooler stripped from host)."
fi

echo "=== 1/4 migrate schema on Neon ==="
DATABASE_URL="${MIGRATE_URL}" php artisan migrate --force

echo "=== 2/4 copy SQLite rows to PostgreSQL ==="
php artisan mudabbir:migrate-sqlite-to-pgsql --sqlite="${SQLITE_SOURCE}"

echo "=== 3/4 import legacy JSON (if files exist — idempotent) ==="
php artisan mudabbir:import-legacy-json || echo "WARN: legacy JSON import skipped or partial."

echo "=== 4/4 verify connection ==="
php artisan db:show || true

echo ""
echo "Next steps:"
echo "  1. Set Render DATABASE_URL (pooled) + DB_CONNECTION=pgsql"
echo "  2. Redeploy Render service"
echo "  3. curl -m 10 https://mudabbir-backend-api.onrender.com/api/health"
echo "  4. Add GitHub secret NEON_DATABASE_URL_DIRECT for daily pg_dump backups"
