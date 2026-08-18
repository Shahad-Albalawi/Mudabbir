<?php

namespace Tests\Feature;

use Tests\TestCase;

class ExpensesFilterApiTest extends TestCase
{
    public function test_expenses_index_supports_filters_and_formatted_amount(): void
    {
        $auth = $this->registerUser('filters@example.com');

        $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 120,
            'date' => '2025-05-10',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'النقدية',
            'category_name' => 'طعام',
        ])->assertCreated();

        $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 500,
            'date' => '2025-06-01',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 2,
            'account_name' => 'النقدية',
            'category_name' => 'نقل',
        ])->assertCreated();

        $response = $this->withApiAuth($auth)->getJson('/api/expenses?from=2025-05-01&to=2025-05-31&sort=amount');
        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('meta.per_page', 15)
            ->assertJsonPath('data.0.amount_formatted', '١٢٠٫٠٠ ﷼')
            ->assertJsonPath('data.0.category_icon', '🍽️');
    }

    public function test_expenses_index_rejects_invalid_filters(): void
    {
        $auth = $this->registerUser('invalid-filters@example.com');

        $this->withApiAuth($auth)->getJson('/api/expenses?sort=invalid')
            ->assertStatus(422);

        $this->withApiAuth($auth)->getJson('/api/expenses?from=not-a-date')
            ->assertStatus(422);

        $this->withApiAuth($auth)->getJson('/api/expenses?per_page=500')
            ->assertStatus(422);
    }
}
