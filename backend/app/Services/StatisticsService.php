<?php

namespace App\Services;

use App\Repositories\BudgetRepository;
use App\Repositories\ExpenseRepository;
use App\Repositories\GoalRepository;
use Carbon\Carbon;

class StatisticsService
{
    public function __construct(
        private ExpenseRepository $expenseStore,
        private GoalRepository $goalStore,
        private BudgetRepository $budgetStore,
    ) {}

    /**
     * Calendar-month aggregates (dashboard default).
     *
     * @return array<string, mixed>
     */
    public function forUser(int $userId): array
    {
        $now = Carbon::now();

        return $this->forUserRange(
            $userId,
            $now->copy()->startOfMonth()->toDateString(),
            $now->copy()->endOfMonth()->toDateString(),
            includeMonthlyTrend: true,
        );
    }

    /**
     * Aggregates for an arbitrary inclusive date range.
     *
     * @return array<string, mixed>
     */
    public function forUserRange(
        int $userId,
        string $from,
        string $to,
        bool $includeMonthlyTrend = false,
    ): array {
        $rangeStart = $from;
        $rangeEnd = $to;

        $periodIncome = 0.0;
        $periodExpense = 0.0;
        $incomeByCategory = [];
        $expenseByCategory = [];
        $dailyExpense = [];
        $monthlyTrend = [];
        $transactionCount = 0;
        $highestExpense = 0.0;

        if ($includeMonthlyTrend) {
            $anchor = Carbon::parse($rangeEnd);
            for ($i = 5; $i >= 0; $i--) {
                $month = $anchor->copy()->subMonths($i);
                $monthlyTrend[$month->format('Y-m')] = [
                    'label' => $month->translatedFormat('M'),
                    'income' => 0.0,
                    'expense' => 0.0,
                ];
            }
        }

        $expenses = $this->expenseStore->all($userId);

        foreach ($expenses as $row) {
            $date = (string) ($row['date'] ?? '');
            $amount = (float) ($row['amount'] ?? 0);
            $type = (string) ($row['type'] ?? 'expense');
            $category = (string) ($row['category_name'] ?? 'أخرى');
            $monthKey = strlen($date) >= 7 ? substr($date, 0, 7) : '';

            if ($includeMonthlyTrend && isset($monthlyTrend[$monthKey])) {
                if ($type === 'income') {
                    $monthlyTrend[$monthKey]['income'] += $amount;
                } else {
                    $monthlyTrend[$monthKey]['expense'] += $amount;
                }
            }

            if ($date < $rangeStart || $date > $rangeEnd) {
                continue;
            }

            if ($type === 'income') {
                $periodIncome += $amount;
                $incomeByCategory[$category] = ($incomeByCategory[$category] ?? 0) + $amount;
            } else {
                $periodExpense += $amount;
                $expenseByCategory[$category] = ($expenseByCategory[$category] ?? 0) + $amount;
                $dailyExpense[$date] = ($dailyExpense[$date] ?? 0) + $amount;
                $transactionCount++;
                $highestExpense = max($highestExpense, $amount);
            }
        }

        arsort($expenseByCategory);
        arsort($incomeByCategory);
        ksort($dailyExpense);

        $balance = round($periodIncome - $periodExpense, 2);
        $savingsRate = $periodIncome > 0
            ? round((($periodIncome - $periodExpense) / $periodIncome) * 100, 2)
            : 0.0;

        $goals = $this->goalStore->all($userId);
        $goalsProgress = [];
        foreach ($goals as $goal) {
            $target = (float) ($goal['target'] ?? 0);
            $current = (float) ($goal['current_amount'] ?? 0);
            $goalsProgress[(string) ($goal['name'] ?? 'هدف')] = $target > 0
                ? round(min(100, ($current / $target) * 100), 2)
                : 0.0;
        }

        $budgetsProgress = [];
        foreach ($this->budgetStore->all($userId) as $budget) {
            $limit = (float) ($budget['amount'] ?? 0);
            $start = (string) ($budget['start_date'] ?? '');
            $end = (string) ($budget['end_date'] ?? '');
            $spent = 0.0;

            foreach ($expenses as $row) {
                $date = (string) ($row['date'] ?? '');
                if ($date < $start || $date > $end) {
                    continue;
                }
                if (($row['type'] ?? 'expense') !== 'expense') {
                    continue;
                }
                $spent += (float) ($row['amount'] ?? 0);
            }

            $label = 'ميزانية #'.(string) ($budget['id'] ?? '');
            $budgetsProgress[$label] = $limit > 0
                ? round(min(100, ($spent / $limit) * 100), 2)
                : 0.0;
        }

        $payload = [
            'period' => [
                'from' => $rangeStart,
                'to' => $rangeEnd,
            ],
            'total_income' => round($periodIncome, 2),
            'total_expense' => round($periodExpense, 2),
            'current_balance' => $balance,
            'savings_rate' => $savingsRate,
            'income_by_category' => $incomeByCategory,
            'expense_by_category' => $expenseByCategory,
            'daily_expense' => $dailyExpense,
            'transaction_count' => $transactionCount,
            'highest_expense' => round($highestExpense, 2),
            'goals_progress' => $goalsProgress,
            'budgets_progress' => $budgetsProgress,
            'active_goals_count' => count(array_filter(
                $goals,
                fn (array $goal): bool => empty($goal['is_completed']),
            )),
        ];

        if ($includeMonthlyTrend) {
            $payload['monthly_trend'] = array_values($monthlyTrend);
        }

        return $payload;
    }
}
