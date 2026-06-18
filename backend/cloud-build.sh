#!/usr/bin/env bash
# Laravel Cloud build script (runs on laravel-cloud branch where backend is at repo root).
set -euo pipefail

composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache

echo "Build complete."
