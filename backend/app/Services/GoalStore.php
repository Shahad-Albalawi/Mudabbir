<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\File;

class GoalStore
{
    /** @var string */
    private $path;

    public function __construct()
    {
        $this->path = storage_path('app/goals.json');
    }

    public function all(): array
    {
        $data = $this->read();

        return array_values(array_map(function (array $goal): array {
            return $this->normalizeGoal($goal);
        }, $data['goals']));
    }

    public function find(int $id): ?array
    {
        $data = $this->read();
        foreach ($data['goals'] as $goal) {
            if ((int) $goal['id'] === $id) {
                return $this->normalizeGoal($goal);
            }
        }

        return null;
    }

    public function create(array $payload): array
    {
        $data = $this->read();
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
            'created_at' => $now->toISOString(),
            'updated_at' => $now->toISOString(),
        ]);

        $data['goals'][] = $goal;
        $this->write($data);

        return $goal;
    }

    public function addContribution(int $goalId, array $payload): ?array
    {
        $data = $this->read();
        foreach ($data['goals'] as $idx => $goal) {
            if ((int) $goal['id'] !== $goalId) {
                continue;
            }

            if (! empty($goal['is_completed'])) {
                return null;
            }

            $amount = (float) $payload['amount'];
            $contribId = (int) $data['next_contribution_id'];
            $data['next_contribution_id'] = $contribId + 1;

            $contributions = $goal['contributions'] ?? [];
            $contributions[] = [
                'id' => $contribId,
                'goal_id' => $goalId,
                'amount' => $amount,
                'contributed_at' => Carbon::now()->toISOString(),
                'note' => $payload['note'] ?? null,
            ];

            $newAmount = min(
                (float) $goal['current_amount'] + $amount,
                (float) $goal['target']
            );
            $reached = $newAmount >= (float) $goal['target'];

            $goal['contributions'] = $contributions;
            $goal['current_amount'] = $newAmount;
            $goal['is_completed'] = $reached;
            $goal['completed_at'] = $reached ? Carbon::now()->toISOString() : null;
            $goal['updated_at'] = Carbon::now()->toISOString();

            $data['goals'][$idx] = $this->normalizeGoal($goal);
            $this->write($data);

            return $data['goals'][$idx];
        }

        return null;
    }

    public function delete(int $id): bool
    {
        $data = $this->read();
        $before = count($data['goals']);
        $data['goals'] = array_values(array_filter(
            $data['goals'],
            function (array $goal) use ($id): bool {
                return (int) $goal['id'] !== $id;
            }
        ));

        if (count($data['goals']) === $before) {
            return false;
        }

        $this->write($data);

        return true;
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

        return [
            'id' => (int) $goal['id'],
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
            'created_at' => $goal['created_at'] ?? null,
            'updated_at' => $goal['updated_at'] ?? null,
        ];
    }

    private function read(): array
    {
        if (! File::exists($this->path)) {
            $seed = [
                'next_goal_id' => 1,
                'next_contribution_id' => 1,
                'goals' => [],
            ];
            $this->write($seed);

            return $seed;
        }

        $decoded = json_decode((string) File::get($this->path), true);
        if (! is_array($decoded) || ! isset($decoded['goals'])) {
            return [
                'next_goal_id' => 1,
                'next_contribution_id' => 1,
                'goals' => [],
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
