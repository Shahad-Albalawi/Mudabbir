<?php

namespace App\Services;

use App\Mail\PasswordResetCodeMail;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Validation\ValidationException;

class PasswordResetService
{
    public function __construct(private AuthService $authService) {}

    /**
     * Send a 6-digit reset code if the account exists. Always succeeds silently
     * when the email is unknown to avoid account enumeration.
     */
    public function sendResetCode(string $email): void
    {
        $email = strtolower(trim($email));
        $user = User::where('email', $email)->first();

        if ($user === null) {
            return;
        }

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        DB::table('password_resets')->updateOrInsert(
            ['email' => $email],
            [
                'token' => Hash::make($code),
                'created_at' => now(),
            ],
        );

        Mail::to($user)->send(new PasswordResetCodeMail($code, (string) $user->name));
    }

    /**
     * @return array{user: User, token: array{plainTextToken: string}}
     *
     * @throws ValidationException
     */
    public function resetPassword(string $email, string $code, string $password): array
    {
        $email = strtolower(trim($email));
        $record = DB::table('password_resets')->where('email', $email)->first();

        if ($record === null || ! Hash::check($code, $record->token)) {
            throw ValidationException::withMessages([
                'code' => [__('passwords.token')],
            ]);
        }

        $createdAt = Carbon::parse($record->created_at);
        $expiresMinutes = (int) config('auth.passwords.users.expire', 60);

        if ($createdAt->addMinutes($expiresMinutes)->isPast()) {
            DB::table('password_resets')->where('email', $email)->delete();

            throw ValidationException::withMessages([
                'code' => [__('passwords.token')],
            ]);
        }

        $user = User::where('email', $email)->first();

        if ($user === null) {
            throw ValidationException::withMessages([
                'email' => [__('passwords.user')],
            ]);
        }

        $user->forceFill([
            'password' => Hash::make($password),
        ])->save();

        DB::table('password_resets')->where('email', $email)->delete();
        $user->tokens()->delete();

        return [
            'user' => $user->fresh(),
            'token' => ['plainTextToken' => $this->authService->issueMobileToken($user)],
        ];
    }
}
