<?php

namespace App\Http\Controllers\Concerns;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;

trait AuthorizesResourceAccess
{
    protected function canAccess(Request $request, string $ability, Model $model): bool
    {
        $user = $request->user();

        return $user !== null && $user->can($ability, $model);
    }
}
