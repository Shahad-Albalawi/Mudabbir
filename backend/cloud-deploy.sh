#!/usr/bin/env bash
# Laravel Cloud deploy script (runs on laravel-cloud branch).
set -euo pipefail

source "$(dirname "$0")/cloud-env.sh"
cloud_prepare_database

php artisan migrate --force
php artisan config:cache

echo "Deploy complete."
