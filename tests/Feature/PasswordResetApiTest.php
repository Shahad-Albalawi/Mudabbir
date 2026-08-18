<?php

namespace Tests\Feature;

use App\Mail\PasswordResetCodeMail;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class PasswordResetApiTest extends TestCase
{
    public function test_forgot_password_validates_email(): void
    {
        $response = $this->postJson('/api/auth/forgot-password', []);

        $response->assertStatus(422)->assertJsonValidationErrors(['email']);
    }

    public function test_forgot_password_sends_mail_for_existing_user(): void
    {
        Mail::fake();
        $this->registerUser('reset-flow@example.com');

        $response = $this->postJson('/api/auth/forgot-password', [
            'email' => 'reset-flow@example.com',
        ]);

        $response->assertOk()->assertJsonPath('message', __('passwords.sent_code'));
        Mail::assertSent(PasswordResetCodeMail::class, function (PasswordResetCodeMail $mail) {
            return strlen($mail->code) === 6;
        });
        $this->assertDatabaseHas('password_resets', [
            'email' => 'reset-flow@example.com',
        ]);
    }

    public function test_forgot_password_does_not_reveal_missing_account(): void
    {
        Mail::fake();

        $response = $this->postJson('/api/auth/forgot-password', [
            'email' => 'missing@example.com',
        ]);

        $response->assertOk()->assertJsonPath('message', __('passwords.sent_code'));
        Mail::assertNothingSent();
    }

    public function test_reset_password_updates_password_and_returns_token(): void
    {
        Mail::fake();
        $this->registerUser('reset-login@example.com');

        $this->postJson('/api/auth/forgot-password', [
            'email' => 'reset-login@example.com',
        ])->assertOk();

        $code = '123456';
        DB::table('password_resets')->where('email', 'reset-login@example.com')->update([
            'token' => Hash::make($code),
            'created_at' => now(),
        ]);

        $response = $this->postJson('/api/auth/reset-password', [
            'email' => 'reset-login@example.com',
            'code' => $code,
            'password' => 'new-password-99',
            'password_confirmation' => 'new-password-99',
        ]);

        $response->assertOk()->assertJsonPath('message', __('passwords.reset'));
        $token = (string) ($response->json('data.token.plainTextToken')
            ?? $response->json('token.plainTextToken'));
        $this->assertNotEmpty($token);

        $this->withHeaders(['Authorization' => 'Bearer '.$token])
            ->getJson('/api/goals')
            ->assertOk();

        $this->postJson('/api/login', [
            'email' => 'reset-login@example.com',
            'password' => 'new-password-99',
        ])->assertOk();

        $this->postJson('/api/login', [
            'email' => 'reset-login@example.com',
            'password' => 'password123',
        ])->assertStatus(422);
    }

    public function test_reset_password_rejects_invalid_code(): void
    {
        $this->registerUser('reset-invalid@example.com');

        DB::table('password_resets')->insert([
            'email' => 'reset-invalid@example.com',
            'token' => Hash::make('111111'),
            'created_at' => now(),
        ]);

        $response = $this->postJson('/api/auth/reset-password', [
            'email' => 'reset-invalid@example.com',
            'code' => '999999',
            'password' => 'new-password-99',
            'password_confirmation' => 'new-password-99',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors(['code']);
    }
}
