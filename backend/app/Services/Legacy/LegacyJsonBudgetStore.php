<?php

namespace App\Services\Legacy;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\UsesJsonStorePath;

class LegacyJsonBudgetStore
{
    use ManagesJsonFileStore;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('budgets.json');
    }

    /**
     * @param  array<string, mixed>  $row
     */
    public function upsertFromStoreArray(array $row): void
    {
        $this->mutateStore(function (array &$data) use ($row): void {
            $normalized = $this->normalize($row);
            $id = (int) $normalized['id'];
            $found = false;

            foreach ($data['budgets'] as $idx => $budget) {
                if ((int) $budget['id'] === $id) {
                    $data['budgets'][$idx] = $normalized;
                    $found = true;
                    break;
                }
            }

            if (! $found) {
                $data['budgets'][] = $normalized;
            }

            $data['next_budget_id'] = max((int) $data['next_budget_id'], $id + 1);
        });
    }

    public function deleteById(int $id, int $userId): void
    {
        $this->mutateStore(function (array &$data) use ($id, $userId): void {
            $data['budgets'] = array_values(array_filter(
                $data['budgets'],
                fn (array $budget): bool => ! ((int) $budget['id'] === $id && (int) ($budget['user_id'] ?? 0) === $userId)
            ));
        });
    }

    /** @return array<string, mixed> */
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

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    private function normalize(array $row): array
    {
        return [
            'id' => (int) $row['id'],
            'user_id' => (int) ($row['user_id'] ?? 0),
            'amount' => (float) $row['amount'],
            'start_date' => (string) $row['start_date'],
            'end_date' => (string) $row['end_date'],
            'account_id' => (int) $row['account_id'],
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }
}
