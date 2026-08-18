#!/usr/bin/env bash
# Shared Laravel Cloud DB/env normalization (no dashboard edits required).
set -euo pipefail

cloud_prepare_storage() {
  mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
  touch database/database.sqlite
}

cloud_use_sqlite() {
  export DB_CONNECTION=sqlite
  export DB_DATABASE="${PWD}/database/database.sqlite"
  unset DB_HOST DB_PORT DB_USERNAME DB_PASSWORD DATABASE_URL MYSQL_ATTR_SSL_CA || true

  if [ -f .env ]; then
    sed -i.bak '/^DB_CONNECTION=/d;/^DB_DATABASE=/d;/^DB_HOST=/d;/^DB_PORT=/d;/^DB_USERNAME=/d;/^DB_PASSWORD=/d;/^DATABASE_URL=/d' .env 2>/dev/null || true
    rm -f .env.bak
  fi

  {
    echo "DB_CONNECTION=sqlite"
    echo "DB_DATABASE=${PWD}/database/database.sqlite"
  } >> .env

  php artisan config:clear 2>/dev/null || true
}

cloud_prepare_database() {
  cloud_prepare_storage

  local conn="${DB_CONNECTION:-}"
  local db_name="${DB_DATABASE:-}"

  # Laravel Cloud often injects mysql + forge without an attached database.
  if [ "$conn" = "sqlite" ] || [ -z "$conn" ]; then
    cloud_use_sqlite
    return
  fi

  if [ "$conn" = "mysql" ] && { [ "$db_name" = "forge" ] || [ "${DB_USERNAME:-}" = "forge" ]; }; then
    echo "Detected default forge MySQL credentials without Cloud Database — using SQLite."
    cloud_use_sqlite
    return
  fi

  if [ "$conn" = "mysql" ]; then
    if ! php -r "
      try {
        new PDO(
          'mysql:host=' . (getenv('DB_HOST') ?: '127.0.0.1') . ';port=' . (getenv('DB_PORT') ?: '3306'),
          getenv('DB_USERNAME') ?: 'forge',
          getenv('DB_PASSWORD') ?: '',
          [PDO::ATTR_TIMEOUT => 3]
        );
        exit(0);
      } catch (Throwable \$e) {
        exit(1);
      }
    "; then
      echo "MySQL unreachable — using SQLite for this environment."
      cloud_use_sqlite
    fi
  fi
}
