<?php

namespace Tests\Feature;

use Illuminate\Support\Carbon;
use Tests\TestCase;

class ExpenseConflictApiTest extends TestCase
{
    public function test_update_rejects_stale_client_with_server_version(): void
    {
        Carbon::setTestNow('2025-05-01 10:00:00');
        $auth = $this->registerUser('conflict@example.com');

        $create = $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 100,
            'date' => '2025-05-01',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
        ]);
        $create->assertCreated();
        $id = (int) $create->json('data.id');
        $serverUpdatedAt = (string) $create->json('data.updated_at');

        Carbon::setTestNow('2025-05-01 10:00:05');
        $this->withApiAuth($auth)->putJson("/api/expenses/{$id}", [
            'amount' => 120,
        ])->assertOk();

        $stale = $this->withApiAuth($auth)->putJson("/api/expenses/{$id}", [
            'amount' => 50,
            'updated_at' => $serverUpdatedAt,
        ]);

        $stale->assertStatus(409)
            ->assertJsonPath('conflict', true)
            ->assertJsonPath('data.amount', 120);

        Carbon::setTestNow();
    }
}
