<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class GenerateContentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'content' => ['required', 'string', 'min:1', 'max:40000'],
        ];
    }

    public function messages(): array
    {
        return [
            'content.required' => 'The content field is required.',
            'content.string' => 'The content field must be a string.',
            'content.min' => 'The content field cannot be empty.',
            'content.max' => 'The content field is too long.',
        ];
    }

    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(
            response()->json([
                'success' => false,
                'error' => [
                    'code' => 'VALIDATION_ERROR',
                    'message' => 'Invalid request payload.',
                    'details' => $validator->errors(),
                ],
            ], 422)
        );
    }
}
