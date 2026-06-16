<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExpensesApiTest extends TestCase
{
    public function test_expenses_crud_workflow(): void
    {
        $index = $this->getJson('/api/expenses');
        $index->assertStatus(200)->assertJsonPath('success', true);

        $create = $this->postJson('/api/expenses', [
            'amount' => 120.5,
            'date' => '2025-05-01',
            'type' => 'expense',
            'notes' => 'غداء',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'النقدية',
            'category_name' => 'طعام',
            'is_recurring' => false,
        ]);
        $create->assertStatus(201)->assertJsonPath('success', true);
        $id = (int) $create->json('data.id');

        $show = $this->getJson("/api/expenses/{$id}");
        $show->assertStatus(200)->assertJsonPath('data.amount', 120.5);

        $update = $this->putJson("/api/expenses/{$id}", [
            'amount' => 150,
            'notes' => 'محدّث',
        ]);
        $update->assertStatus(200)->assertJsonPath('data.amount', 150);

        $delete = $this->deleteJson("/api/expenses/{$id}");
        $delete->assertStatus(200)->assertJsonPath('success', true);
    }
}
