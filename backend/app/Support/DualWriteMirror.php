<?php

namespace App\Support;

use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Mirrors Eloquent writes to legacy JSON stores during the migration safety window.
 * Failures are logged only — the primary database write is never rolled back.
 */
final class DualWriteMirror
{
    public static function enabled(): bool
    {
        if (! config('mudabbir.dual_write_json', false)) {
            return false;
        }

        $until = config('mudabbir.dual_write_json_until');
        if (is_string($until) && $until !== '' && now()->greaterThan($until)) {
            return false;
        }

        return true;
    }

    /**
     * @param  callable(): void  $legacyWrite
     */
    public static function mirror(string $entity, callable $legacyWrite): void
    {
        if (! self::enabled()) {
            return;
        }

        try {
            $legacyWrite();
        } catch (Throwable $e) {
            Log::warning('Dual-write JSON mirror failed', [
                'entity' => $entity,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
