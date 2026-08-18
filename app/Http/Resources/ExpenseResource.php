<?php

namespace App\Http\Resources;

use App\Support\ArabicCurrencyFormatter;
use App\Support\CategoryPresenter;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\Expense */
class ExpenseResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        $category = CategoryPresenter::present($this->category_name);

        return [
            'id' => (int) $this->id,
            'user_id' => (int) $this->user_id,
            'amount' => (float) $this->amount,
            'amount_formatted' => ArabicCurrencyFormatter::format((float) $this->amount),
            'date' => $this->date?->format('Y-m-d') ?? (string) $this->date,
            'type' => (string) $this->type,
            'notes' => $this->notes,
            'account_id' => (int) $this->account_id,
            'category_id' => (int) $this->category_id,
            'account_name' => (string) $this->account_name,
            'category_name' => (string) $this->category_name,
            'category_icon' => $category['icon'],
            'category_color' => $category['color'],
            'is_recurring' => (bool) $this->is_recurring,
            'recurrence_interval' => $this->recurrence_interval,
            'created_at' => optional($this->created_at)->toISOString(),
            'updated_at' => optional($this->updated_at)->toISOString(),
        ];
    }

    /**
     * @param  array<string, mixed>  $row
     * @return array<string, mixed>
     */
    public static function fromStoreArray(array $row): array
    {
        $category = CategoryPresenter::present($row['category_name'] ?? '');

        return [
            'id' => (int) $row['id'],
            'user_id' => (int) ($row['user_id'] ?? 0),
            'amount' => (float) $row['amount'],
            'amount_formatted' => ArabicCurrencyFormatter::format((float) $row['amount']),
            'date' => (string) $row['date'],
            'type' => (string) ($row['type'] ?? 'expense'),
            'notes' => $row['notes'] ?? null,
            'account_id' => (int) $row['account_id'],
            'category_id' => (int) $row['category_id'],
            'account_name' => (string) ($row['account_name'] ?? ''),
            'category_name' => (string) ($row['category_name'] ?? ''),
            'category_icon' => $category['icon'],
            'category_color' => $category['color'],
            'is_recurring' => (bool) ($row['is_recurring'] ?? false),
            'recurrence_interval' => $row['recurrence_interval'] ?? null,
            'created_at' => $row['created_at'] ?? null,
            'updated_at' => $row['updated_at'] ?? null,
        ];
    }
}
