<?php

namespace App\Services;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\ResolvesSyncConflicts;
use App\Services\Concerns\UsesJsonStorePath;
use Carbon\Carbon;

class ExpenseStore
{
    use ManagesJsonFileStore;
    use ResolvesSyncConflicts;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('expenses.json');
    }

    protected function emptyDocument(): array
    {
        return [
            'next_expense_id' => 1,
            'expenses' => [],
        ];
    }

    protected function collectionKey(): string
    {
        return 'expenses';
    }

    public function all(int $userId): array
    {
        $data = $this->mutateStore(fn (array $data): array => $data);

        $owned = array_values(array_filter(
            $data['expenses'],
            fn (array $expense): bool => (int) ($expense['user_id'] ?? 0) === $userId
        ));

        return array_values(array_map(
            fn (array $expense): array => $this->normalizeExpense($expense),
            $owned
        ));
    }

    public function find(int $id, int $userId): ?array
    {
        return $this->mutateStore(function (array $data) use ($id, $userId): ?array {
            foreach ($data['expenses'] as $expense) {
                if ((int) $expense['id'] === $id && (int) ($expense['user_id'] ?? 0) === $userId) {
                    return $this->normalizeExpense($expense);
                }
            }

            return null;
        });
    }

    public function create(array $payload, int $userId): array
    {
        return $this->mutateStore(function (array &$data) use ($payload, $userId): array {
            $id = (int) $data['next_expense_id'];
            $data['next_expense_id'] = $id + 1;
            $expense = $this->buildExpense($id, $payload, $userId);
            $data['expenses'][] = $expense;

            return $expense;
        });
    }

    /**
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        return $this->mutateStore(function (array &$data) use ($id, $updates, $userId, $clientUpdatedAt): ?array {
            foreach ($data['expenses'] as $idx => $expense) {
                if ((int) $expense['id'] !== $id || (int) ($expense['user_id'] ?? 0) !== $userId) {
                    continue;
                }

                $conflict = $this->resolveUpdateConflict(
                    $expense,
                    $clientUpdatedAt,
                    fn (array $row): array => $this->normalizeExpense($row)
                );
                if ($conflict !== null) {
                    return $conflict;
                }

                $merged = array_merge($expense, $this->filterUpdatable($updates));
                $merged['updated_at'] = Carbon::now()->toISOString();
                $data['expenses'][$idx] = $this->normalizeExpense($merged);

                return [
                    'conflict' => false,
                    'data' => $data['expenses'][$idx],
                ];
            }

            return null;
        });
    }

    public function delete(int $id, int $userId): bool
    {
        return $this->mutateStore(function (array &$data) use ($id, $userId): bool {
            $before = count($data['expenses']);
            $data['expenses'] = array_values(array_filter(
                $data['expenses'],
                fn (array $expense): bool => ! ((int) $expense['id'] === $id && (int) ($expense['user_id'] ?? 0) === $userId)
            ));

            return count($data['expenses']) < $before;
        });
    }

    private function buildExpense(int $id, array $payload, int $userId): array
    {
        $now = Carbon::now()->toISOString();

        return $this->normalizeExpense([
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
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

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

    private function normalizeExpense(array $expense): array
    {
        return [
            'id' => (int) $expense['id'],
            'user_id' => (int) ($expense['user_id'] ?? 0),
            'amount' => (float) $expense['amount'],
            'date' => (string) $expense['date'],
            'type' => (string) ($expense['type'] ?? 'expense'),
            'notes' => $expense['notes'] ?? null,
            'account_id' => (int) $expense['account_id'],
            'category_id' => (int) $expense['category_id'],
            'account_name' => (string) ($expense['account_name'] ?? ''),
            'category_name' => (string) ($expense['category_name'] ?? ''),
            'is_recurring' => (bool) ($expense['is_recurring'] ?? false),
            'recurrence_interval' => $expense['recurrence_interval'] ?? null,
            'created_at' => $expense['created_at'] ?? null,
            'updated_at' => $expense['updated_at'] ?? null,
        ];
    }
}
