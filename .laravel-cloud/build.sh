#!/usr/bin/env bash
# Monorepo workaround: promote backend/ to the deployment root before composer install.
# Configure in Laravel Cloud → Deployments → Build commands:
#   bash .laravel-cloud/build.sh && composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev && php artisan config:cache && php artisan route:cache
set -euo pipefail

mkdir -p /tmp/monorepo_tmp
repos=("backend" "frontend" "docs" "scripts" "screenshots" ".devcontainer")
for item in "${repos[@]}"; do
  if [ -d "$item" ]; then
    mv "$item" /tmp/monorepo_tmp/
  fi
done

cp -Rf /tmp/monorepo_tmp/backend/. .
rm -rf /tmp/monorepo_tmp

echo "Monorepo: backend/ promoted to deployment root."
