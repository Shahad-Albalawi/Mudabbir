<?php

namespace App\Http\Resources;

use App\Models\Budget;
use App\Support\ArabicCurrencyFormatter;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Budget|array<string, mixed> */
class BudgetResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        $budget = $this->resource instanceof Budget
            ? $this->resource->toStoreArray()
            : (array) $this->resource;

        return self::shape($budget);
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    public static function fromStoreArray(array $row): array
    {
        return self::shape($row);
    }

    /**
     * @param  array<string, mixed>  $budget
     * @return array<string, mixed>
     */
    private static function shape(array $budget): array
    {
        $amount = (float) ($budget['amount'] ?? 0);

        return [
            'id' => (int) $budget['id'],
            'user_id' => (int) ($budget['user_id'] ?? 0),
            'amount' => $amount,
            'amount_formatted' => ArabicCurrencyFormatter::format($amount),
            'start_date' => (string) $budget['start_date'],
            'end_date' => (string) $budget['end_date'],
            'account_id' => (int) $budget['account_id'],
            'created_at' => $budget['created_at'] ?? null,
            'updated_at' => $budget['updated_at'] ?? null,
        ];
    }
}
