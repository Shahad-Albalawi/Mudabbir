<?php

namespace App\Console\Commands;

use App\Models\Expense;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class ImportExpensesFromJson extends Command
{
    protected $signature = 'mudabbir:import-expenses-json
                            {path? : Path to expenses.json (default: storage/app/expenses.json)}';

    protected $description = 'One-time import of legacy expenses.json into the database';

    public function handle(): int
    {
        $path = (string) ($this->argument('path') ?: storage_path('app/expenses.json'));

        if (! File::exists($path)) {
            $this->warn("No JSON file at {$path} — nothing to import.");

            return self::SUCCESS;
        }

        $decoded = json_decode((string) File::get($path), true);
        if (! is_array($decoded) || ! isset($decoded['expenses']) || ! is_array($decoded['expenses'])) {
            $this->error('Invalid expenses.json structure.');

            return self::FAILURE;
        }

        $imported = 0;
        $skipped = 0;

        foreach ($decoded['expenses'] as $row) {
            if (! is_array($row)) {
                continue;
            }

            $id = (int) ($row['id'] ?? 0);
            $userId = (int) ($row['user_id'] ?? 0);

            if ($id <= 0 || $userId <= 0 || ! User::query()->whereKey($userId)->exists()) {
                $skipped++;

                continue;
            }

            $createdAt = isset($row['created_at'])
                ? Carbon::parse((string) $row['created_at'])
                : now();
            $updatedAt = isset($row['updated_at'])
                ? Carbon::parse((string) $row['updated_at'])
                : $createdAt;

            Expense::query()->updateOrCreate(
                ['id' => $id],
                [
                    'user_id' => $userId,
                    'amount' => (float) ($row['amount'] ?? 0),
                    'date' => (string) ($row['date'] ?? now()->toDateString()),
                    'type' => (string) ($row['type'] ?? 'expense'),
                    'notes' => $row['notes'] ?? null,
                    'account_id' => (int) ($row['account_id'] ?? 1),
                    'category_id' => (int) ($row['category_id'] ?? 1),
                    'account_name' => (string) ($row['account_name'] ?? ''),
                    'category_name' => (string) ($row['category_name'] ?? ''),
                    'is_recurring' => (bool) ($row['is_recurring'] ?? false),
                    'recurrence_interval' => $row['recurrence_interval'] ?? null,
                    'synced_at' => now(),
                    'created_at' => $createdAt,
                    'updated_at' => $updatedAt,
                ],
            );

            $imported++;
        }

        $this->info("Imported {$imported} expense(s), skipped {$skipped}.");

        return self::SUCCESS;
    }
}
