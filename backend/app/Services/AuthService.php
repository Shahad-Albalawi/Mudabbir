<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function register(array $validated): array
    {
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'email_verified_at' => now(),
        ]);

        $token = $this->issueMobileToken($user);

        return [
            'user' => $user,
            'token' => ['plainTextToken' => $token],
        ];
    }

    /**
     * @return array{user: User, token: array{plainTextToken: string}}
     *
     * @throws ValidationException
     */
    public function login(array $validated, Request $request): array
    {
        $key = Str::lower($validated['email']).'|'.$request->ip();

        if (RateLimiter::tooManyAttempts($key, 5)) {
            $seconds = RateLimiter::availableIn($key);

            throw ValidationException::withMessages([
                'email' => [__('auth.throttle', ['seconds' => $seconds])],
            ]);
        }

        $user = User::where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            RateLimiter::hit($key, 60);

            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        RateLimiter::clear($key);

        return [
            'user' => $user,
            'token' => ['plainTextToken' => $this->issueMobileToken($user)],
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }

    public function issueMobileToken(User $user): string
    {
        $user->tokens()->where('name', 'mudabbir-mobile')->delete();

        return $user->createToken('mudabbir-mobile')->plainTextToken;
    }
}
