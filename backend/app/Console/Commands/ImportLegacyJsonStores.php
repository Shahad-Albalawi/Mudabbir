<?php

namespace App\Console\Commands;

use App\Models\Budget;
use App\Models\Challenge;
use App\Models\ChallengeParticipant;
use App\Models\Goal;
use App\Models\GoalContribution;
use App\Models\GoalMilestone;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ImportLegacyJsonStores extends Command
{
    protected $signature = 'mudabbir:import-legacy-json
                            {--expenses= : Path to expenses.json}
                            {--goals= : Path to goals.json}
                            {--budgets= : Path to budgets.json}
                            {--challenges= : Path to challenges.json}';

    protected $description = 'One-time import of legacy JSON store files into the database';

    public function handle(): int
    {
        $this->call('mudabbir:import-expenses-json', [
            'path' => $this->option('expenses') ?: storage_path('app/expenses.json'),
        ]);

        $this->importGoals((string) ($this->option('goals') ?: storage_path('app/goals.json')));
        $this->importBudgets((string) ($this->option('budgets') ?: storage_path('app/budgets.json')));

        try {
            $this->importChallenges((string) ($this->option('challenges') ?: storage_path('app/challenges.json')));
        } catch (\Throwable $e) {
            $this->warn('Challenge import skipped: '.$e->getMessage());
        }

        $this->info('Legacy JSON import finished.');

        return self::SUCCESS;
    }

    private function userExists(int $userId): bool
    {
        return $userId > 0 && User::query()->whereKey($userId)->exists();
    }

    private function importGoals(string $path): void
    {
        if (! File::exists($path)) {
            $this->warn("No goals file at {$path}");

            return;
        }

        $decoded = json_decode((string) File::get($path), true);
        if (! is_array($decoded['goals'] ?? null)) {
            $this->error('Invalid goals.json');

            return;
        }

        $count = 0;
        $skipped = 0;
        foreach ($decoded['goals'] as $row) {
            if (! is_array($row)) {
                continue;
            }

            $userId = (int) ($row['user_id'] ?? 0);
            if (! $this->userExists($userId)) {
                $skipped++;

                continue;
            }

            $goal = Goal::query()->updateOrCreate(
                ['id' => (int) $row['id']],
                [
                    'user_id' => (int) $row['user_id'],
                    'name' => (string) $row['name'],
                    'target' => (float) $row['target'],
                    'current_amount' => (float) ($row['current_amount'] ?? 0),
                    'type' => (string) ($row['type'] ?? 'Saving'),
                    'start_date' => (string) $row['start_date'],
                    'end_date' => (string) $row['end_date'],
                    'image_path' => $row['image_path'] ?? null,
                    'is_completed' => (bool) ($row['is_completed'] ?? false),
                    'completed_at' => isset($row['completed_at']) ? Carbon::parse($row['completed_at']) : null,
                ],
            );

            foreach ($row['contributions'] ?? [] as $contrib) {
                if (! is_array($contrib)) {
                    continue;
                }
                GoalContribution::query()->updateOrCreate(
                    ['id' => (int) $contrib['id']],
                    [
                        'goal_id' => $goal->id,
                        'amount' => (float) $contrib['amount'],
                        'contributed_at' => Carbon::parse((string) $contrib['contributed_at']),
                        'note' => $contrib['note'] ?? null,
                    ],
                );
            }

            foreach ($row['milestones'] ?? [] as $milestone) {
                if (! is_array($milestone)) {
                    continue;
                }
                GoalMilestone::query()->updateOrCreate(
                    ['id' => (int) $milestone['id']],
                    [
                        'goal_id' => $goal->id,
                        'title' => (string) $milestone['title'],
                        'target_amount' => (float) $milestone['target_amount'],
                        'is_achieved' => (bool) ($milestone['is_achieved'] ?? false),
                        'achieved_at' => isset($milestone['achieved_at']) ? Carbon::parse($milestone['achieved_at']) : null,
                    ],
                );
            }

            $count++;
        }

        $this->info("Imported {$count} goal(s)".($skipped > 0 ? ", skipped {$skipped} (missing user)" : '').'.');
    }

    private function importBudgets(string $path): void
    {
        if (! File::exists($path)) {
            $this->warn("No budgets file at {$path}");

            return;
        }

        $decoded = json_decode((string) File::get($path), true);
        if (! is_array($decoded['budgets'] ?? null)) {
            $this->error('Invalid budgets.json');

            return;
        }

        $count = 0;
        $skipped = 0;
        foreach ($decoded['budgets'] as $row) {
            if (! is_array($row)) {
                continue;
            }

            $userId = (int) ($row['user_id'] ?? 0);
            if (! $this->userExists($userId)) {
                $skipped++;

                continue;
            }

            Budget::query()->updateOrCreate(
                ['id' => (int) $row['id']],
                [
                    'user_id' => (int) $row['user_id'],
                    'amount' => (float) $row['amount'],
                    'start_date' => (string) $row['start_date'],
                    'end_date' => (string) $row['end_date'],
                    'account_id' => (int) $row['account_id'],
                ],
            );
            $count++;
        }

        $this->info("Imported {$count} budget(s)".($skipped > 0 ? ", skipped {$skipped} (missing user)" : '').'.');
    }

    private function importChallenges(string $path): void
    {
        if (! File::exists($path)) {
            $this->warn("No challenges file at {$path}");

            return;
        }

        $decoded = json_decode((string) File::get($path), true);
        if (! is_array($decoded['challenges'] ?? null)) {
            $this->error('Invalid challenges.json');

            return;
        }

        $count = 0;
        $skipped = 0;
        foreach ($decoded['challenges'] as $row) {
            if (! is_array($row)) {
                continue;
            }

            $userId = (int) ($row['user_id'] ?? $row['creator_id'] ?? 0);
            if (! $this->userExists($userId)) {
                $skipped++;

                continue;
            }

            $creator = $row['creator'] ?? [];
            $challenge = Challenge::query()->updateOrCreate(
                ['id' => (int) $row['id']],
                [
                    'user_id' => (int) ($row['user_id'] ?? $row['creator_id'] ?? 0),
                    'creator_id' => (int) ($row['creator_id'] ?? $row['user_id'] ?? 0),
                    'creator_name' => (string) ($creator['name'] ?? ''),
                    'creator_email' => (string) ($creator['email'] ?? ''),
                    'name' => (string) $row['name'],
                    'amount' => (float) ($row['amount'] ?? 0),
                    'start_date' => (string) $row['start_date'],
                    'end_date' => (string) $row['end_date'],
                    'achieved' => (bool) ($row['achieved'] ?? false),
                ],
            );

            ChallengeParticipant::query()->where('challenge_id', $challenge->id)->delete();

            foreach ($row['participants'] ?? [] as $participant) {
                if (! is_array($participant)) {
                    continue;
                }

                ChallengeParticipant::query()->create([
                    'challenge_id' => $challenge->id,
                    'participant_id' => (int) $participant['id'],
                    'name' => (string) $participant['name'],
                    'email' => (string) $participant['email'],
                    'status' => (string) ($participant['status'] ?? 'pending'),
                    'target_amount' => $participant['target_amount'] ?? null,
                    'achieved' => (bool) ($participant['achieved'] ?? false),
                    'current_progress' => (float) ($participant['current_progress'] ?? 0),
                    'streak_days' => (int) ($participant['streak_days'] ?? 0),
                    'longest_streak' => (int) ($participant['longest_streak'] ?? 0),
                    'last_check_in' => $participant['last_check_in'] ?? null,
                    'badges' => $participant['badges'] ?? [],
                ]);
            }

            $count++;
        }

        $this->info("Imported {$count} challenge(s)".($skipped > 0 ? ", skipped {$skipped} (missing user)" : '').'.');
    }
}
