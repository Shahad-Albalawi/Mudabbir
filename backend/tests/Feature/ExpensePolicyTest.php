<?php

namespace Tests\Feature;

use App\Models\Expense;
use Tests\TestCase;

class ExpensePolicyTest extends TestCase
{
    public function test_user_cannot_view_another_users_expense(): void
    {
        $owner = $this->registerUser('owner@example.com');
        $other = $this->registerUser('other@example.com');

        $create = $this->withApiAuth($owner)->postJson('/api/expenses', [
            'amount' => 50,
            'date' => '2025-06-01',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'Cash',
            'category_name' => 'Food',
        ]);
        $create->assertStatus(201);
        $id = (int) $create->json('data.id');

        $this->withApiAuth($other)->getJson("/api/expenses/{$id}")
            ->assertStatus(404);

        $this->withApiAuth($other)->putJson("/api/expenses/{$id}", ['amount' => 99])
            ->assertStatus(404);

        $this->withApiAuth($other)->deleteJson("/api/expenses/{$id}")
            ->assertStatus(404);

        $this->assertNotNull(Expense::query()->find($id));
    }
}
