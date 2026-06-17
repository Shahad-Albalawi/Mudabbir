<?php

namespace App\Services\Concerns;

use Carbon\Carbon;

trait ResolvesSyncConflicts
{
    /**
     * @return array{conflict: bool, data: array}|null null when record not found
     */
    protected function resolveUpdateConflict(
        array $existing,
        ?string $clientUpdatedAt,
        callable $normalize
    ): ?array {
        if ($clientUpdatedAt !== null && $clientUpdatedAt !== '') {
            $serverStamp = $existing['updated_at'] ?? $existing['created_at'] ?? null;
            if ($serverStamp !== null) {
                $serverAt = Carbon::parse((string) $serverStamp);
                $clientAt = Carbon::parse($clientUpdatedAt);
                if ($serverAt->greaterThan($clientAt)) {
                    return [
                        'conflict' => true,
                        'data' => $normalize($existing),
                    ];
                }
            }
        }

        return null;
    }
}
