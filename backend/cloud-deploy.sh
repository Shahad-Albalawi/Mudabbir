#!/usr/bin/env bash
# Laravel Cloud deploy script (runs on laravel-cloud branch).
set -euo pipefail

php artisan migrate --force

echo "Deploy complete."
