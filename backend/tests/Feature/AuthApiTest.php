<?php

namespace Tests\Feature;

use Tests\TestCase;

class AuthApiTest extends TestCase
{
    public function test_register_validates_required_fields(): void
    {
        $response = $this->postJson('/api/register', []);

        $response->assertStatus(422)->assertJsonValidationErrors(['name', 'email', 'password']);
    }

    public function test_login_rejects_invalid_credentials(): void
    {
        $this->registerUser('auth-valid@example.com');

        $response = $this->postJson('/api/login', [
            'email' => 'auth-valid@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors(['email']);
    }

    public function test_login_rotates_mobile_tokens(): void
    {
        $auth = $this->registerUser('auth-rotate@example.com');
        $oldToken = $auth['token'];

        $login = $this->postJson('/api/login', [
            'email' => 'auth-rotate@example.com',
            'password' => 'password123',
        ]);
        $login->assertOk();
        $newToken = (string) ($login->json('data.token.plainTextToken')
            ?? $login->json('token.plainTextToken'));

        $this->assertNotSame($oldToken, $newToken);
        $this->withHeaders(['Authorization' => 'Bearer '.$oldToken])
            ->getJson('/api/goals')
            ->assertUnauthorized();
        $this->withHeaders(['Authorization' => 'Bearer '.$newToken])
            ->getJson('/api/goals')
            ->assertOk();
    }

    public function test_login_locks_out_after_repeated_failures(): void
    {
        $this->registerUser('auth-lockout@example.com');

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/login', [
                'email' => 'auth-lockout@example.com',
                'password' => 'wrong-password',
            ])->assertStatus(422);
        }

        $response = $this->postJson('/api/login', [
            'email' => 'auth-lockout@example.com',
            'password' => 'wrong-password',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors(['email']);

        $this->assertStringContainsString(
            'Too many login attempts',
            (string) $response->json('errors.email.0')
        );
    }
}
