<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class ResetPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'email', 'max:255'],
            'code' => ['required', 'string', 'size:6', 'regex:/^\d{6}$/'],
            'password' => ['required', 'string', 'confirmed', Password::min(8)],
        ];
    }
}
