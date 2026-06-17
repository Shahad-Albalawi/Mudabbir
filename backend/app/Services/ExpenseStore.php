<?php

namespace App\Services;

use App\Services\Concerns\ResolvesSyncConflicts;
use App\Services\Concerns\UsesJsonStorePath;
use Carbon\Carbon;
use Illuminate\Support\Facades\File;

class ExpenseStore
{
    use ResolvesSyncConflicts;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('expenses.json');
    }

    public function all(int $userId): array
    {
        $data = $this->read();

        $owned = array_values(array_filter(
            $data['expenses'],
            function (array $expense) use ($userId): bool {
                return (int) ($expense['user_id'] ?? 0) === $userId;
            }
        ));

        return array_values(array_map(function (array $expense): array {
            return $this->normalizeExpense($expense);
        }, $owned));
    }

    public function find(int $id, int $userId): ?array
    {
        $data = $this->read();
        foreach ($data['expenses'] as $expense) {
            if ((int) $expense['id'] === $id && (int) ($expense['user_id'] ?? 0) === $userId) {
                return $this->normalizeExpense($expense);
            }
        }

        return null;
    }

    public function create(array $payload, int $userId): array
    {
        $data = $this->read();
        $id = (int) $data['next_expense_id'];
        $data['next_expense_id'] = $id + 1;

        $expense = $this->buildExpense($id, $payload, $userId);
        $data['expenses'][] = $expense;
        $this->write($data);

        return $expense;
    }

    /**
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        $data = $this->read();
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
            $this->write($data);

            return [
                'conflict' => false,
                'data' => $data['expenses'][$idx],
            ];
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $data = $this->read();
        $before = count($data['expenses']);
        $data['expenses'] = array_values(array_filter(
            $data['expenses'],
            function (array $expense) use ($id, $userId): bool {
                return ! ((int) $expense['id'] === $id && (int) ($expense['user_id'] ?? 0) === $userId);
            }
        ));

        if (count($data['expenses']) === $before) {
            return false;
        }

        $this->write($data);

        return true;
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
            'amount',
            'date',
            'type',
            'notes',
            'account_id',
            'category_id',
            'account_name',
            'category_name',
            'is_recurring',
            'recurrence_interval',
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

    private function read(): array
    {
        if (! File::exists($this->path)) {
            $seed = [
                'next_expense_id' => 1,
                'expenses' => [],
            ];
            $this->write($seed);

            return $seed;
        }

        $decoded = json_decode((string) File::get($this->path), true);
        if (! is_array($decoded) || ! isset($decoded['expenses'])) {
            return [
                'next_expense_id' => 1,
                'expenses' => [],
            ];
        }

        return $decoded;
    }

    private function write(array $payload): void
    {
        File::ensureDirectoryExists(dirname($this->path));
        File::put($this->path, json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }
}
