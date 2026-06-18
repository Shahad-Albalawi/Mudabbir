#!/usr/bin/env bash
set -euo pipefail

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

exec php artisan serve --host=0.0.0.0 --port="${PORT:-8080}"
