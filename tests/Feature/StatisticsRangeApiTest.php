<?php

namespace Tests\Feature;

use Tests\TestCase;

class StatisticsRangeApiTest extends TestCase
{
    public function test_statistics_accepts_period_query(): void
    {
        $auth = $this->registerUser('stats-range@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/statistics?period=week');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    'period' => ['from', 'to'],
                    'total_expense',
                    'daily_expense',
                    'transaction_count',
                ],
            ]);
    }

    public function test_statistics_accepts_explicit_from_to(): void
    {
        $auth = $this->registerUser('stats-range-dates@example.com');

        $response = $this->withApiAuth($auth)->getJson(
            '/api/statistics?from=2026-08-01&to=2026-08-18'
        );

        $response
            ->assertOk()
            ->assertJsonPath('data.period.from', '2026-08-01')
            ->assertJsonPath('data.period.to', '2026-08-18');
    }
}
