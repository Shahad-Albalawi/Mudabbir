<?php

namespace App\Http\Requests\Expense;

use Illuminate\Foundation\Http\FormRequest;

class UpdateExpenseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => ['sometimes', 'numeric', 'min:0.01'],
            'date' => ['sometimes', 'date', 'before_or_equal:today'],
            'type' => ['sometimes', 'string', 'in:expense,income'],
            'notes' => ['nullable', 'string', 'max:500'],
            'account_id' => ['sometimes', 'integer', 'min:1'],
            'category_id' => ['sometimes', 'integer', 'min:1'],
            'account_name' => ['nullable', 'string', 'max:255'],
            'category_name' => ['nullable', 'string', 'max:255'],
            'is_recurring' => ['sometimes', 'boolean'],
            'recurrence_interval' => ['nullable', 'string', 'max:32'],
            'updated_at' => ['nullable', 'date'],
        ];
    }
}
