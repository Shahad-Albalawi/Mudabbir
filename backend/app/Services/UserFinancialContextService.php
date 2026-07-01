<?php

namespace App\Services;

use Carbon\Carbon;

class UserFinancialContextService
{
    public function __construct(
        private ExpenseStore $expenseStore,
        private GoalStore $goalStore,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function buildForUser(int $userId): array
    {
        $now = Carbon::now();
        $monthStart = $now->copy()->startOfMonth()->toDateString();
        $monthEnd = $now->copy()->endOfMonth()->toDateString();

        $monthlyIncome = 0.0;
        $monthlyExpense = 0.0;
        $categoryTotals = [];

        foreach ($this->expenseStore->all($userId) as $row) {
            $date = (string) ($row['date'] ?? '');
            if ($date < $monthStart || $date > $monthEnd) {
                continue;
            }
            $amount = (float) ($row['amount'] ?? 0);
            if (($row['type'] ?? 'expense') === 'income') {
                $monthlyIncome += $amount;
            } else {
                $monthlyExpense += $amount;
                $category = (string) ($row['category_name'] ?? 'اخرى');
                $categoryTotals[$category] = ($categoryTotals[$category] ?? 0) + $amount;
            }
        }

        arsort($categoryTotals);
        $topCategories = array_slice($categoryTotals, 0, 5, true);
        $savingsRate = $monthlyIncome > 0
            ? (($monthlyIncome - $monthlyExpense) / $monthlyIncome) * 100
            : 0.0;

        $activeGoals = array_values(array_filter(
            $this->goalStore->all($userId),
            fn (array $goal): bool => empty($goal['is_completed'])
        ));

        return [
            'monthly_income' => round($monthlyIncome, 2),
            'total_expenses' => round($monthlyExpense, 2),
            'savings_rate' => round($savingsRate, 2),
            'top_categories' => $topCategories,
            'active_goals' => array_map(
                fn (array $goal): array => [
                    'name' => $goal['name'],
                    'target' => $goal['target'],
                    'current_amount' => $goal['current_amount'],
                ],
                array_slice($activeGoals, 0, 5)
            ),
        ];
    }

    public function toArabicPromptContext(array $context): string
    {
        $lines = [
            'الدخل الشهري: '.$context['monthly_income'].' ريال',
            'إجمالي المصروفات الشهرية: '.$context['total_expenses'].' ريال',
            'معدل الادخار: '.$context['savings_rate'].'%',
        ];

        if (! empty($context['top_categories'])) {
            $lines[] = 'أعلى فئات الإنفاق:';
            foreach ($context['top_categories'] as $name => $amount) {
                $lines[] = "- {$name}: {$amount} ريال";
            }
        }

        if (! empty($context['active_goals'])) {
            $lines[] = 'الأهداف النشطة:';
            foreach ($context['active_goals'] as $goal) {
                $lines[] = "- {$goal['name']}: {$goal['current_amount']} / {$goal['target']} ريال";
            }
        }

        return implode("\n", $lines);
    }
}
