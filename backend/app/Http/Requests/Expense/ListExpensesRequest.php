<?php

namespace App\Http\Requests\Expense;

use App\Http\Requests\Concerns\PaginatedListRules;
use Illuminate\Foundation\Http\FormRequest;

class ListExpensesRequest extends FormRequest
{
    use PaginatedListRules;

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return array_merge($this->paginatedListRules(), [
            'sort' => ['sometimes', 'string', 'in:amount,date'],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'category' => ['nullable', 'string', 'max:255'],
            'min' => ['nullable', 'numeric', 'min:0'],
            'max' => ['nullable', 'numeric', 'min:0'],
        ]);
    }

    public function sort(): string
    {
        $sort = (string) $this->query('sort', 'date');

        return in_array($sort, ['amount', 'date'], true) ? $sort : 'date';
    }
}
