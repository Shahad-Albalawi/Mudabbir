<?php

namespace App\Services;

use Carbon\Carbon;

class StatisticsService
{
    public function __construct(
        private ExpenseStore $expenseStore,
        private GoalStore $goalStore,
        private BudgetStore $budgetStore,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function forUser(int $userId): array
    {
        $now = Carbon::now();
        $monthStart = $now->copy()->startOfMonth()->toDateString();
        $monthEnd = $now->copy()->endOfMonth()->toDateString();

        $monthlyIncome = 0.0;
        $monthlyExpense = 0.0;
        $incomeByCategory = [];
        $expenseByCategory = [];
        $monthlyTrend = [];

        for ($i = 5; $i >= 0; $i--) {
            $month = $now->copy()->subMonths($i);
            $monthlyTrend[$month->format('Y-m')] = [
                'label' => $month->translatedFormat('M'),
                'income' => 0.0,
                'expense' => 0.0,
            ];
        }

        foreach ($this->expenseStore->all($userId) as $row) {
            $date = (string) ($row['date'] ?? '');
            $amount = (float) ($row['amount'] ?? 0);
            $type = (string) ($row['type'] ?? 'expense');
            $category = (string) ($row['category_name'] ?? 'أخرى');
            $monthKey = strlen($date) >= 7 ? substr($date, 0, 7) : '';

            if (isset($monthlyTrend[$monthKey])) {
                if ($type === 'income') {
                    $monthlyTrend[$monthKey]['income'] += $amount;
                } else {
                    $monthlyTrend[$monthKey]['expense'] += $amount;
                }
            }

            if ($date < $monthStart || $date > $monthEnd) {
                continue;
            }

            if ($type === 'income') {
                $monthlyIncome += $amount;
                $incomeByCategory[$category] = ($incomeByCategory[$category] ?? 0) + $amount;
            } else {
                $monthlyExpense += $amount;
                $expenseByCategory[$category] = ($expenseByCategory[$category] ?? 0) + $amount;
            }
        }

        arsort($expenseByCategory);
        arsort($incomeByCategory);

        $balance = round($monthlyIncome - $monthlyExpense, 2);
        $savingsRate = $monthlyIncome > 0
            ? round((($monthlyIncome - $monthlyExpense) / $monthlyIncome) * 100, 2)
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
        $expenses = $this->expenseStore->all($userId);
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

        return [
            'period' => [
                'from' => $monthStart,
                'to' => $monthEnd,
            ],
            'total_income' => round($monthlyIncome, 2),
            'total_expense' => round($monthlyExpense, 2),
            'current_balance' => $balance,
            'savings_rate' => $savingsRate,
            'income_by_category' => $incomeByCategory,
            'expense_by_category' => $expenseByCategory,
            'monthly_trend' => array_values($monthlyTrend),
            'goals_progress' => $goalsProgress,
            'budgets_progress' => $budgetsProgress,
            'active_goals_count' => count(array_filter(
                $goals,
                fn (array $goal): bool => empty($goal['is_completed']),
            )),
        ];
    }
}
