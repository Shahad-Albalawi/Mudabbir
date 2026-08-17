<?php

namespace App\Support;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Throwable;

final class ResolvesModelPrimaryKey
{
    /** @var list<string> */
    private const PGSQL_SEQUENCE_TABLES = [
        'expenses',
        'goals',
        'goal_contributions',
        'goal_milestones',
        'budgets',
        'challenges',
    ];

    /**
     * Legacy JSON ids are manual integers. SQLite tests assign ids in PHP.
     * PostgreSQL uses per-table sequences (migration 2026_08_13_200000) or
     * nextval()/max fallback when sequences are unavailable.
     *
     * @param  class-string<Model>  $modelClass
     * @param  array<string, mixed>  $attributes
     * @return array<string, mixed>
     */
    public static function forCreate(string $modelClass, array $attributes): array
    {
        if (array_key_exists('id', $attributes)) {
            return $attributes;
        }

        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'sqlite') {
            $attributes['id'] = ((int) $modelClass::query()->max('id')) + 1;

            return $attributes;
        }

        if ($driver !== 'pgsql') {
            return $attributes;
        }

        /** @var Model $model */
        $model = new $modelClass();
        $table = $model->getTable();

        if (in_array($table, self::PGSQL_SEQUENCE_TABLES, true)) {
            $nextId = self::nextPostgresId($table);
            if ($nextId !== null) {
                $attributes['id'] = $nextId;

                return $attributes;
            }
        }

        $attributes['id'] = ((int) DB::table($table)->max('id')) + 1;

        return $attributes;
    }

    private static function nextPostgresId(string $table): ?int
    {
        $sequence = "{$table}_id_seq";

        try {
            $row = DB::selectOne("SELECT nextval('{$sequence}') AS id");

            return isset($row->id) ? (int) $row->id : null;
        } catch (Throwable) {
            return null;
        }
    }
}
