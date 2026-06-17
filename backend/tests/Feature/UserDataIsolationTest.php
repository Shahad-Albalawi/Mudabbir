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
    }
}
