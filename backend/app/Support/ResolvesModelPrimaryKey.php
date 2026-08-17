<?php

namespace App\Support;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

final class ResolvesModelPrimaryKey
{
    /**
     * SQLite tests use manual integer PKs; PostgreSQL uses DB sequences after migration.
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

        if (Schema::getConnection()->getDriverName() === 'sqlite') {
            $attributes['id'] = ((int) $modelClass::query()->max('id')) + 1;
        }

        return $attributes;
    }
}
