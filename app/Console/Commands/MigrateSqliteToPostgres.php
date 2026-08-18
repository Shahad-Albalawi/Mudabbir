<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Throwable;

class MigrateSqliteToPostgres extends Command
{
    protected $signature = 'mudabbir:migrate-sqlite-to-pgsql
                            {--sqlite= : Path to source SQLite file (Render export)}
                            {--dry-run : Count rows only, do not copy}';

    protected $description = 'Copy all application tables from a SQLite dump into the configured PostgreSQL (Neon) database';

    /**
     * Table copy order respects foreign keys.
     *
     * @var list<array{table: string, key: string|list<string>}>
     */
    private array $tables = [
        ['table' => 'users', 'key' => 'id'],
        ['table' => 'password_resets', 'key' => 'email'],
        ['table' => 'personal_access_tokens', 'key' => 'id'],
        ['table' => 'expenses', 'key' => 'id'],
        ['table' => 'user_notifications', 'key' => 'id'],
        ['table' => 'device_tokens', 'key' => 'id'],
        ['table' => 'goals', 'key' => 'id'],
        ['table' => 'goal_contributions', 'key' => 'id'],
        ['table' => 'goal_milestones', 'key' => 'id'],
        ['table' => 'budgets', 'key' => 'id'],
        ['table' => 'challenges', 'key' => 'id'],
        ['table' => 'challenge_participants', 'key' => 'id'],
        ['table' => 'failed_jobs', 'key' => 'id'],
        ['table' => 'migrations', 'key' => 'id'],
    ];

    public function handle(): int
    {
        $sqlitePath = (string) ($this->option('sqlite') ?: database_path('database.sqlite'));
        if (! is_file($sqlitePath)) {
            $this->error("SQLite file not found: {$sqlitePath}");

            return self::FAILURE;
        }

        if (config('database.default') !== 'pgsql') {
            $this->error('Default DB_CONNECTION must be pgsql (Neon). Set DATABASE_URL first.');

            return self::FAILURE;
        }

        Config::set('database.connections.sqlite_migration', [
            'driver' => 'sqlite',
            'database' => $sqlitePath,
            'prefix' => '',
            'foreign_key_constraints' => true,
        ]);

        try {
            DB::connection('sqlite_migration')->getPdo();
            DB::connection()->getPdo();
        } catch (Throwable $e) {
            $this->error('Connection failed: '.$e->getMessage());

            return self::FAILURE;
        }

        $dryRun = (bool) $this->option('dry-run');
        $this->info('Source SQLite: '.$sqlitePath);
        $this->info('Target: PostgreSQL ('.config('database.connections.pgsql.host', 'DATABASE_URL').')');
        $this->info($dryRun ? 'DRY RUN — no writes.' : 'Copying rows…');

        $total = 0;

        foreach ($this->tables as $spec) {
            $table = $spec['table'];
            $key = $spec['key'];

            if (! Schema::connection('sqlite_migration')->hasTable($table)) {
                $this->warn("Skip {$table} (missing in SQLite)");

                continue;
            }

            if (! Schema::hasTable($table)) {
                $this->error("Target table {$table} missing — run php artisan migrate first.");

                return self::FAILURE;
            }

            $rows = DB::connection('sqlite_migration')->table($table)->get();
            $count = $rows->count();
            $this->line("  {$table}: {$count} row(s)");

            if ($dryRun || $count === 0) {
                $total += $count;

                continue;
            }

            DB::connection()->transaction(function () use ($table, $key, $rows, &$total): void {
                foreach ($rows as $row) {
                    $payload = $this->normalizeRow($table, (array) $row);
                    $this->upsertRow($table, $key, $payload);
                    $total++;
                }
            });
        }

        if (config('database.default') === 'pgsql') {
            $this->fixPostgresSequences();
        }

        $this->info("Done. {$total} row(s) processed.");

        return self::SUCCESS;
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    private function normalizeRow(string $table, array $row): array
    {
        if ($table === 'challenge_participants' && isset($row['badges'])) {
            if (is_string($row['badges'])) {
                $decoded = json_decode($row['badges'], true);
                $row['badges'] = is_array($decoded) ? json_encode($decoded) : '[]';
            } elseif (is_array($row['badges'])) {
                $row['badges'] = json_encode($row['badges']);
            }
        }

        return $row;
    }

    /**
     * @param  string|list<string>  $key
     * @param  array<string, mixed>  $payload
     */
    private function upsertRow(string $table, string|array $key, array $payload): void
    {
        if (is_array($key)) {
            $where = [];
            foreach ($key as $column) {
                $where[$column] = $payload[$column] ?? null;
            }
            DB::table($table)->updateOrInsert($where, $payload);

            return;
        }

        DB::table($table)->updateOrInsert([$key => $payload[$key]], $payload);
    }

    private function fixPostgresSequences(): void
    {
        $sequences = [
            'users' => 'id',
            'personal_access_tokens' => 'id',
            'user_notifications' => 'id',
            'device_tokens' => 'id',
            'failed_jobs' => 'id',
            'migrations' => 'id',
        ];

        foreach ($sequences as $table => $column) {
            if (! Schema::hasTable($table)) {
                continue;
            }

            $max = DB::table($table)->max($column);
            if ($max === null) {
                continue;
            }

            try {
                DB::statement(
                    "SELECT setval(pg_get_serial_sequence('{$table}', '{$column}'), ?)",
                    [(int) $max]
                );
            } catch (Throwable) {
                // Manual-id tables (expenses, goals, …) have no serial sequence.
            }
        }
    }
}
