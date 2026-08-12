<?php

namespace App\Services;

use App\Models\Expense;
use App\Services\Concerns\ResolvesSyncConflicts;
use Illuminate\Support\Facades\DB;

class ExpenseStore
{
    use ResolvesSyncConflicts;

    /**
     * @return list<array<string, mixed>>
     */
    public function all(int $userId): array
    {
        return Expense::query()
            ->forUser($userId)
            ->orderByDesc('date')
            ->orderByDesc('id')
            ->get()
            ->map(fn (Expense $expense): array => $expense->toStoreArray())
            ->all();
    }

    /**
     * @return array<string, mixed>|null
     */
    public function find(int $id, int $userId): ?array
    {
        $expense = Expense::query()
            ->forUser($userId)
            ->whereKey($id)
            ->first();

        return $expense?->toStoreArray();
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public function create(array $payload, int $userId): array
    {
        $expense = DB::transaction(function () use ($payload, $userId): Expense {
            $id = $this->nextExpenseId();

            return Expense::query()->create([
                'id' => $id,
                'user_id' => $userId,
                'amount' => (float) $payload['amount'],
                'date' => (string) $payload['date'],
                'type' => (string) ($payload['type'] ?? 'expense'),
                'notes' => $payload['notes'] ?? null,
                'account_id' => (int) $payload['account_id'],
                'category_id' => (int) $payload['category_id'],
                'account_name' => (string) ($payload['account_name'] ?? ''),
                'category_name' => (string) ($payload['category_name'] ?? ''),
                'is_recurring' => (bool) ($payload['is_recurring'] ?? false),
                'recurrence_interval' => $payload['recurrence_interval'] ?? null,
                'synced_at' => now(),
            ]);
        });

        DashboardCache::forgetForUser($userId);

        return $expense->toStoreArray();
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        $expense = Expense::query()
            ->forUser($userId)
            ->whereKey($id)
            ->first();

        if ($expense === null) {
            return null;
        }

        $existing = $expense->toStoreArray();
        $conflict = $this->resolveUpdateConflict(
            $existing,
            $clientUpdatedAt,
            fn (array $row): array => $row
        );

        if ($conflict !== null) {
            return $conflict;
        }

        $expense->fill($this->filterUpdatable($updates));
        $expense->synced_at = now();
        $expense->save();

        DashboardCache::forgetForUser($userId);

        return [
            'conflict' => false,
            'data' => $expense->fresh()->toStoreArray(),
        ];
    }

    public function delete(int $id, int $userId): bool
    {
        $deleted = Expense::query()
            ->forUser($userId)
            ->whereKey($id)
            ->delete() > 0;

        if ($deleted) {
            DashboardCache::forgetForUser($userId);
        }

        return $deleted;
    }

    private function nextExpenseId(): int
    {
        return ((int) Expense::query()->max('id')) + 1;
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array<string, mixed>
     */
    private function filterUpdatable(array $updates): array
    {
        $allowed = [
            'amount', 'date', 'type', 'notes', 'account_id', 'category_id',
            'account_name', 'category_name', 'is_recurring', 'recurrence_interval',
        ];
        $filtered = [];
        foreach ($allowed as $field) {
            if (array_key_exists($field, $updates)) {
                $filtered[$field] = $updates[$field];
            }
        }

        return $filtered;
    }
}
