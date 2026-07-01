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
php artisan config:cache
php artisan route:cache

echo "Mudabbir API starting (APP_ENV=${APP_ENV}, APP_URL=${APP_URL})"

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
