<?php

namespace App\Services;

use App\Models\Expense;
use Carbon\Carbon;

class ExpenseDatabaseSync
{
    public function __construct(private ExpenseStore $store) {}

    public function syncUser(int $userId): void
    {
        foreach ($this->store->all($userId) as $row) {
            $this->upsertFromArray($row);
        }
    }

    /**
     * @param  array<string, mixed>  $row
     */
    public function upsertFromArray(array $row): Expense
    {
        $createdAt = isset($row['created_at'])
            ? Carbon::parse((string) $row['created_at'])
            : now();
        $updatedAt = isset($row['updated_at'])
            ? Carbon::parse((string) $row['updated_at'])
            : now();

        return Expense::query()->updateOrCreate(
            ['id' => (int) $row['id']],
            [
                'user_id' => (int) ($row['user_id'] ?? 0),
                'amount' => (float) $row['amount'],
                'date' => (string) $row['date'],
                'type' => (string) ($row['type'] ?? 'expense'),
                'notes' => $row['notes'] ?? null,
                'account_id' => (int) $row['account_id'],
                'category_id' => (int) $row['category_id'],
                'account_name' => (string) ($row['account_name'] ?? ''),
                'category_name' => (string) ($row['category_name'] ?? ''),
                'is_recurring' => (bool) ($row['is_recurring'] ?? false),
                'recurrence_interval' => $row['recurrence_interval'] ?? null,
                'synced_at' => now(),
                'created_at' => $createdAt,
                'updated_at' => $updatedAt,
            ]
        );
    }

    public function deleteById(int $id): void
    {
        Expense::query()->whereKey($id)->delete();
    }
}
