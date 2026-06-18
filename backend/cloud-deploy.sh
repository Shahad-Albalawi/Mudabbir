#!/usr/bin/env bash
# Laravel Cloud deploy script (runs on laravel-cloud branch).
set -euo pipefail

mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache

php artisan config:clear

use_sqlite() {
  export DB_CONNECTION=sqlite
  export DB_DATABASE="${PWD}/database/database.sqlite"
  unset DB_HOST DB_PORT DB_USERNAME DB_PASSWORD DATABASE_URL MYSQL_ATTR_SSL_CA || true
  touch database/database.sqlite
  php artisan config:clear
}

conn="${DB_CONNECTION:-sqlite}"

if [ "$conn" = "sqlite" ]; then
  use_sqlite
elif [ "$conn" = "mysql" ]; then
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
    echo "MySQL unreachable (connection refused). Falling back to SQLite."
    echo "For production auth, attach a Laravel Cloud Database or set DB_CONNECTION=sqlite in env."
    use_sqlite
  fi
fi

php artisan migrate --force
php artisan config:cache

echo "Deploy complete."
