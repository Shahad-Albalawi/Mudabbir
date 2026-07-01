<?php

namespace Tests\Feature;

use App\Services\DashboardCache;
use App\Services\DashboardService;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class DashboardApiTest extends TestCase
{
    public function test_dashboard_requires_authentication(): void
    {
        $this->getJson('/api/dashboard')->assertUnauthorized();
    }

    public function test_dashboard_returns_unified_envelope(): void
    {
        $auth = $this->registerUser('dashboard-envelope@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/dashboard');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'health_score',
                    'health_grade',
                    'kpis' => [
                        'total_income',
                        'total_expenses',
                        'net_savings',
                        'savings_rate',
                    ],
                    'monthly_trend',
                    'expense_distribution',
                    'behavior_analysis' => [
                        'savings_consistency',
                        'spending_pattern',
                        'goal_adherence',
                        'prediction_next_month',
                    ],
                ],
                'message',
                'meta' => ['timestamp', 'version'],
            ])
            ->assertJsonPath('meta.version', '1.0');
    }

    public function test_dashboard_monthly_trend_has_six_months(): void
    {
        $auth = $this->registerUser('dashboard-trend@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/dashboard');

        $response->assertOk();
        $trend = $response->json('data.monthly_trend');
        $this->assertIsArray($trend);
        $this->assertCount(6, $trend);
        $this->assertArrayHasKey('month', $trend[0]);
        $this->assertArrayHasKey('income', $trend[0]);
        $this->assertArrayHasKey('expenses', $trend[0]);
    }

    public function test_dashboard_uses_cache(): void
    {
        $auth = $this->registerUser('dashboard-cache@example.com');
        $userId = (int) $auth['user']['id'];

        Cache::flush();

        $this->mock(DashboardService::class, function ($mock): void {
            $mock->shouldReceive('forUser')
                ->once()
                ->andReturn([
                    'health_score' => 70,
                    'health_grade' => 'good',
                    'kpis' => [
                        'total_income' => 12000,
                        'total_expenses' => 3580,
                        'net_savings' => 8420,
                        'savings_rate' => 29.8,
                    ],
                    'monthly_trend' => [],
                    'expense_distribution' => [],
                    'behavior_analysis' => [
                        'savings_consistency' => 'excellent',
                        'spending_pattern' => 'regular',
                        'goal_adherence' => 'on_track',
                        'prediction_next_month' => 9200,
                    ],
                ]);
        });

        $headers = ['Authorization' => 'Bearer '.$auth['token']];

        $this->getJson('/api/dashboard', $headers)->assertOk();
        $this->getJson('/api/dashboard', $headers)->assertOk();

        $this->assertTrue(Cache::has(DashboardCache::keyForUser($userId)));
    }

    public function test_dashboard_cache_cleared_when_expense_created(): void
    {
        $auth = $this->registerUser('dashboard-bust@example.com');
        $userId = (int) $auth['user']['id'];

        Cache::flush();
        Cache::put(DashboardCache::keyForUser($userId), ['cached' => true], now()->addMinutes(5));
        $this->assertTrue(Cache::has(DashboardCache::keyForUser($userId)));

        $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 150,
            'date' => now()->toDateString(),
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'نقدي',
            'category_name' => 'تسوق',
        ])->assertCreated();

        $this->assertFalse(Cache::has(DashboardCache::keyForUser($userId)));
    }
}
