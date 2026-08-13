#!/usr/bin/env bash
set -euo pipefail

export APP_ENV="${APP_ENV:-production}"
export APP_DEBUG="${APP_DEBUG:-false}"
export APP_URL="${APP_URL:-https://mudabbir-backend-api.onrender.com}"
export LOG_CHANNEL="${LOG_CHANNEL:-stderr}"
export LOG_LEVEL="${LOG_LEVEL:-warning}"
export HEALTH_DB_TIMEOUT_SECONDS="${HEALTH_DB_TIMEOUT_SECONDS:-5}"
export TRUSTED_PROXIES="${TRUSTED_PROXIES:-*}"

# Normalize Neon/Render DATABASE_URL for Laravel (driver must be pgsql, not Neon/neon).
normalize_database_url() {
  local url="${1:-}"
  [ -z "${url}" ] && return 0
  url="$(echo "${url}" | sed -E 's/^neon:/postgresql:/I')"
  url="$(echo "${url}" | sed -E 's/[?&]channel_binding=[^&]*//g')"
  url="$(echo "${url}" | sed -E 's/\?&/?/; s/\?$//')"
  printf '%s' "${url}"
}

if [ -n "${DATABASE_URL:-}" ]; then
  DATABASE_URL="$(normalize_database_url "${DATABASE_URL}")"
  export DATABASE_URL
  export DB_CONNECTION=pgsql
  export DB_SSLMODE="${DB_SSLMODE:-require}"
  echo "DB: using PostgreSQL (Neon) host=$(echo "${DATABASE_URL}" | sed -E 's|^[^@]+@([^/]+).*|\1|')"
else
  export DB_CONNECTION=sqlite
  echo "WARN: DATABASE_URL not set — using SQLite."
fi

if [ -z "${APP_KEY:-}" ] || [ "$APP_KEY" = "base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" ]; then
  echo "ERROR: Set APP_KEY in Render Environment (scripts/generate-app-key.ps1)."
  exit 1
fi

mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache

if [ "${DB_CONNECTION}" = "sqlite" ]; then
  touch database/database.sqlite
fi

php artisan config:clear

# PgBouncer pooler cannot run DDL — migrate via direct host (strip -pooler).
migrate_database_url() {
  local url="${NEON_DATABASE_URL_DIRECT:-${DATABASE_URL:-}}"
  url="$(normalize_database_url "${url}")"
  if [ -n "${url}" ] && echo "${url}" | grep -qi pooler; then
    url="$(echo "${url}" | sed 's/-pooler//')"
    echo "Neon: migrations use direct connection (pooler stripped)."
  fi
  printf '%s' "${url}"
}

run_migrate() {
  local attempt=1
  local max=3
  local migrate_url
  migrate_url="$(migrate_database_url)"

  while [ "${attempt}" -le "${max}" ]; do
    echo "Running migrations (attempt ${attempt}/${max})..."
    if [ "${DB_CONNECTION}" = "pgsql" ] && [ -n "${migrate_url}" ]; then
      if DATABASE_URL="${migrate_url}" php artisan migrate --force; then
        return 0
      fi
    elif php artisan migrate --force; then
      return 0
    fi
    if [ "${attempt}" -lt "${max}" ]; then
      echo "Migrate failed — waiting 12s (Neon cold start?)..."
      sleep 12
    fi
    attempt=$((attempt + 1))
  done
  echo "ERROR: migrations failed after ${max} attempts."
  return 1
}

run_migrate

# One-time legacy JSON → DB import (idempotent). Uses GitHub backup if local JSON is missing.
if [ "${MUDABBIR_SKIP_LEGACY_IMPORT:-}" != "1" ] && [ ! -f storage/app/.legacy-import-done ]; then
  mkdir -p storage/app
  has_json=false
  for f in expenses.json goals.json budgets.json challenges.json; do
    if [ -f "storage/app/${f}" ]; then
      has_json=true
      break
    fi
  done

  if [ "$has_json" = false ]; then
    backup_url="${MUDABBIR_LEGACY_JSON_BACKUP_URL:-https://raw.githubusercontent.com/Shahad-Albalawi/Mudabbir/backup/json-2026-08-12/mudabbir-json-2026-08-12-140250Z.tar.gz}"
    if [ -n "${backup_url}" ]; then
      echo "Fetching legacy JSON backup for import..."
      tmp_archive="$(mktemp /tmp/mudabbir-json-backup.XXXXXX.tar.gz)"
      tmp_dir="$(mktemp -d /tmp/mudabbir-json-staging.XXXXXX)"
      if curl -fsSL "${backup_url}" -o "${tmp_archive}"; then
        tar -xzf "${tmp_archive}" -C "${tmp_dir}"
        if [ -d "${tmp_dir}/storage-app" ]; then
          find "${tmp_dir}/storage-app" -type f -name '*.json' -exec cp {} storage/app/ \;
          has_json=true
        fi
      else
        echo "WARN: could not download legacy JSON backup."
      fi
      rm -rf "${tmp_dir}" "${tmp_archive}"
    fi
  fi

  if [ "$has_json" = true ]; then
    echo "Running legacy JSON import..."
    if php artisan mudabbir:import-legacy-json; then
      touch storage/app/.legacy-import-done
    else
      echo "WARN: legacy JSON import failed."
    fi
  fi
fi

# Do not config:cache — keeps DATABASE_URL/env working on Render after deploy.
php artisan route:cache

echo "Mudabbir API starting (APP_ENV=${APP_ENV}, DB_CONNECTION=${DB_CONNECTION})"

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
