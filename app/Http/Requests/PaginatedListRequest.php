<?php

namespace App\Http\Requests;

use App\Http\Requests\Concerns\PaginatedListRules;
use Illuminate\Foundation\Http\FormRequest;

class PaginatedListRequest extends FormRequest
{
    use PaginatedListRules;

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return $this->paginatedListRules();
    }
}
