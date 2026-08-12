#!/usr/bin/env bash
set -euo pipefail

export APP_ENV="${APP_ENV:-production}"
export APP_DEBUG="${APP_DEBUG:-false}"
export APP_URL="${APP_URL:-https://mudabbir-backend-api.onrender.com}"
export LOG_CHANNEL="${LOG_CHANNEL:-stderr}"
export LOG_LEVEL="${LOG_LEVEL:-warning}"
export DB_CONNECTION="${DB_CONNECTION:-sqlite}"
export TRUSTED_PROXIES="${TRUSTED_PROXIES:-*}"

if [ -z "${APP_KEY:-}" ] || [ "$APP_KEY" = "base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" ]; then
  echo "ERROR: Set APP_KEY in Render Environment (scripts/generate-app-key.ps1)."
  exit 1
fi

mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
touch database/database.sqlite

php artisan config:clear
php artisan migrate --force

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

php artisan config:cache
php artisan route:cache

echo "Mudabbir API starting (APP_ENV=${APP_ENV}, APP_URL=${APP_URL})"

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
