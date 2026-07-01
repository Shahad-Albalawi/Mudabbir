<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class HealthApiTest extends TestCase
{
    public function test_health_endpoint_is_public_and_returns_ok_when_checks_pass(): void
    {
        Config::set('openai.api_key', 'sk-test-key');
        Config::set('ai.provider', 'openai');

        Http::fake([
            'api.openai.com/*' => Http::response(['data' => []], 200),
        ]);

        $response = $this->getJson('/api/health');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'ok')
            ->assertJsonPath('data.checks.database.ok', true)
            ->assertJsonPath('data.checks.storage.ok', true)
            ->assertJsonPath('data.checks.ai.ok', true);
    }

    public function test_health_returns_degraded_when_ai_is_not_configured(): void
    {
        Config::set('openai.api_key', '');
        Config::set('ai.provider', 'openai');

        $response = $this->getJson('/api/health');

        $response->assertOk()
            ->assertJsonPath('data.status', 'degraded')
            ->assertJsonPath('data.checks.database.ok', true)
            ->assertJsonPath('data.checks.storage.ok', true)
            ->assertJsonPath('data.checks.ai.configured', false);
    }

    public function test_health_returns_service_unavailable_when_database_fails(): void
    {
        DB::shouldReceive('connection')
            ->once()
            ->andReturn(new class
            {
                public function getPdo(): never
                {
                    throw new \PDOException('Connection refused');
                }
            });

        $response = $this->getJson('/api/health');

        $response->assertStatus(503)
            ->assertJsonPath('data.status', 'unhealthy')
            ->assertJsonPath('data.checks.database.ok', false);
    }
}
