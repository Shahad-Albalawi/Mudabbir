FROM php:8.2-cli-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    libsqlite3-dev \
    libpq-dev \
    libzip-dev \
    && docker-php-ext-install pdo_sqlite pdo_pgsql zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Laravel artisan during image build needs a placeholder key.
ENV APP_KEY=base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV APP_URL=https://mudabbir-backend-api.onrender.com
ENV DB_CONNECTION=sqlite
ENV LOG_CHANNEL=stderr

COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev --no-scripts

COPY . .

# Bump to invalidate Docker cache when deploy scripts change.
ARG DEPLOY_REV=20260813-neon-pgsql
RUN echo "Deploy revision: ${DEPLOY_REV}"

RUN mkdir -p database storage/framework/cache storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && touch database/database.sqlite \
    && composer dump-autoload --optimize \
    && php artisan package:discover --ansi

RUN chmod +x docker/render-start.sh

ENV PORT=8080
EXPOSE 8080

CMD ["./docker/render-start.sh"]
