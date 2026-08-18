<?php

namespace App\Http\Requests;

use Carbon\Carbon;
use Illuminate\Foundation\Http\FormRequest;

class StatisticsRangeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'from' => ['sometimes', 'date'],
            'to' => ['sometimes', 'date'],
            'period' => ['sometimes', 'string', 'in:week,month,quarter,year'],
        ];
    }

    /**
     * @return array{from: string, to: string}
     */
    public function resolvedRange(): array
    {
        if ($this->filled('from') && $this->filled('to')) {
            return [
                'from' => Carbon::parse((string) $this->query('from'))->toDateString(),
                'to' => Carbon::parse((string) $this->query('to'))->toDateString(),
            ];
        }

        $period = (string) $this->query('period', 'month');
        $to = Carbon::today();
        $days = match ($period) {
            'week' => 7,
            'quarter' => 90,
            'year' => 365,
            default => 30,
        };

        return [
            'from' => $to->copy()->subDays($days - 1)->toDateString(),
            'to' => $to->toDateString(),
        ];
    }

    public function cacheSuffix(): string
    {
        $range = $this->resolvedRange();

        return $range['from'].'_'.$range['to'];
    }
}
