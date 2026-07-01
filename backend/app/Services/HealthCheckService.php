<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class HealthCheckService
{
    /**
     * @return array{status: string, checks: array<string, array<string, mixed>>}
     */
    public function run(): array
    {
        $database = $this->checkDatabase();
        $storage = $this->checkStorage();
        $ai = $this->checkAiProvider();

        $criticalOk = ($database['ok'] ?? false) && ($storage['ok'] ?? false);
        $allOk = $criticalOk && ($ai['ok'] ?? false);

        $status = match (true) {
            ! $criticalOk => 'unhealthy',
            ! $allOk => 'degraded',
            default => 'ok',
        };

        return [
            'status' => $status,
            'service' => 'mudabbir-api',
            'environment' => (string) config('app.env'),
            'checks' => [
                'database' => $database,
                'storage' => $storage,
                'ai' => $ai,
            ],
        ];
    }

    public function httpStatus(array $report): int
    {
        $criticalOk = ($report['checks']['database']['ok'] ?? false)
            && ($report['checks']['storage']['ok'] ?? false);

        return $criticalOk ? 200 : 503;
    }

    /**
     * @return array<string, mixed>
     */
    private function checkDatabase(): array
    {
        $started = microtime(true);

        try {
            DB::connection()->getPdo();
            DB::select('select 1 as ok');

            return [
                'ok' => true,
                'driver' => (string) config('database.default'),
                'latency_ms' => (int) round((microtime(true) - $started) * 1000),
            ];
        } catch (\Throwable $e) {
            Log::warning('Health check: database failed', ['error' => $e->getMessage()]);

            return [
                'ok' => false,
                'driver' => (string) config('database.default'),
                'error' => 'Database connection failed',
            ];
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function checkStorage(): array
    {
        $probeDir = storage_path('framework/cache');
        $probeFile = $probeDir.'/health_probe_'.uniqid('', true).'.tmp';

        try {
            if (! is_dir($probeDir) && ! mkdir($probeDir, 0755, true) && ! is_dir($probeDir)) {
                throw new \RuntimeException('Storage directory is not writable');
            }

            if (file_put_contents($probeFile, 'ok') === false) {
                throw new \RuntimeException('Unable to write probe file');
            }

            $readable = is_readable($probeFile);
            @unlink($probeFile);

            if (! $readable) {
                throw new \RuntimeException('Unable to read probe file');
            }

            return [
                'ok' => true,
                'disk' => (string) config('filesystems.default', 'local'),
                'path' => $probeDir,
            ];
        } catch (\Throwable $e) {
            if (is_file($probeFile)) {
                @unlink($probeFile);
            }

            Log::warning('Health check: storage failed', ['error' => $e->getMessage()]);

            return [
                'ok' => false,
                'disk' => (string) config('filesystems.default', 'local'),
                'error' => 'Storage is not writable',
            ];
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function checkAiProvider(): array
    {
        $provider = strtolower((string) config('ai.provider', 'openai'));
        $apiKey = $this->aiApiKey($provider);
        $configured = is_string($apiKey) && trim($apiKey) !== '';

        if (! $configured) {
            return [
                'ok' => false,
                'provider' => $provider,
                'configured' => false,
                'reachable' => false,
                'error' => 'AI API key is not configured',
            ];
        }

        $reachable = $this->pingAiProvider($provider);
        $model = $provider === 'gemini'
            ? (string) config('gemini.model', 'gemini-2.0-flash')
            : (string) config('openai.model', 'gpt-4o-mini');

        return [
            'ok' => $reachable,
            'provider' => $provider,
            'model' => $model,
            'configured' => true,
            'reachable' => $reachable,
            ...($reachable ? [] : ['error' => 'AI provider is not reachable']),
        ];
    }

    private function aiApiKey(string $provider): string
    {
        if ($provider === 'gemini') {
            return (string) config('gemini.api_key', '');
        }

        return (string) config('openai.api_key', '');
    }

    private function pingAiProvider(string $provider): bool
    {
        $url = $provider === 'gemini'
            ? rtrim((string) config('gemini.base_url'), '/').'/models'
            : rtrim((string) config('openai.base_url', 'https://api.openai.com/v1'), '/').'/models';

        $apiKey = $this->aiApiKey($provider);

        try {
            $response = Http::withToken($apiKey)
                ->connectTimeout(3)
                ->timeout(5)
                ->get($url);

            // 2xx/401/403 still prove the provider endpoint is reachable.
            return $response->status() < 500;
        } catch (\Throwable $e) {
            Log::warning('Health check: AI provider ping failed', [
                'provider' => $provider,
                'error' => $e->getMessage(),
            ]);

            return false;
        }
    }
}
