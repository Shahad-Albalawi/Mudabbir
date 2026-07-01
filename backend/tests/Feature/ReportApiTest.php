<?php

namespace Tests\Feature;

use App\Services\ReportService;
use Illuminate\Support\Facades\Cache;
use Tests\TestCase;

class ReportApiTest extends TestCase
{
    public function test_monthly_report_requires_authentication(): void
    {
        $this->getJson('/api/reports/monthly')->assertUnauthorized();
    }

    public function test_monthly_report_returns_unified_envelope(): void
    {
        $auth = $this->registerUser('report-envelope@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/reports/monthly');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.report_type', 'monthly')
            ->assertJsonStructure([
                'success',
                'data' => [
                    'report_type',
                    'period',
                    'summary',
                    'expense_by_category',
                    'goals',
                ],
                'meta' => ['timestamp', 'version'],
            ]);
    }

    public function test_monthly_report_uses_cache(): void
    {
        $auth = $this->registerUser('report-cache@example.com');
        $userId = (int) $auth['user']['id'];

        Cache::flush();

        $this->mock(ReportService::class, function ($mock): void {
            $mock->shouldReceive('monthlyForUser')
                ->once()
                ->andReturn([
                    'report_type' => 'monthly',
                    'summary' => ['total_income' => 0, 'total_expense' => 0],
                ]);
        });

        $headers = ['Authorization' => 'Bearer '.$auth['token']];

        $this->getJson('/api/reports/monthly', $headers)->assertOk();
        $this->getJson('/api/reports/monthly', $headers)->assertOk();

        $this->assertTrue(Cache::has("api:reports:monthly:user:{$userId}:current"));
    }
}
