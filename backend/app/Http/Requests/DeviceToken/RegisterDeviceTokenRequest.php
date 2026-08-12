<?php

namespace App\Http\Requests\DeviceToken;

use Illuminate\Foundation\Http\FormRequest;

class RegisterDeviceTokenRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'fcm_token' => ['required', 'string', 'max:512'],
            'platform' => ['nullable', 'string', 'max:32'],
        ];
    }
}
