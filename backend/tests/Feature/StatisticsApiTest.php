<?php

namespace Tests\Feature;

use App\Services\StatisticsService;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class StatisticsApiTest extends TestCase
{
    public function test_statistics_requires_authentication(): void
    {
        $this->getJson('/api/statistics')->assertUnauthorized();
    }

    public function test_statistics_returns_unified_envelope(): void
    {
        $auth = $this->registerUser('stats-envelope@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/statistics');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'total_income',
                    'total_expense',
                    'current_balance',
                    'savings_rate',
                    'monthly_trend',
                ],
                'message',
                'meta' => ['timestamp', 'version'],
            ])
            ->assertJsonPath('meta.version', '1.0');
    }

    public function test_statistics_uses_cache(): void
    {
        $auth = $this->registerUser('stats-cache@example.com');
        $userId = (int) $auth['user']['id'];

        Cache::flush();

        $this->mock(StatisticsService::class, function ($mock): void {
            $mock->shouldReceive('forUser')
                ->once()
                ->andReturn([
                    'total_income' => 1000,
                    'total_expense' => 500,
                    'current_balance' => 500,
                    'savings_rate' => 50,
                    'monthly_trend' => [],
                ]);
        });

        $headers = ['Authorization' => 'Bearer '.$auth['token']];

        $this->getJson('/api/statistics', $headers)->assertOk();
        $this->getJson('/api/statistics', $headers)->assertOk();

        $this->assertTrue(Cache::has("api:statistics:user:{$userId}"));
    }
}
