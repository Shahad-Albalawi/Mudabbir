<?php

namespace App\Services\Legacy;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\UsesJsonStorePath;

class LegacyJsonGoalStore
{
    use ManagesJsonFileStore;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('goals.json');
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

            foreach ($data['goals'] as $idx => $goal) {
                if ((int) $goal['id'] === $id) {
                    $data['goals'][$idx] = $normalized;
                    $found = true;
                    break;
                }
            }

            if (! $found) {
                $data['goals'][] = $normalized;
            }

            $data['next_goal_id'] = max((int) $data['next_goal_id'], $id + 1);
            $data['next_contribution_id'] = $this->bumpCounter(
                (int) $data['next_contribution_id'],
                $normalized['contributions'] ?? [],
                'id'
            );
            $data['next_milestone_id'] = $this->bumpCounter(
                (int) $data['next_milestone_id'],
                $normalized['milestones'] ?? [],
                'id'
            );
        });
    }

    public function deleteById(int $id, int $userId): void
    {
        $this->mutateStore(function (array &$data) use ($id, $userId): void {
            $data['goals'] = array_values(array_filter(
                $data['goals'],
                fn (array $goal): bool => ! ((int) $goal['id'] === $id && (int) ($goal['user_id'] ?? 0) === $userId)
            ));
        });
    }

    /** @return array<string, mixed> */
    protected function emptyDocument(): array
    {
        return [
            'next_goal_id' => 1,
            'next_contribution_id' => 1,
            'next_milestone_id' => 1,
            'goals' => [],
        ];
    }

    protected function collectionKey(): string
    {
        return 'goals';
    }

    /**
     * @param  list<array<string, mixed>>  $items
     */
    private function bumpCounter(int $current, array $items, string $key): int
    {
        $max = $current;
        foreach ($items as $item) {
            if (isset($item[$key])) {
                $max = max($max, (int) $item[$key] + 1);
            }
        }

        return $max;
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    private function normalize(array $row): array
    {
        $contributions = [];
        foreach ($row['contributions'] ?? [] as $contrib) {
            if (! is_array($contrib)) {
                continue;
            }
            $contributions[] = [
                'id' => (int) $contrib['id'],
                'amount' => (float) $contrib['amount'],
                'contributed_at' => (string) $contrib['contributed_at'],
                'note' => $contrib['note'] ?? null,
            ];
        }

        $milestones = [];
        foreach ($row['milestones'] ?? [] as $milestone) {
            if (! is_array($milestone)) {
                continue;
            }
            $milestones[] = [
                'id' => (int) $milestone['id'],
                'title' => (string) $milestone['title'],
                'target_amount' => (float) $milestone['target_amount'],
                'is_achieved' => (bool) ($milestone['is_achieved'] ?? false),
                'achieved_at' => $milestone['achieved_at'] ?? null,
            ];
        }

        return [
            'id' => (int) $row['id'],
            'user_id' => (int) ($row['user_id'] ?? 0),
            'name' => (string) $row['name'],
            'target' => (float) $row['target'],
            'current_amount' => (float) ($row['current_amount'] ?? 0),
            'type' => (string) ($row['type'] ?? 'Saving'),
            'start_date' => (string) $row['start_date'],
            'end_date' => (string) $row['end_date'],
            'image_path' => $row['image_path'] ?? null,
            'is_completed' => (bool) ($row['is_completed'] ?? false),
            'completed_at' => $row['completed_at'] ?? null,
            'contributions' => $contributions,
            'milestones' => $milestones,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }
}
