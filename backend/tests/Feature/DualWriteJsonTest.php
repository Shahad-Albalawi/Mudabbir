<?php

namespace Tests\Feature;

use App\Services\Legacy\LegacyJsonExpenseStore;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\File;
use Tests\TestCase;

class DualWriteJsonTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        Config::set('mudabbir.json_store_subdir', 'testing-dual-write');
        Config::set('mudabbir.dual_write_json', true);
        Config::set('mudabbir.dual_write_json_until', null);

        $dir = storage_path('app/testing-dual-write');
        if (File::isDirectory($dir)) {
            File::deleteDirectory($dir);
        }
    }

    public function test_expense_create_mirrors_to_legacy_json_when_dual_write_enabled(): void
    {
        $auth = $this->registerUser('dual-write@example.com');

        $response = $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 99.5,
            'date' => '2025-06-01',
            'type' => 'expense',
            'notes' => 'mirror test',
            'account_id' => 1,
            'category_id' => 2,
            'account_name' => 'Cash',
            'category_name' => 'Food',
            'is_recurring' => false,
        ]);

        $response->assertStatus(201);
        $id = (int) $response->json('data.id');

        $legacy = app(LegacyJsonExpenseStore::class);
        $jsonPath = storage_path('app/testing-dual-write/expenses.json');
        $this->assertFileExists($jsonPath);

        $decoded = json_decode((string) File::get($jsonPath), true);
        $match = collect($decoded['expenses'] ?? [])->first(fn (array $row): bool => (int) $row['id'] === $id);
        $this->assertNotNull($match);
        $this->assertSame(99.5, (float) $match['amount']);
        $this->assertSame('mirror test', $match['notes']);
    }

    public function test_expense_delete_removes_row_from_legacy_json(): void
    {
        $auth = $this->registerUser('dual-write-delete@example.com');

        $create = $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 10,
            'date' => '2025-06-02',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'Cash',
            'category_name' => 'Food',
        ]);
        $id = (int) $create->json('data.id');

        $this->withApiAuth($auth)->deleteJson("/api/expenses/{$id}")->assertStatus(200);

        $jsonPath = storage_path('app/testing-dual-write/expenses.json');
        $decoded = json_decode((string) File::get($jsonPath), true);
        $match = collect($decoded['expenses'] ?? [])->first(fn (array $row): bool => (int) $row['id'] === $id);
        $this->assertNull($match);
    }

    public function test_dual_write_can_be_disabled_via_config(): void
    {
        Config::set('mudabbir.dual_write_json', false);
        $auth = $this->registerUser('dual-write-off@example.com');

        $this->withApiAuth($auth)->postJson('/api/expenses', [
            'amount' => 5,
            'date' => '2025-06-03',
            'account_id' => 1,
            'category_id' => 1,
            'account_name' => 'Cash',
            'category_name' => 'Food',
        ])->assertStatus(201);

        $this->assertFileDoesNotExist(storage_path('app/testing-dual-write/expenses.json'));
    }
}
