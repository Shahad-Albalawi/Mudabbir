<?php

namespace App\Services;

use Carbon\Carbon;

class ReportService
{
    public function __construct(
        private StatisticsService $statisticsService,
        private ExpenseStore $expenseStore,
        private GoalStore $goalStore,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function monthlyForUser(int $userId, ?string $month = null): array
    {
        $reference = $month
            ? Carbon::createFromFormat('Y-m', $month)->startOfMonth()
            : Carbon::now()->startOfMonth();

        $monthStart = $reference->toDateString();
        $monthEnd = $reference->copy()->endOfMonth()->toDateString();
        $label = $reference->translatedFormat('F Y');

        $income = 0.0;
        $expense = 0.0;
        $expenseByCategory = [];
        $transactions = [];

        foreach ($this->expenseStore->all($userId) as $row) {
            $date = (string) ($row['date'] ?? '');
            if ($date < $monthStart || $date > $monthEnd) {
                continue;
            }

            $amount = (float) ($row['amount'] ?? 0);
            $type = (string) ($row['type'] ?? 'expense');
            $category = (string) ($row['category_name'] ?? 'أخرى');

            $transactions[] = [
                'id' => $row['id'] ?? null,
                'date' => $date,
                'type' => $type,
                'category' => $category,
                'amount' => round($amount, 2),
                'note' => $row['note'] ?? $row['description'] ?? null,
            ];

            if ($type === 'income') {
                $income += $amount;
            } else {
                $expense += $amount;
                $expenseByCategory[$category] = ($expenseByCategory[$category] ?? 0) + $amount;
            }
        }

        arsort($expenseByCategory);
        usort($transactions, fn (array $a, array $b): int => strcmp((string) $b['date'], (string) $a['date']));

        $statistics = $this->statisticsService->forUser($userId);
        $goals = array_values(array_map(
            fn (array $goal): array => [
                'name' => $goal['name'] ?? '',
                'target' => round((float) ($goal['target'] ?? 0), 2),
                'current_amount' => round((float) ($goal['current_amount'] ?? 0), 2),
                'is_completed' => (bool) ($goal['is_completed'] ?? false),
            ],
            $this->goalStore->all($userId),
        ));

        return [
            'report_type' => 'monthly',
            'period' => [
                'label' => $label,
                'from' => $monthStart,
                'to' => $monthEnd,
            ],
            'summary' => [
                'total_income' => round($income, 2),
                'total_expense' => round($expense, 2),
                'net_balance' => round($income - $expense, 2),
                'savings_rate' => $income > 0
                    ? round((($income - $expense) / $income) * 100, 2)
                    : 0.0,
                'transaction_count' => count($transactions),
            ],
            'expense_by_category' => $expenseByCategory,
            'top_categories' => array_slice($expenseByCategory, 0, 5, true),
            'goals' => $goals,
            'health_snapshot' => [
                'savings_rate' => $statistics['savings_rate'],
                'active_goals_count' => $statistics['active_goals_count'],
            ],
            'transactions' => array_slice($transactions, 0, 50),
            'generated_at' => now()->toIso8601String(),
        ];
    }
}
