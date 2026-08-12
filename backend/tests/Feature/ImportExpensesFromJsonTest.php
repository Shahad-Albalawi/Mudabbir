<?php

namespace Tests\Feature;

use App\Models\Expense;
use Illuminate\Support\Facades\File;
use Tests\TestCase;

class ImportExpensesFromJsonTest extends TestCase
{
    public function test_import_command_loads_legacy_json_into_database(): void
    {
        $auth = $this->registerUser('import-json@example.com');
        $userId = (int) $auth['user']['id'];

        $jsonPath = storage_path('app/testing-import-expenses.json');
        File::ensureDirectoryExists(dirname($jsonPath));
        File::put($jsonPath, json_encode([
            'next_expense_id' => 3,
            'expenses' => [
                [
                    'id' => 1,
                    'user_id' => $userId,
                    'amount' => 42.5,
                    'date' => '2025-04-01',
                    'type' => 'expense',
                    'notes' => 'legacy',
                    'account_id' => 1,
                    'category_id' => 2,
                    'account_name' => 'Cash',
                    'category_name' => 'Food',
                    'is_recurring' => false,
                    'recurrence_interval' => null,
                    'created_at' => '2025-04-01T10:00:00+00:00',
                    'updated_at' => '2025-04-01T10:00:00+00:00',
                ],
            ],
        ], JSON_UNESCAPED_UNICODE));

        $this->artisan('mudabbir:import-expenses-json', ['path' => $jsonPath])
            ->assertSuccessful();

        $this->assertDatabaseHas('expenses', [
            'id' => 1,
            'user_id' => $userId,
            'amount' => 42.5,
            'category_name' => 'Food',
        ]);

        File::delete($jsonPath);
    }

    public function test_expense_store_reads_from_database_not_json_file(): void
    {
        $auth = $this->registerUser('db-only@example.com');
        $userId = (int) ($auth['user']['id'] ?? 0);

        Expense::query()->create([
            'id' => 5001,
            'user_id' => $userId,
            'amount' => 88,
            'date' => '2025-03-15',
            'type' => 'expense',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'Cash',
            'category_name' => 'Other',
            'is_recurring' => false,
            'synced_at' => now(),
        ]);

        $response = $this->withApiAuth($auth)->getJson('/api/expenses');
        $response->assertOk()
            ->assertJsonPath('data.0.amount', 88)
            ->assertJsonPath('data.0.id', 5001);
    }
}
