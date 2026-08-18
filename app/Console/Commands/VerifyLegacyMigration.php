<?php

namespace App\Console\Commands;

use App\Models\Budget;
use App\Models\Challenge;
use App\Models\Expense;
use App\Models\Goal;
use App\Services\Legacy\LegacyMigrationVerifier;
use Illuminate\Console\Command;

class VerifyLegacyMigration extends Command
{
    protected $signature = 'mudabbir:verify-legacy-migration
                            {--expenses= : Path to expenses.json}
                            {--goals= : Path to goals.json}
                            {--budgets= : Path to budgets.json}
                            {--challenges= : Path to challenges.json}
                            {--all : Verify all default JSON files}
                            {--sample-percent=10 : Random sample size percent}';

    protected $description = 'Verify legacy JSON row counts and sampled field parity against the database';

    public function handle(LegacyMigrationVerifier $verifier): int
    {
        $samplePercent = max(1, min(100, (int) $this->option('sample-percent')));
        $verifyAll = (bool) $this->option('all');
        $failed = false;

        $checks = [
            'expenses' => $this->option('expenses') ?: storage_path('app/expenses.json'),
            'goals' => $this->option('goals') ?: storage_path('app/goals.json'),
            'budgets' => $this->option('budgets') ?: storage_path('app/budgets.json'),
            'challenges' => $this->option('challenges') ?: storage_path('app/challenges.json'),
        ];

        if (! $verifyAll && ! $this->hasExplicitOption()) {
            $verifyAll = true;
        }

        if ($verifyAll || $this->option('expenses') !== null) {
            $failed = $this->verifyExpenses($verifier, (string) $checks['expenses'], $samplePercent) || $failed;
        }

        if ($verifyAll || $this->option('goals') !== null) {
            $failed = $this->verifyGoals($verifier, (string) $checks['goals'], $samplePercent) || $failed;
        }

        if ($verifyAll || $this->option('budgets') !== null) {
            $failed = $this->verifyBudgets($verifier, (string) $checks['budgets'], $samplePercent) || $failed;
        }

        if ($verifyAll || $this->option('challenges') !== null) {
            $failed = $this->verifyChallenges($verifier, (string) $checks['challenges'], $samplePercent) || $failed;
        }

        if ($failed) {
            $this->error('Legacy migration verification failed.');

            return self::FAILURE;
        }

        $this->info('Legacy migration verification passed.');

        return self::SUCCESS;
    }

    private function hasExplicitOption(): bool
    {
        return $this->option('expenses') !== null
            || $this->option('goals') !== null
            || $this->option('budgets') !== null
            || $this->option('challenges') !== null;
    }

    private function verifyExpenses(LegacyMigrationVerifier $verifier, string $path, int $samplePercent): bool
    {
        if (! is_file($path)) {
            $this->warn("Skipping expenses — no file at {$path}");

            return false;
        }

        $result = $verifier->verify(
            'expenses',
            fn (): array => LegacyMigrationVerifier::rowsFromJsonFile($path, 'expenses'),
            fn (array $ids): array => Expense::query()
                ->whereIn('id', $ids)
                ->get()
                ->mapWithKeys(fn (Expense $row): array => [$row->id => $row->toStoreArray()])
                ->all(),
            fn (): array => Expense::query()->pluck('id')->map(fn ($id): int => (int) $id)->all(),
            ['user_id', 'amount', 'date', 'type', 'notes', 'account_id', 'category_id', 'account_name', 'category_name', 'is_recurring', 'recurrence_interval'],
            $samplePercent,
        );

        return $this->report('Expenses', $result);
    }

    private function verifyGoals(LegacyMigrationVerifier $verifier, string $path, int $samplePercent): bool
    {
        if (! is_file($path)) {
            $this->warn("Skipping goals — no file at {$path}");

            return false;
        }

        $result = $verifier->verify(
            'goals',
            fn (): array => LegacyMigrationVerifier::rowsFromJsonFile($path, 'goals'),
            fn (array $ids): array => Goal::query()
                ->with(['contributions', 'milestones'])
                ->whereIn('id', $ids)
                ->get()
                ->mapWithKeys(fn (Goal $row): array => [$row->id => $row->toStoreArray()])
                ->all(),
            fn (): array => Goal::query()->pluck('id')->map(fn ($id): int => (int) $id)->all(),
            ['user_id', 'name', 'target', 'current_amount', 'type', 'start_date', 'end_date', 'is_completed'],
            $samplePercent,
            function (array $json, array $db, int $id): ?string {
                $jsonContrib = count($json['contributions'] ?? []);
                $dbContrib = count($db['contributions'] ?? []);
                if ($jsonContrib !== $dbContrib) {
                    return "goals id={$id} contributions count: JSON={$jsonContrib} DB={$dbContrib}";
                }

                $jsonMilestones = count($json['milestones'] ?? []);
                $dbMilestones = count($db['milestones'] ?? []);
                if ($jsonMilestones !== $dbMilestones) {
                    return "goals id={$id} milestones count: JSON={$jsonMilestones} DB={$dbMilestones}";
                }

                return null;
            },
        );

        return $this->report('Goals', $result);
    }

    private function verifyBudgets(LegacyMigrationVerifier $verifier, string $path, int $samplePercent): bool
    {
        if (! is_file($path)) {
            $this->warn("Skipping budgets — no file at {$path}");

            return false;
        }

        $result = $verifier->verify(
            'budgets',
            fn (): array => LegacyMigrationVerifier::rowsFromJsonFile($path, 'budgets'),
            fn (array $ids): array => Budget::query()
                ->whereIn('id', $ids)
                ->get()
                ->mapWithKeys(fn (Budget $row): array => [$row->id => $row->toStoreArray()])
                ->all(),
            fn (): array => Budget::query()->pluck('id')->map(fn ($id): int => (int) $id)->all(),
            ['user_id', 'amount', 'start_date', 'end_date', 'account_id'],
            $samplePercent,
        );

        return $this->report('Budgets', $result);
    }

    private function verifyChallenges(LegacyMigrationVerifier $verifier, string $path, int $samplePercent): bool
    {
        if (! is_file($path)) {
            $this->warn("Skipping challenges — no file at {$path}");

            return false;
        }

        $result = $verifier->verify(
            'challenges',
            fn (): array => LegacyMigrationVerifier::rowsFromJsonFile($path, 'challenges'),
            fn (array $ids): array => Challenge::query()
                ->with('participants')
                ->whereIn('id', $ids)
                ->get()
                ->mapWithKeys(fn (Challenge $row): array => [$row->id => $row->toStoreArray()])
                ->all(),
            fn (): array => Challenge::query()->pluck('id')->map(fn ($id): int => (int) $id)->all(),
            ['user_id', 'name', 'amount', 'start_date', 'end_date', 'achieved', 'creator_id'],
            $samplePercent,
            function (array $json, array $db, int $id): ?string {
                $jsonParticipants = count($json['participants'] ?? []);
                $dbParticipants = count($db['participants'] ?? []);
                if ($jsonParticipants !== $dbParticipants) {
                    return "challenges id={$id} participants count: JSON={$jsonParticipants} DB={$dbParticipants}";
                }

                return null;
            },
        );

        return $this->report('Challenges', $result);
    }

    /**
     * @param  array{ok: bool, json_count: int, db_count: int, sampled: int, mismatches: list<string>, orphans: list<int>}  $result
     */
    private function report(string $label, array $result): bool
    {
        $this->line(sprintf(
            '%s: JSON=%d DB=%d sampled=%d %s',
            $label,
            $result['json_count'],
            $result['db_count'],
            $result['sampled'],
            $result['ok'] ? 'OK' : 'FAIL',
        ));

        foreach ($result['mismatches'] as $message) {
            $this->error('  '.$message);
        }

        return ! $result['ok'];
    }
}
