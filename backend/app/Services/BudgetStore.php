<?php

namespace App\Services;

use App\Models\Budget;
use App\Services\Concerns\ResolvesSyncConflicts;
use Illuminate\Support\Facades\DB;

class BudgetStore
{
    use ResolvesSyncConflicts;

    /**
     * @return list<array<string, mixed>>
     */
    public function all(int $userId): array
    {
        return Budget::query()
            ->forUser($userId)
            ->orderByDesc('id')
            ->get()
            ->map(fn (Budget $budget): array => $budget->toStoreArray())
            ->all();
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function allUsersBudgets(): array
    {
        return Budget::query()
            ->orderByDesc('id')
            ->get()
            ->map(fn (Budget $budget): array => $budget->toStoreArray())
            ->all();
    }

    /**
     * @return array<string, mixed>|null
     */
    public function find(int $id, int $userId): ?array
    {
        $budget = Budget::query()->forUser($userId)->whereKey($id)->first();

        return $budget?->toStoreArray();
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public function create(array $payload, int $userId): array
    {
        $budget = DB::transaction(function () use ($payload, $userId): Budget {
            return Budget::query()->create([
                'id' => $this->nextBudgetId(),
                'user_id' => $userId,
                'amount' => (float) $payload['amount'],
                'start_date' => (string) $payload['start_date'],
                'end_date' => (string) $payload['end_date'],
                'account_id' => (int) $payload['account_id'],
            ]);
        });

        return $budget->toStoreArray();
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        $budget = Budget::query()->forUser($userId)->whereKey($id)->first();
        if ($budget === null) {
            return null;
        }

        $conflict = $this->resolveUpdateConflict(
            $budget->toStoreArray(),
            $clientUpdatedAt,
            fn (array $row): array => $row
        );
        if ($conflict !== null) {
            return $conflict;
        }

        $budget->fill($this->filterUpdatable($updates));
        $budget->save();

        return [
            'conflict' => false,
            'data' => $budget->fresh()->toStoreArray(),
        ];
    }

    public function delete(int $id, int $userId): bool
    {
        return Budget::query()->forUser($userId)->whereKey($id)->delete() > 0;
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array<string, mixed>
     */
    private function filterUpdatable(array $updates): array
    {
        $allowed = ['amount', 'start_date', 'end_date', 'account_id'];
        $filtered = [];
        foreach ($allowed as $key) {
            if (array_key_exists($key, $updates)) {
                $filtered[$key] = $updates[$key];
            }
        }

        return $filtered;
    }

    private function nextBudgetId(): int
    {
        return ((int) Budget::query()->max('id')) + 1;
    }
}
