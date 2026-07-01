<?php

namespace App\Services;

use App\Services\Concerns\ManagesJsonFileStore;
use App\Services\Concerns\ResolvesSyncConflicts;
use App\Services\Concerns\UsesJsonStorePath;
use Carbon\Carbon;

class GoalStore
{
    use ManagesJsonFileStore;
    use ResolvesSyncConflicts;
    use UsesJsonStorePath;

    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = $this->jsonStorePath('goals.json');
    }

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

    public function all(int $userId): array
    {
        $data = $this->mutateStore(fn (array $data): array => $data);

        $owned = array_values(array_filter(
            $data['goals'],
            fn (array $goal): bool => (int) ($goal['user_id'] ?? 0) === $userId
        ));

        return array_values(array_map(
            fn (array $goal): array => $this->normalizeGoal($goal),
            $owned
        ));
    }

    public function find(int $id, int $userId): ?array
    {
        return $this->mutateStore(function (array $data) use ($id, $userId): ?array {
            foreach ($data['goals'] as $goal) {
                if ((int) $goal['id'] === $id && (int) ($goal['user_id'] ?? 0) === $userId) {
                    return $this->normalizeGoal($goal);
                }
            }

            return null;
        });
    }

    public function create(array $payload, int $userId): array
    {
        return $this->mutateStore(function (array &$data) use ($payload, $userId): array {
            $id = (int) $data['next_goal_id'];
            $data['next_goal_id'] = $id + 1;

            $current = (float) ($payload['current_amount'] ?? 0);
            $target = (float) $payload['target'];
            $reached = $current >= $target;
            $now = Carbon::now();

            $contributions = [];
            if ($current > 0) {
                $contribId = (int) $data['next_contribution_id'];
                $data['next_contribution_id'] = $contribId + 1;
                $contributions[] = [
                    'id' => $contribId,
                    'goal_id' => $id,
                    'amount' => $current,
                    'contributed_at' => $now->toISOString(),
                    'note' => null,
                ];
            }

            $goal = $this->normalizeGoal([
                'id' => $id,
                'user_id' => $userId,
                'name' => (string) $payload['name'],
                'target' => $target,
                'current_amount' => min($current, $target),
                'type' => (string) ($payload['type'] ?? 'Saving'),
                'start_date' => (string) $payload['start_date'],
                'end_date' => (string) $payload['end_date'],
                'image_path' => $payload['image_path'] ?? null,
                'is_completed' => $reached,
                'completed_at' => $reached ? $now->toISOString() : null,
                'contributions' => $contributions,
                'milestones' => [],
                'created_at' => $now->toISOString(),
                'updated_at' => $now->toISOString(),
            ]);

            $data['goals'][] = $goal;

            return $goal;
        });
    }

    /**
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        return $this->mutateStore(function (array &$data) use ($id, $updates, $userId, $clientUpdatedAt): ?array {
            foreach ($data['goals'] as $idx => $goal) {
                if ((int) $goal['id'] !== $id || (int) ($goal['user_id'] ?? 0) !== $userId) {
                    continue;
                }

                $conflict = $this->resolveUpdateConflict(
                    $goal,
                    $clientUpdatedAt,
                    fn (array $row): array => $this->normalizeGoal($row)
                );
                if ($conflict !== null) {
                    return $conflict;
                }

                $merged = array_merge($goal, $this->filterUpdatable($updates));
                $target = (float) $merged['target'];
                $current = min((float) $merged['current_amount'], $target);
                $reached = $current >= $target && $target > 0;

                $merged['target'] = $target;
                $merged['current_amount'] = $current;
                $merged['is_completed'] = $reached;
                $merged['completed_at'] = $reached
                    ? ($goal['completed_at'] ?? Carbon::now()->toISOString())
                    : null;
                $merged['updated_at'] = Carbon::now()->toISOString();
                $merged = $this->applyMilestoneProgress($merged);

                $data['goals'][$idx] = $this->normalizeGoal($merged);

                return [
                    'conflict' => false,
                    'data' => $data['goals'][$idx],
                ];
            }

            return null;
        });
    }

    public function addContribution(int $goalId, array $payload, int $userId): ?array
    {
        return $this->mutateStore(function (array &$data) use ($goalId, $payload, $userId): ?array {
            foreach ($data['goals'] as $idx => $goal) {
                if ((int) $goal['id'] !== $goalId || (int) ($goal['user_id'] ?? 0) !== $userId) {
                    continue;
                }

                if (! empty($goal['is_completed'])) {
                    return null;
                }

                $amount = (float) $payload['amount'];
                $remaining = max(0.0, (float) $goal['target'] - (float) $goal['current_amount']);
                $applied = min($amount, $remaining);
                if ($applied <= 0) {
                    return $this->normalizeGoal($goal);
                }

                $contribId = (int) $data['next_contribution_id'];
                $data['next_contribution_id'] = $contribId + 1;

                $contributions = $goal['contributions'] ?? [];
                $contributions[] = [
                    'id' => $contribId,
                    'goal_id' => $goalId,
                    'amount' => $applied,
                    'contributed_at' => Carbon::now()->toISOString(),
                    'note' => $payload['note'] ?? null,
                ];

                $newAmount = min(
                    (float) $goal['current_amount'] + $applied,
                    (float) $goal['target']
                );
                $reached = $newAmount >= (float) $goal['target'];

                $goal['contributions'] = $contributions;
                $goal['current_amount'] = $newAmount;
                $goal['is_completed'] = $reached;
                $goal['completed_at'] = $reached ? Carbon::now()->toISOString() : null;
                $goal['updated_at'] = Carbon::now()->toISOString();
                $goal = $this->applyMilestoneProgress($goal);

                $data['goals'][$idx] = $this->normalizeGoal($goal);

                return $data['goals'][$idx];
            }

            return null;
        });
    }

    public function addMilestone(int $goalId, array $payload, int $userId): ?array
    {
        return $this->mutateStore(function (array &$data) use ($goalId, $payload, $userId): ?array {
            foreach ($data['goals'] as $idx => $goal) {
                if ((int) $goal['id'] !== $goalId || (int) ($goal['user_id'] ?? 0) !== $userId) {
                    continue;
                }

                $milestoneId = (int) $data['next_milestone_id'];
                $data['next_milestone_id'] = $milestoneId + 1;

                $targetAmount = (float) $payload['target_amount'];
                $currentAmount = (float) ($goal['current_amount'] ?? 0);
                $milestones = $goal['milestones'] ?? [];
                $milestones[] = [
                    'id' => $milestoneId,
                    'goal_id' => $goalId,
                    'title' => (string) $payload['title'],
                    'target_amount' => $targetAmount,
                    'is_achieved' => $currentAmount >= $targetAmount,
                    'achieved_at' => $currentAmount >= $targetAmount
                        ? Carbon::now()->toISOString()
                        : null,
                    'created_at' => Carbon::now()->toISOString(),
                ];

                $goal['milestones'] = $milestones;
                $goal['updated_at'] = Carbon::now()->toISOString();
                $data['goals'][$idx] = $this->normalizeGoal($goal);

                return $data['goals'][$idx];
            }

            return null;
        });
    }

    /**
     * @param  array<string, mixed>  $goal
     * @return array<string, mixed>
     */
    private function applyMilestoneProgress(array $goal): array
    {
        $current = (float) ($goal['current_amount'] ?? 0);
        $milestones = $goal['milestones'] ?? [];
        foreach ($milestones as $i => $milestone) {
            if (! empty($milestone['is_achieved'])) {
                continue;
            }
            if ($current >= (float) ($milestone['target_amount'] ?? 0)) {
                $milestones[$i]['is_achieved'] = true;
                $milestones[$i]['achieved_at'] = Carbon::now()->toISOString();
            }
        }
        $goal['milestones'] = $milestones;

        return $goal;
    }

    public function delete(int $id, int $userId): bool
    {
        return $this->mutateStore(function (array &$data) use ($id, $userId): bool {
            $before = count($data['goals']);
            $data['goals'] = array_values(array_filter(
                $data['goals'],
                fn (array $goal): bool => ! ((int) $goal['id'] === $id && (int) ($goal['user_id'] ?? 0) === $userId)
            ));

            return count($data['goals']) < $before;
        });
    }

    private function filterUpdatable(array $updates): array
    {
        $allowed = ['name', 'target', 'type', 'start_date', 'end_date', 'image_path'];
        $filtered = [];
        foreach ($allowed as $key) {
            if (array_key_exists($key, $updates)) {
                $filtered[$key] = $updates[$key];
            }
        }

        return $filtered;
    }

    private function normalizeGoal(array $goal): array
    {
        $contributions = [];
        foreach ($goal['contributions'] ?? [] as $contrib) {
            $contributions[] = [
                'id' => (int) $contrib['id'],
                'goal_id' => (int) $contrib['goal_id'],
                'amount' => (float) $contrib['amount'],
                'contributed_at' => (string) $contrib['contributed_at'],
                'note' => $contrib['note'] ?? null,
            ];
        }

        $milestones = [];
        foreach ($goal['milestones'] ?? [] as $milestone) {
            $milestones[] = [
                'id' => (int) $milestone['id'],
                'goal_id' => (int) $milestone['goal_id'],
                'title' => (string) $milestone['title'],
                'target_amount' => (float) $milestone['target_amount'],
                'is_achieved' => (bool) ($milestone['is_achieved'] ?? false),
                'achieved_at' => $milestone['achieved_at'] ?? null,
                'created_at' => $milestone['created_at'] ?? null,
            ];
        }

        return [
            'id' => (int) $goal['id'],
            'user_id' => (int) ($goal['user_id'] ?? 0),
            'name' => (string) $goal['name'],
            'target' => (float) $goal['target'],
            'current_amount' => (float) ($goal['current_amount'] ?? 0),
            'type' => (string) ($goal['type'] ?? 'Saving'),
            'start_date' => (string) $goal['start_date'],
            'end_date' => (string) $goal['end_date'],
            'image_path' => $goal['image_path'] ?? null,
            'is_completed' => (bool) ($goal['is_completed'] ?? false),
            'completed_at' => $goal['completed_at'] ?? null,
            'contributions' => $contributions,
            'milestones' => $milestones,
            'created_at' => $goal['created_at'] ?? null,
            'updated_at' => $goal['updated_at'] ?? null,
        ];
    }
}
