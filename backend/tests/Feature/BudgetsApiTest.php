<?php

namespace Tests\Feature;

use Tests\TestCase;

class BudgetsApiTest extends TestCase
{
    public function test_budgets_crud_workflow(): void
    {
        $auth = $this->registerUser('budgets@example.com');

        $index = $this->withApiAuth($auth)->getJson('/api/budgets');
        $index->assertStatus(200)->assertJsonPath('success', true);

        $create = $this->withApiAuth($auth)->postJson('/api/budgets', [
            'amount' => 2500,
            'start_date' => '2025-06-01',
            'end_date' => '2025-06-30',
            'account_id' => 1,
        ]);
        $create->assertStatus(201)->assertJsonPath('success', true);
        $id = (int) $create->json('data.id');

        $show = $this->withApiAuth($auth)->getJson("/api/budgets/{$id}");
        $show->assertStatus(200)->assertJsonPath('data.amount', 2500);

        $update = $this->withApiAuth($auth)->putJson("/api/budgets/{$id}", [
            'amount' => 3000,
        ]);
        $update->assertStatus(200)->assertJsonPath('data.amount', 3000);

        $delete = $this->withApiAuth($auth)->deleteJson("/api/budgets/{$id}");
        $delete->assertStatus(200)->assertJsonPath('success', true);
    }

    public function test_budgets_require_authentication(): void
    {
        $this->getJson('/api/budgets')->assertStatus(401);
    }
}
