<?php

namespace App\Support;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

final class ResolvesModelPrimaryKey
{
    /**
     * Tables use manual integer PKs (legacy JSON ids). SQLite tests and PostgreSQL
     * production both assign the next id in PHP; the optional sequences migration
     * is a safety net when inserts omit id and the column default is configured.
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
        if (in_array($driver, ['sqlite', 'pgsql'], true)) {
            $attributes['id'] = ((int) $modelClass::query()->max('id')) + 1;
        }

        return $attributes;
    }
}
