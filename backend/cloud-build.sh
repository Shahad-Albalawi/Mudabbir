#!/usr/bin/env bash
# Laravel Cloud build script (runs on laravel-cloud branch where backend is at repo root).
set -euo pipefail

# Laravel Cloud may use PHP 8.5; refresh locked packages that only declare support up to 8.3.
composer update nette/schema nette/utils league/config \
  --with-all-dependencies \
  --no-interaction \
  --no-dev \
  --prefer-dist \
  --optimize-autoloader

php artisan config:cache
php artisan route:cache

echo "Build complete."
