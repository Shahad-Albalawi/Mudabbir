<?php

namespace App\Services;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\ResolvesSyncConflicts;
use App\Services\Concerns\UsesJsonStorePath;
use Carbon\Carbon;

class BudgetStore
{
    use ManagesJsonFileStore;
    use ResolvesSyncConflicts;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('budgets.json');
    }

    protected function emptyDocument(): array
    {
        return [
            'next_budget_id' => 1,
            'budgets' => [],
        ];
    }

    protected function collectionKey(): string
    {
        return 'budgets';
    }

    public function all(int $userId): array
    {
        $data = $this->mutateStore(fn (array $data): array => $data);

        $owned = array_values(array_filter(
            $data['budgets'],
            fn (array $budget): bool => (int) ($budget['user_id'] ?? 0) === $userId
        ));

        return array_values(array_map(
            fn (array $budget): array => $this->normalizeBudget($budget),
            $owned
        ));
    }

    public function find(int $id, int $userId): ?array
    {
        return $this->mutateStore(function (array $data) use ($id, $userId): ?array {
            foreach ($data['budgets'] as $budget) {
                if ((int) $budget['id'] === $id && (int) ($budget['user_id'] ?? 0) === $userId) {
                    return $this->normalizeBudget($budget);
                }
            }

            return null;
        });
    }

    public function create(array $payload, int $userId): array
    {
        return $this->mutateStore(function (array &$data) use ($payload, $userId): array {
            $id = (int) $data['next_budget_id'];
            $data['next_budget_id'] = $id + 1;
            $now = Carbon::now();

            $budget = $this->normalizeBudget([
                'id' => $id,
                'user_id' => $userId,
                'amount' => (float) $payload['amount'],
                'start_date' => (string) $payload['start_date'],
                'end_date' => (string) $payload['end_date'],
                'account_id' => (int) $payload['account_id'],
                'created_at' => $now->toISOString(),
                'updated_at' => $now->toISOString(),
            ]);

            $data['budgets'][] = $budget;

            return $budget;
        });
    }

    /**
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        return $this->mutateStore(function (array &$data) use ($id, $updates, $userId, $clientUpdatedAt): ?array {
            foreach ($data['budgets'] as $idx => $budget) {
                if ((int) $budget['id'] !== $id || (int) ($budget['user_id'] ?? 0) !== $userId) {
                    continue;
                }

                $conflict = $this->resolveUpdateConflict(
                    $budget,
                    $clientUpdatedAt,
                    fn (array $row): array => $this->normalizeBudget($row)
                );
                if ($conflict !== null) {
                    return $conflict;
                }

                $merged = array_merge($budget, $this->filterUpdatable($updates));
                $merged['updated_at'] = Carbon::now()->toISOString();
                $data['budgets'][$idx] = $this->normalizeBudget($merged);

                return [
                    'conflict' => false,
                    'data' => $data['budgets'][$idx],
                ];
            }

            return null;
        });
    }

    public function delete(int $id, int $userId): bool
    {
        return $this->mutateStore(function (array &$data) use ($id, $userId): bool {
            $before = count($data['budgets']);
            $data['budgets'] = array_values(array_filter(
                $data['budgets'],
                fn (array $budget): bool => ! ((int) $budget['id'] === $id && (int) ($budget['user_id'] ?? 0) === $userId)
            ));

            return count($data['budgets']) < $before;
        });
    }

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

    private function normalizeBudget(array $budget): array
    {
        return [
            'id' => (int) $budget['id'],
            'user_id' => (int) ($budget['user_id'] ?? 0),
            'amount' => (float) $budget['amount'],
            'start_date' => (string) $budget['start_date'],
            'end_date' => (string) $budget['end_date'],
            'account_id' => (int) $budget['account_id'],
            'created_at' => $budget['created_at'] ?? null,
            'updated_at' => $budget['updated_at'] ?? null,
        ];
    }
}
