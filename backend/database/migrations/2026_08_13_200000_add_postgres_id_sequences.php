<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /** @var list<string> */
    private array $tables = [
        'expenses',
        'goals',
        'goal_contributions',
        'goal_milestones',
        'budgets',
        'challenges',
    ];

    public function up(): void
    {
        if (Schema::getConnection()->getDriverName() !== 'pgsql') {
            return;
        }

        foreach ($this->tables as $table) {
            $sequence = "{$table}_id_seq";

            DB::statement("CREATE SEQUENCE IF NOT EXISTS {$sequence}");
            DB::statement(
                "SELECT setval('{$sequence}', COALESCE((SELECT MAX(id) FROM {$table}), 0) + 1, false)"
            );
            DB::statement("ALTER TABLE {$table} ALTER COLUMN id SET DEFAULT nextval('{$sequence}')");
            DB::statement("ALTER SEQUENCE {$sequence} OWNED BY {$table}.id");
        }
    }

    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() !== 'pgsql') {
            return;
        }

        foreach ($this->tables as $table) {
            $sequence = "{$table}_id_seq";
            DB::statement("ALTER TABLE {$table} ALTER COLUMN id DROP DEFAULT");
            DB::statement("DROP SEQUENCE IF EXISTS {$sequence}");
        }
    }
};
