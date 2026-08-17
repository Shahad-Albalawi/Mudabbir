<?php

namespace Tests\Feature;

use App\Models\UserNotification;
use Tests\TestCase;

/**
 * End-to-end API smoke coverage for the core financial workflow.
 */
class ApiSmokeWorkflowTest extends TestCase
{
    public function test_authenticated_user_can_complete_core_financial_workflow(): void
    {
        $auth = $this->registerUser('smoke-workflow@example.com');

        $expense = $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 150,
            'date' => '2025-06-15',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'Cash',
            'category_name' => 'Food',
        ]);
        $expense->assertCreated()
            ->assertJsonStructure(['data' => ['id', 'amount_formatted']]);

        $goal = $this->withApiAuth($auth)->postJson('/api/goals', [
            'name' => 'Emergency fund',
            'target' => 5000,
            'current_amount' => 0,
            'type' => 'Saving',
            'start_date' => '2025-01-01',
            'end_date' => '2026-12-31',
        ]);
        $goal->assertCreated();

        $budget = $this->withApiAuth($auth)->postJson('/api/budgets', [
            'amount' => 2000,
            'start_date' => '2025-06-01',
            'end_date' => '2025-06-30',
            'account_id' => 1,
        ]);
        $budget->assertCreated()
            ->assertJsonStructure(['data' => ['amount_formatted']]);

        $stats = $this->withApiAuth($auth)->getJson('/api/statistics');
        $stats->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => ['total_expense', 'total_income', 'current_balance'],
            ]);

        $report = $this->withApiAuth($auth)->getJson('/api/reports/monthly');
        $report->assertOk()->assertJsonPath('data.report_type', 'monthly');

        $dashboard = $this->withApiAuth($auth)->getJson('/api/dashboard');
        $dashboard->assertOk()->assertJsonPath('success', true);
    }
}
