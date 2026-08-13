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

# Export DB_HOST/DB_* from DATABASE_URL — Laravel env('DATABASE_URL') is unreliable on Render CLI.
apply_database_url() {
  local url="${1:-}"
  url="$(normalize_database_url "${url}")"
  [ -z "${url}" ] && return 1

  export DATABASE_URL="${url}"
  export DB_CONNECTION=pgsql
  export DB_SSLMODE="${DB_SSLMODE:-require}"

  eval "$(
    MUDABBIR_DB_URL="${url}" php -r '
      $url = getenv("MUDABBIR_DB_URL") ?: "";
      $parsed = parse_url($url);
      if ($parsed === false || empty($parsed["host"])) {
        fwrite(STDERR, "ERROR: invalid DATABASE_URL (cannot parse host)\n");
        exit(1);
      }
      $query = [];
      if (! empty($parsed["query"])) {
        parse_str($parsed["query"], $query);
      }
      $database = ltrim((string) ($parsed["path"] ?? ""), "/");
      if ($database === "") {
        $database = "neondb";
      }
      $exports = [
        "DB_HOST" => $parsed["host"],
        "DB_PORT" => (string) ($parsed["port"] ?? 5432),
        "DB_DATABASE" => $database,
        "DB_USERNAME" => $parsed["user"] ?? "",
        "DB_PASSWORD" => $parsed["pass"] ?? "",
      ];
      if (! empty($query["sslmode"])) {
        $exports["DB_SSLMODE"] = $query["sslmode"];
      }
      foreach ($exports as $key => $value) {
        echo "export {$key}=".escapeshellarg((string) $value)."\n";
      }
    '
  )"

  echo "DB: PostgreSQL host=${DB_HOST} database=${DB_DATABASE}"
}

POOLED_DATABASE_URL=""

if [ -n "${DATABASE_URL:-}" ]; then
  POOLED_DATABASE_URL="$(normalize_database_url "${DATABASE_URL}")"
  apply_database_url "${POOLED_DATABASE_URL}"
else
  unset DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD || true
  export DB_CONNECTION=sqlite
  echo "WARN: DATABASE_URL not set — using SQLite."
fi

if [ -z "${APP_KEY:-}" ] || [ "$APP_KEY" = "base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" ]; then
  echo "ERROR: Set APP_KEY in Render Environment (scripts/generate-app-key.ps1)."
  exit 1
fi

mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
rm -f bootstrap/cache/config.php

if [ "${DB_CONNECTION}" = "sqlite" ]; then
  touch database/database.sqlite
fi

php artisan config:clear

# PgBouncer pooler cannot run DDL — migrate via direct host (strip -pooler).
migrate_database_url() {
  local url="${NEON_DATABASE_URL_DIRECT:-${POOLED_DATABASE_URL:-${DATABASE_URL:-}}}"
  url="$(normalize_database_url "${url}")"
  if [ -n "${url}" ] && echo "${url}" | grep -qi pooler; then
    url="$(echo "${url}" | sed 's/-pooler//')"
    echo "Neon: migrations use direct connection (pooler stripped)." >&2
  fi
  printf '%s' "${url}"
}

run_migrate() {
  local attempt=1
  local max=3
  local migrate_url

  if [ "${DB_CONNECTION}" != "pgsql" ]; then
    php artisan migrate --force
    return 0
  fi

  migrate_url="$(migrate_database_url)"
  if [ -z "${migrate_url}" ]; then
    echo "ERROR: DATABASE_URL missing — cannot migrate PostgreSQL."
    return 1
  fi

  while [ "${attempt}" -le "${max}" ]; do
    echo "Running migrations (attempt ${attempt}/${max})..."
    if ! apply_database_url "${migrate_url}"; then
      echo "ERROR: could not parse migrate DATABASE_URL." >&2
      return 1
    fi
    if echo "${DB_HOST}" | grep -qi pooler; then
      echo "ERROR: migrate must not use pooler host (${DB_HOST})." >&2
      return 1
    fi
    echo "Migrate DB host=${DB_HOST}" >&2
    if php artisan migrate --force; then
      # Restore pooled URL for web requests (PgBouncer).
      if [ -n "${POOLED_DATABASE_URL}" ]; then
        apply_database_url "${POOLED_DATABASE_URL}"
      fi
      return 0
    fi
    if [ "${attempt}" -lt "${max}" ]; then
      echo "Migrate failed — waiting 15s (Neon cold start?)..."
      sleep 15
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
      echo "WARN: legacy JSON import failed — marking done to avoid deploy loop."
      touch storage/app/.legacy-import-done
    fi
  fi
fi

php artisan route:cache

echo "Mudabbir API starting (APP_ENV=${APP_ENV}, DB_CONNECTION=${DB_CONNECTION}, DB_HOST=${DB_HOST:-n/a})"

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
