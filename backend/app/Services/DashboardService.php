<?php

namespace App\Services;

use Carbon\Carbon;

class DashboardService
{
    public function __construct(
        private StatisticsService $statisticsService,
        private GoalStore $goalStore,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function forUser(int $userId): array
    {
        $stats = $this->statisticsService->forUser($userId);
        $health = $this->resolveHealth($stats);

        return [
            'health_score' => $health['score'],
            'health_grade' => $health['grade'],
            'kpis' => [
                'total_income' => $stats['total_income'],
                'total_expenses' => $stats['total_expense'],
                'net_savings' => $stats['current_balance'],
                'savings_rate' => $stats['savings_rate'],
            ],
            'monthly_trend' => $this->formatMonthlyTrend($stats['monthly_trend'] ?? []),
            'expense_distribution' => $this->expenseDistribution(
                $stats['expense_by_category'] ?? [],
            ),
            'behavior_analysis' => $this->behaviorAnalysis($userId, $stats),
        ];
    }

    /**
     * @param  array<string, mixed>  $stats
     * @return array{score: int, grade: string}
     */
    private function resolveHealth(array $stats): array
    {
        $income = (float) ($stats['total_income'] ?? 0);
        $savingsRate = (float) ($stats['savings_rate'] ?? 0);
        $goalsProgress = $stats['goals_progress'] ?? [];

        $score = 40.0;

        if ($income > 0) {
            $score += min(35.0, max(0.0, $savingsRate) * 0.7);
        }

        if ($goalsProgress !== []) {
            $avgGoal = array_sum($goalsProgress) / count($goalsProgress);
            $score += min(15.0, $avgGoal * 0.15);
        }

        $activeGoals = (int) ($stats['active_goals_count'] ?? 0);
        if ($activeGoals > 0) {
            $score += 5.0;
        }

        if ($income > 0 && ($stats['total_expense'] ?? 0) <= $income) {
            $score += 5.0;
        }

        $score = (int) round(min(100, max(0, $score)));

        $grade = match (true) {
            $score >= 85 => 'excellent',
            $score >= 70 => 'good',
            $score >= 55 => 'fair',
            $score >= 40 => 'needs_improvement',
            default => 'at_risk',
        };

        return ['score' => $score, 'grade' => $grade];
    }

    /**
     * @param  array<int, array<string, mixed>>  $rawTrend
     * @return array<int, array<string, mixed>>
     */
    private function formatMonthlyTrend(array $rawTrend): array
    {
        $now = Carbon::now()->locale('ar');
        $result = [];

        for ($i = 5; $i >= 0; $i--) {
            $idx = 5 - $i;
            $point = $rawTrend[$idx] ?? ['income' => 0.0, 'expense' => 0.0];
            $month = $now->copy()->subMonths($i);

            $result[] = [
                'month' => $month->translatedFormat('F'),
                'income' => round((float) ($point['income'] ?? 0), 2),
                'expenses' => round((float) ($point['expense'] ?? 0), 2),
            ];
        }

        return $result;
    }

    /**
     * @param  array<string, float>  $byCategory
     * @return array<int, array<string, mixed>>
     */
    private function expenseDistribution(array $byCategory): array
    {
        if ($byCategory === []) {
            return [];
        }

        $total = array_sum($byCategory);
        if ($total <= 0) {
            return [];
        }

        $rows = [];
        foreach ($byCategory as $category => $amount) {
            $rows[] = [
                'category' => (string) $category,
                'amount' => round((float) $amount, 2),
                'percentage' => round(((float) $amount / $total) * 100, 1),
            ];
        }

        return array_slice($rows, 0, 8);
    }

    /**
     * @param  array<string, mixed>  $stats
     * @return array<string, mixed>
     */
    private function behaviorAnalysis(int $userId, array $stats): array
    {
        $savingsRate = (float) ($stats['savings_rate'] ?? 0);
        $income = (float) ($stats['total_income'] ?? 0);
        $expense = (float) ($stats['total_expense'] ?? 0);
        $trend = $stats['monthly_trend'] ?? [];

        $expenseSeries = array_map(
            fn (array $row): float => (float) ($row['expense'] ?? 0),
            $trend,
        );

        return [
            'savings_consistency' => $this->savingsConsistencyLabel($savingsRate),
            'spending_pattern' => $this->spendingPatternLabel($income, $expense, $expenseSeries),
            'goal_adherence' => $this->goalAdherenceLabel($userId, $stats),
            'prediction_next_month' => $this->predictNextMonthExpense($expenseSeries, $expense),
        ];
    }

    private function savingsConsistencyLabel(float $savingsRate): string
    {
        return match (true) {
            $savingsRate >= 20 => 'excellent',
            $savingsRate >= 10 => 'good',
            $savingsRate >= 5 => 'fair',
            default => 'poor',
        };
    }

    /**
     * @param  array<int, float>  $expenseSeries
     */
    private function spendingPatternLabel(float $income, float $expense, array $expenseSeries): string
    {
        if ($income > 0 && $expense / $income >= 0.85) {
            return 'high';
        }

        $nonZero = array_values(array_filter($expenseSeries, fn (float $v): bool => $v > 0));
        if (count($nonZero) < 2) {
            return $income > 0 && $expense < $income * 0.3 ? 'low' : 'regular';
        }

        $mean = array_sum($nonZero) / count($nonZero);
        if ($mean <= 0) {
            return 'regular';
        }

        $variance = 0.0;
        foreach ($nonZero as $value) {
            $variance += ($value - $mean) ** 2;
        }
        $variance /= count($nonZero);
        $cv = sqrt($variance) / $mean;

        return match (true) {
            $cv >= 0.4 => 'volatile',
            $cv <= 0.2 => 'regular',
            default => 'regular',
        };
    }

    /**
     * @param  array<string, mixed>  $stats
     */
    private function goalAdherenceLabel(int $userId, array $stats): string
    {
        $goals = $this->goalStore->all($userId);
        $active = array_values(array_filter(
            $goals,
            fn (array $goal): bool => empty($goal['is_completed']),
        ));

        if ($active === []) {
            return 'no_goals';
        }

        $progressValues = [];
        foreach ($active as $goal) {
            $target = (float) ($goal['target'] ?? 0);
            $current = (float) ($goal['current_amount'] ?? 0);
            $progressValues[] = $target > 0 ? min(100, ($current / $target) * 100) : 0.0;
        }

        $avg = array_sum($progressValues) / count($progressValues);

        return match (true) {
            $avg >= 75 => 'excellent',
            $avg >= 25 => 'on_track',
            default => 'behind',
        };
    }

    /**
     * @param  array<int, float>  $expenseSeries
     */
    private function predictNextMonthExpense(array $expenseSeries, float $currentMonthExpense): float
    {
        $recent = array_slice($expenseSeries, -3);
        $recent = array_values(array_filter($recent, fn (float $v): bool => $v > 0));

        if ($recent === []) {
            return round($currentMonthExpense, 2);
        }

        return round(array_sum($recent) / count($recent), 2);
    }
}
