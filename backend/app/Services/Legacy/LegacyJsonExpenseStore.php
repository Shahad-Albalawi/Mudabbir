<?php

namespace App\Services\Legacy;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\UsesJsonStorePath;

class LegacyJsonExpenseStore
{
    use ManagesJsonFileStore;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('expenses.json');
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

            foreach ($data['expenses'] as $idx => $expense) {
                if ((int) $expense['id'] === $id) {
                    $data['expenses'][$idx] = $normalized;
                    $found = true;
                    break;
                }
            }

            if (! $found) {
                $data['expenses'][] = $normalized;
            }

            $data['next_expense_id'] = max((int) $data['next_expense_id'], $id + 1);
        });
    }

    public function deleteById(int $id, int $userId): void
    {
        $this->mutateStore(function (array &$data) use ($id, $userId): void {
            $data['expenses'] = array_values(array_filter(
                $data['expenses'],
                fn (array $expense): bool => ! ((int) $expense['id'] === $id && (int) ($expense['user_id'] ?? 0) === $userId)
            ));
        });
    }

    /** @return array<string, mixed> */
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
            'date' => (string) $row['date'],
            'type' => (string) ($row['type'] ?? 'expense'),
            'notes' => $row['notes'] ?? null,
            'account_id' => (int) $row['account_id'],
            'category_id' => (int) $row['category_id'],
            'account_name' => (string) ($row['account_name'] ?? ''),
            'category_name' => (string) ($row['category_name'] ?? ''),
            'is_recurring' => (bool) ($row['is_recurring'] ?? false),
            'recurrence_interval' => $row['recurrence_interval'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }
}
