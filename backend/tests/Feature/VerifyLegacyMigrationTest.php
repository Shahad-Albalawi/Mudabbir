<?php

namespace Tests\Feature;

use App\Models\Expense;
use Illuminate\Support\Facades\File;
use Tests\TestCase;

class VerifyLegacyMigrationTest extends TestCase
{
    public function test_verify_passes_when_json_and_database_match(): void
    {
        $auth = $this->registerUser('verify-json@example.com');
        $userId = (int) $auth['user']['id'];

        $jsonPath = storage_path('app/testing-verify-expenses.json');
        File::put($jsonPath, json_encode([
            'expenses' => [[
                'id' => 9001,
                'user_id' => $userId,
                'amount' => 10.5,
                'date' => '2025-06-01',
                'type' => 'expense',
                'notes' => 'test',
                'account_id' => 1,
                'category_id' => 2,
                'account_name' => 'Cash',
                'category_name' => 'Food',
                'is_recurring' => false,
                'recurrence_interval' => null,
            ]],
        ], JSON_UNESCAPED_UNICODE));

        Expense::query()->create([
            'id' => 9001,
            'user_id' => $userId,
            'amount' => 10.5,
            'date' => '2025-06-01',
            'type' => 'expense',
            'notes' => 'test',
            'account_id' => 1,
            'category_id' => 2,
            'account_name' => 'Cash',
            'category_name' => 'Food',
            'is_recurring' => false,
            'recurrence_interval' => null,
            'synced_at' => now(),
        ]);

        $this->artisan('mudabbir:verify-legacy-migration', [
            '--expenses' => $jsonPath,
            '--sample-percent' => 100,
        ])->assertSuccessful();

        File::delete($jsonPath);
    }

    public function test_verify_fails_on_count_mismatch(): void
    {
        $jsonPath = storage_path('app/testing-verify-expenses-mismatch.json');
        File::put($jsonPath, json_encode([
            'expenses' => [[
                'id' => 9002,
                'user_id' => 1,
                'amount' => 1,
                'date' => '2025-06-01',
                'type' => 'expense',
                'account_id' => 1,
                'category_id' => 1,
                'account_name' => 'Cash',
                'category_name' => 'Food',
                'is_recurring' => false,
            ]],
        ], JSON_UNESCAPED_UNICODE));

        $this->artisan('mudabbir:verify-legacy-migration', [
            '--expenses' => $jsonPath,
            '--sample-percent' => 100,
        ])->assertFailed();

        File::delete($jsonPath);
    }
}
