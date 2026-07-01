<?php

namespace App\Http\Requests\Goal;

use Illuminate\Foundation\Http\FormRequest;

class UpdateGoalRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'target' => ['sometimes', 'numeric', 'min:0.01'],
            'type' => ['sometimes', 'string', 'max:64'],
            'start_date' => ['sometimes', 'date'],
            'end_date' => ['sometimes', 'date'],
            'image_path' => ['nullable', 'string', 'max:500'],
            'updated_at' => ['nullable', 'date'],
        ];
    }
}
