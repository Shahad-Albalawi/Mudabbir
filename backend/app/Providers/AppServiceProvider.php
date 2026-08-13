<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        if ($this->app->environment('local')) {
            $this->app->register(TelescopeServiceProvider::class);
        }
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        if ($this->app->environment('production')) {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        $this->configurePostgresFromDatabaseUrl();
    }

    /**
     * Neon / Render may set DB_CONNECTION=Neon or DATABASE_URL with a non-Laravel scheme.
     * Laravel only supports driver "pgsql" for PostgreSQL — parse the URL ourselves.
     */
    private function configurePostgresFromDatabaseUrl(): void
    {
        $url = env('DATABASE_URL');
        if (! is_string($url) || trim($url) === '') {
            return;
        }

        // Render Neon integration sometimes uses neon:// — Laravel would treat that as driver "neon".
        $url = (string) preg_replace('/^neon:/i', 'postgresql:', trim($url));

        $parsed = parse_url($url);
        if ($parsed === false || empty($parsed['host'])) {
            return;
        }

        $database = ltrim((string) ($parsed['path'] ?? ''), '/');
        $query = [];
        if (! empty($parsed['query'])) {
            parse_str($parsed['query'], $query);
        }

        config([
            'database.default' => 'pgsql',
            'database.connections.pgsql' => array_merge(
                (array) config('database.connections.pgsql', []),
                [
                    'driver' => 'pgsql',
                    'url' => null,
                    'host' => $parsed['host'],
                    'port' => $parsed['port'] ?? 5432,
                    'database' => $database !== '' ? $database : 'neondb',
                    'username' => $parsed['user'] ?? null,
                    'password' => $parsed['pass'] ?? null,
                    'sslmode' => $query['sslmode'] ?? env('DB_SSLMODE', 'require'),
                ]
            ),
        ]);
    }
}
