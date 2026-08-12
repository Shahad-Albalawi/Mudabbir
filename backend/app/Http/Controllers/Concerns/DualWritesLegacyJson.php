<?php

namespace App\Http\Controllers\Concerns;

use App\Services\Legacy\LegacyJsonBudgetStore;
use App\Services\Legacy\LegacyJsonChallengeStore;
use App\Services\Legacy\LegacyJsonExpenseStore;
use App\Services\Legacy\LegacyJsonGoalStore;
use App\Support\DualWriteMirror;

trait DualWritesLegacyJson
{
    /**
     * @param  array<string, mixed>  $row
     */
    protected function mirrorExpenseToLegacyJson(array $row): void
    {
        DualWriteMirror::mirror(
            'expense',
            fn (): mixed => app(LegacyJsonExpenseStore::class)->upsertFromStoreArray($row)
        );
    }

    protected function mirrorExpenseDeleteToLegacyJson(int $id, int $userId): void
    {
        DualWriteMirror::mirror(
            'expense',
            fn (): mixed => app(LegacyJsonExpenseStore::class)->deleteById($id, $userId)
        );
    }

    /**
     * @param  array<string, mixed>  $row
     */
    protected function mirrorGoalToLegacyJson(array $row): void
    {
        DualWriteMirror::mirror(
            'goal',
            fn (): mixed => app(LegacyJsonGoalStore::class)->upsertFromStoreArray($row)
        );
    }

    protected function mirrorGoalDeleteToLegacyJson(int $id, int $userId): void
    {
        DualWriteMirror::mirror(
            'goal',
            fn (): mixed => app(LegacyJsonGoalStore::class)->deleteById($id, $userId)
        );
    }

    /**
     * @param  array<string, mixed>  $row
     */
    protected function mirrorBudgetToLegacyJson(array $row): void
    {
        DualWriteMirror::mirror(
            'budget',
            fn (): mixed => app(LegacyJsonBudgetStore::class)->upsertFromStoreArray($row)
        );
    }

    protected function mirrorBudgetDeleteToLegacyJson(int $id, int $userId): void
    {
        DualWriteMirror::mirror(
            'budget',
            fn (): mixed => app(LegacyJsonBudgetStore::class)->deleteById($id, $userId)
        );
    }

    /**
     * @param  array<string, mixed>  $row
     */
    protected function mirrorChallengeToLegacyJson(array $row): void
    {
        DualWriteMirror::mirror(
            'challenge',
            fn (): mixed => app(LegacyJsonChallengeStore::class)->upsertFromStoreArray($row)
        );
    }

    protected function mirrorChallengeDeleteToLegacyJson(int $id, int $userId): void
    {
        DualWriteMirror::mirror(
            'challenge',
            fn (): mixed => app(LegacyJsonChallengeStore::class)->deleteById($id, $userId)
        );
    }
}
