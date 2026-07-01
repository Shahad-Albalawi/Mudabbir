<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

/**
 * Per-user dashboard response cache (5 minutes).
 */
class DashboardCache
{
    public const TTL_MINUTES = 5;

    public static function keyForUser(int $userId): string
    {
        return "api:dashboard:user:{$userId}";
    }

    public static function forgetForUser(int $userId): void
    {
        Cache::forget(self::keyForUser($userId));
    }
}
