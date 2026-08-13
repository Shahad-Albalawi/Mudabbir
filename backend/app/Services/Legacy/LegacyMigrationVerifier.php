<?php

namespace App\Services\Legacy;

use Illuminate\Support\Collection;

final class LegacyMigrationVerifier
{
    /**
     * @param  callable(): array<int, array<string, mixed>>  $loadJsonRowsById
     * @param  callable(list<int>): array<int, array<string, mixed>>  $loadDbRowsById
     * @param  callable(): list<int>  $allDbIds
     * @param  list<string>  $compareKeys
     * @param  callable(array<string, mixed>, array<string, mixed>, int): ?string  $extraCompare
     * @return array{ok: bool, json_count: int, db_count: int, sampled: int, mismatches: list<string>, orphans: list<int>}
     */
    public function verify(
        string $entity,
        callable $loadJsonRowsById,
        callable $loadDbRowsById,
        callable $allDbIds,
        array $compareKeys,
        int $samplePercent = 10,
        ?callable $extraCompare = null,
    ): array {
        $jsonRows = $loadJsonRowsById();
        $jsonIds = array_keys($jsonRows);
        $dbIds = $allDbIds();
        $dbCount = count($dbIds);

        $mismatches = [];
        $orphans = array_values(array_diff($dbIds, $jsonIds));

        if (count($jsonRows) !== $dbCount) {
            $mismatches[] = sprintf(
                '%s count mismatch: JSON=%d DB=%d',
                $entity,
                count($jsonRows),
                $dbCount,
            );
        }

        if ($orphans !== []) {
            $mismatches[] = sprintf(
                '%s orphan DB row(s) without JSON source: %s',
                $entity,
                $this->formatIdList($orphans),
            );
        }

        $sampleIds = $this->sampleIds($jsonIds, $samplePercent);
        $dbSample = $loadDbRowsById($sampleIds);

        foreach ($sampleIds as $id) {
            if (! isset($jsonRows[$id])) {
                $mismatches[] = "{$entity} id={$id}: missing from JSON sample set";

                continue;
            }

            if (! isset($dbSample[$id])) {
                $mismatches[] = "{$entity} id={$id}: missing from database";

                continue;
            }

            foreach ($compareKeys as $key) {
                $jsonValue = $this->normalizeValue($jsonRows[$id][$key] ?? null, $key);
                $dbValue = $this->normalizeValue($dbSample[$id][$key] ?? null, $key);

                if ($jsonValue !== $dbValue) {
                    $mismatches[] = "{$entity} id={$id} field={$key}: JSON=".json_encode($jsonValue).' DB='.json_encode($dbValue);
                }
            }

            if ($extraCompare !== null) {
                $message = $extraCompare($jsonRows[$id], $dbSample[$id], $id);
                if ($message !== null) {
                    $mismatches[] = $message;
                }
            }
        }

        return [
            'ok' => $mismatches === [],
            'json_count' => count($jsonRows),
            'db_count' => $dbCount,
            'sampled' => count($sampleIds),
            'mismatches' => $mismatches,
            'orphans' => $orphans,
        ];
    }

    /**
     * @param  list<int>  $ids
     * @return list<int>
     */
    private function sampleIds(array $ids, int $samplePercent): array
    {
        if ($ids === []) {
            return [];
        }

        $samplePercent = max(1, min(100, $samplePercent));
        $target = (int) max(1, ceil(count($ids) * $samplePercent / 100));

        if ($target >= count($ids)) {
            return array_values($ids);
        }

        $picked = (array) array_rand(array_flip($ids), $target);
        if (! array_is_list($picked)) {
            $picked = [$picked];
        }

        sort($picked);

        return $picked;
    }

    private function normalizeValue(mixed $value, string $key): mixed
    {
        if ($value === null || $value === '') {
            return null;
        }

        if (in_array($key, ['amount', 'target', 'current_amount'], true)) {
            return round((float) $value, 2);
        }

        if (in_array($key, ['is_recurring', 'is_completed', 'achieved'], true)) {
            return (bool) $value;
        }

        if (in_array($key, ['date', 'start_date', 'end_date'], true)) {
            return substr((string) $value, 0, 10);
        }

        if (in_array($key, ['account_id', 'category_id', 'user_id', 'creator_id'], true)) {
            return (int) $value;
        }

        return (string) $value;
    }

    /**
     * @param  list<int>  $ids
     */
    private function formatIdList(array $ids): string
    {
        $slice = array_slice($ids, 0, 10);

        return implode(', ', $slice).(count($ids) > 10 ? '…' : '');
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public static function rowsFromJsonFile(string $path, string $collectionKey): array
    {
        if (! is_file($path)) {
            return [];
        }

        $decoded = json_decode((string) file_get_contents($path), true);
        if (! is_array($decoded[$collectionKey] ?? null)) {
            return [];
        }

        $rows = [];
        foreach ($decoded[$collectionKey] as $row) {
            if (! is_array($row) || ! isset($row['id'])) {
                continue;
            }
            $rows[(int) $row['id']] = $row;
        }

        return $rows;
    }
}
