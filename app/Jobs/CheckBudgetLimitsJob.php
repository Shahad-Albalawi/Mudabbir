<?php

namespace App\Jobs;

use App\Repositories\BudgetRepository;
use App\Repositories\ExpenseRepository;
use App\Services\FcmService;
use Carbon\Carbon;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Cache;

class CheckBudgetLimitsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(
        BudgetRepository $budgetStore,
        ExpenseRepository $expenseStore,
        FcmService $fcmService,
    ): void {
        $today = Carbon::today()->toDateString();
        /** @var array<string, float> $spentCache */
        $spentCache = [];

        foreach ($budgetStore->allUsersBudgets() as $budget) {
            if ($today < (string) ($budget['start_date'] ?? '') || $today > (string) ($budget['end_date'] ?? '')) {
                continue;
            }

            $userId = (int) ($budget['user_id'] ?? 0);
            $budgetId = (int) ($budget['id'] ?? 0);
            $limit = (float) ($budget['amount'] ?? 0);
            if ($userId <= 0 || $limit <= 0) {
                continue;
            }

            $start = (string) $budget['start_date'];
            $end = (string) $budget['end_date'];
            $cacheKey = "{$userId}:{$start}:{$end}";

            if (! array_key_exists($cacheKey, $spentCache)) {
                $spentCache[$cacheKey] = $expenseStore->sumExpensesInRange($userId, $start, $end);
            }

            $spent = $spentCache[$cacheKey];
            $ratio = $spent / $limit;

            if ($ratio >= 1.0) {
                $this->notifyOnce(
                    $fcmService,
                    $userId,
                    $budgetId,
                    'budget_exceeded',
                    'تجاوزت الميزانية',
                    'لقد تجاوزت ميزانيتك المحددة. راجع مصروفاتك اليوم.',
                    $spent,
                    $limit,
                );
                continue;
            }

            if ($ratio >= 0.8) {
                $this->notifyOnce(
                    $fcmService,
                    $userId,
                    $budgetId,
                    'budget_warning',
                    'اقتراب من حد الميزانية',
                    'استهلكت '.number_format($ratio * 100, 0).'% من ميزانيتك.',
                    $spent,
                    $limit,
                );
            }
        }
    }

    private function notifyOnce(
        FcmService $fcmService,
        int $userId,
        int $budgetId,
        string $type,
        string $title,
        string $body,
        float $spent,
        float $limit,
    ): void {
        $cacheKey = "budget-alert:{$userId}:{$budgetId}:{$type}:".Carbon::today()->format('Y-m-d');
        if (! Cache::add($cacheKey, true, now()->addDay())) {
            return;
        }

        $fcmService->storeAndPush($userId, $type, $title, $body, [
            'budget_id' => $budgetId,
            'spent' => $spent,
            'limit' => $limit,
        ]);
    }
}
