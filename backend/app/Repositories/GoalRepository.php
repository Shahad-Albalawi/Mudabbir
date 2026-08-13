<?php

namespace App\Repositories;

use App\Models\Goal;
use App\Models\GoalContribution;
use App\Models\GoalMilestone;
use App\Services\Concerns\ResolvesSyncConflicts;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class GoalRepository
{
    use ResolvesSyncConflicts;

    /**
     * @return list<array<string, mixed>>
     */
    public function all(int $userId): array
    {
        return Goal::query()
            ->forUser($userId)
            ->with(['contributions', 'milestones'])
            ->orderByDesc('id')
            ->get()
            ->map(fn (Goal $goal): array => $goal->toStoreArray())
            ->all();
    }

    /**
     * @return array<string, mixed>|null
     */
    public function find(int $id, int $userId): ?array
    {
        $goal = Goal::query()
            ->forUser($userId)
            ->with(['contributions', 'milestones'])
            ->whereKey($id)
            ->first();

        return $goal?->toStoreArray();
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    public function create(array $payload, int $userId): array
    {
        return DB::transaction(function () use ($payload, $userId): array {
            $id = $this->nextGoalId();
            $current = (float) ($payload['current_amount'] ?? 0);
            $target = (float) $payload['target'];
            $reached = $current >= $target && $target > 0;
            $now = Carbon::now();

            $goal = Goal::query()->create([
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
                'completed_at' => $reached ? $now : null,
            ]);

            if ($current > 0) {
                GoalContribution::query()->create([
                    'id' => $this->nextContributionId(),
                    'goal_id' => $goal->id,
                    'amount' => min($current, $target),
                    'contributed_at' => $now,
                    'note' => null,
                ]);
            }

            return $goal->fresh(['contributions', 'milestones'])->toStoreArray();
        });
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array{conflict: bool, data: array}|null
     */
    public function update(int $id, array $updates, int $userId, ?string $clientUpdatedAt = null): ?array
    {
        $goal = Goal::query()
            ->forUser($userId)
            ->with(['contributions', 'milestones'])
            ->whereKey($id)
            ->first();

        if ($goal === null) {
            return null;
        }

        $existing = $goal->toStoreArray();
        $conflict = $this->resolveUpdateConflict($existing, $clientUpdatedAt, fn (array $row): array => $row);
        if ($conflict !== null) {
            return $conflict;
        }

        $goal->fill($this->filterUpdatable($updates));
        $target = (float) $goal->target;
        $current = min((float) $goal->current_amount, $target);
        $reached = $current >= $target && $target > 0;

        $goal->target = $target;
        $goal->current_amount = $current;
        $goal->is_completed = $reached;
        $goal->completed_at = $reached ? ($goal->completed_at ?? Carbon::now()) : null;
        $goal->save();

        $this->applyMilestoneProgress($goal);

        return [
            'conflict' => false,
            'data' => $goal->fresh(['contributions', 'milestones'])->toStoreArray(),
        ];
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>|null
     */
    public function addContribution(int $goalId, array $payload, int $userId): ?array
    {
        return DB::transaction(function () use ($goalId, $payload, $userId): ?array {
            $goal = Goal::query()->forUser($userId)->whereKey($goalId)->lockForUpdate()->first();
            if ($goal === null || $goal->is_completed) {
                return null;
            }

            $amount = (float) $payload['amount'];
            $remaining = max(0.0, (float) $goal->target - (float) $goal->current_amount);
            $applied = min($amount, $remaining);
            if ($applied <= 0) {
                return $goal->fresh(['contributions', 'milestones'])->toStoreArray();
            }

            GoalContribution::query()->create([
                'id' => $this->nextContributionId(),
                'goal_id' => $goal->id,
                'amount' => $applied,
                'contributed_at' => Carbon::now(),
                'note' => $payload['note'] ?? null,
            ]);

            $newAmount = min((float) $goal->current_amount + $applied, (float) $goal->target);
            $reached = $newAmount >= (float) $goal->target;

            $goal->update([
                'current_amount' => $newAmount,
                'is_completed' => $reached,
                'completed_at' => $reached ? Carbon::now() : null,
            ]);

            $this->applyMilestoneProgress($goal->fresh());

            return $goal->fresh(['contributions', 'milestones'])->toStoreArray();
        });
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>|null
     */
    public function addMilestone(int $goalId, array $payload, int $userId): ?array
    {
        $goal = Goal::query()->forUser($userId)->whereKey($goalId)->first();
        if ($goal === null) {
            return null;
        }

        $targetAmount = (float) $payload['target_amount'];
        $currentAmount = (float) $goal->current_amount;
        $achieved = $currentAmount >= $targetAmount;

        GoalMilestone::query()->create([
            'id' => $this->nextMilestoneId(),
            'goal_id' => $goal->id,
            'title' => (string) $payload['title'],
            'target_amount' => $targetAmount,
            'is_achieved' => $achieved,
            'achieved_at' => $achieved ? Carbon::now() : null,
        ]);

        return $goal->fresh(['contributions', 'milestones'])->toStoreArray();
    }

    public function delete(int $id, int $userId): bool
    {
        return Goal::query()->forUser($userId)->whereKey($id)->delete() > 0;
    }

    private function applyMilestoneProgress(Goal $goal): void
    {
        $goal->load('milestones');
        $current = (float) $goal->current_amount;
        foreach ($goal->milestones as $milestone) {
            if ($milestone->is_achieved) {
                continue;
            }
            if ($current >= (float) $milestone->target_amount) {
                $milestone->update([
                    'is_achieved' => true,
                    'achieved_at' => Carbon::now(),
                ]);
            }
        }
    }

    /**
     * @param  array<string, mixed>  $updates
     * @return array<string, mixed>
     */
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

    private function nextGoalId(): int
    {
        return ((int) Goal::query()->max('id')) + 1;
    }

    private function nextContributionId(): int
    {
        return ((int) GoalContribution::query()->max('id')) + 1;
    }

    private function nextMilestoneId(): int
    {
        return ((int) GoalMilestone::query()->max('id')) + 1;
    }
}
