<?php

namespace Tests\Feature;

use Tests\TestCase;

class UserDataIsolationTest extends TestCase
{
    public function test_each_user_sees_only_their_own_expenses(): void
    {
        $userA = $this->registerUser('alice@example.com', 'Alice');
        $userB = $this->registerUser('bob@example.com', 'Bob');

        $this->withApiAuth($userA)->postJson('/api/expenses', [
            'amount' => 100,
            'date' => '2025-05-01',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'notes' => 'Alice expense',
        ])->assertCreated();

        $this->withApiAuth($userB)->postJson('/api/expenses', [
            'amount' => 200,
            'date' => '2025-05-02',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'notes' => 'Bob expense',
        ])->assertCreated();

        $aliceList = $this->withApiAuth($userA)->getJson('/api/expenses');
        $aliceList->assertOk()->assertJsonCount(1, 'data');
        $aliceList->assertJsonPath('data.0.amount', 100);
        $aliceList->assertJsonPath('data.0.notes', 'Alice expense');

        $bobList = $this->withApiAuth($userB)->getJson('/api/expenses');
        $bobList->assertOk()->assertJsonCount(1, 'data');
        $bobList->assertJsonPath('data.0.amount', 200);
        $bobList->assertJsonPath('data.0.notes', 'Bob expense');

        $aliceId = (int) $aliceList->json('data.0.id');
        $this->withApiAuth($userB)->getJson("/api/expenses/{$aliceId}")->assertStatus(404);
        $this->withApiAuth($userB)->putJson("/api/expenses/{$aliceId}", [
            'amount' => 999,
        ])->assertStatus(404);
        $this->withApiAuth($userB)->deleteJson("/api/expenses/{$aliceId}")->assertStatus(404);
    }

    public function test_user_cannot_access_another_users_goal(): void
    {
        $userA = $this->registerUser('goal-alice@example.com', 'Alice');
        $userB = $this->registerUser('goal-bob@example.com', 'Bob');

        $created = $this->withApiAuth($userA)->postJson('/api/goals', [
            'name' => 'Alice goal',
            'target' => 1000,
            'current_amount' => 0,
            'type' => 'Saving',
            'start_date' => '2025-01-01',
            'end_date' => '2026-12-31',
        ])->assertCreated();

        $goalId = (int) $created->json('data.id');

        $this->withApiAuth($userB)->getJson("/api/goals/{$goalId}")->assertStatus(404);
        $this->withApiAuth($userB)->putJson("/api/goals/{$goalId}", [
            'name' => 'Hacked',
        ])->assertStatus(404);
        $this->withApiAuth($userB)->deleteJson("/api/goals/{$goalId}")->assertStatus(404);
    }

    public function test_monthly_report_is_scoped_to_authenticated_user(): void
    {
        $userA = $this->registerUser('report-alice@example.com', 'Alice');
        $userB = $this->registerUser('report-bob@example.com', 'Bob');

        $this->withApiAuth($userA)->postJson('/api/expenses', [
            'amount' => 50,
            'date' => now()->format('Y-m-d'),
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
        ])->assertCreated();

        $aliceReport = $this->withApiAuth($userA)->getJson('/api/reports/monthly');
        $aliceReport->assertOk();

        $bobReport = $this->withApiAuth($userB)->getJson('/api/reports/monthly');
        $bobReport->assertOk();

        $aliceExpenseTotal = (float) data_get($aliceReport->json(), 'data.summary.total_expense', 0);
        $bobExpenseTotal = (float) data_get($bobReport->json(), 'data.summary.total_expense', 0);

        $this->assertGreaterThan(0, $aliceExpenseTotal);
        $this->assertSame(0.0, $bobExpenseTotal);
    }
}
