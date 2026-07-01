<?php

namespace Tests\Concerns;

use Illuminate\Support\Facades\File;

trait AuthenticatesUsers
{
    protected function resetJsonStores(): void
    {
        $subdir = (string) config('mudabbir.json_store_subdir');
        if ($subdir === '') {
            return;
        }

        $dir = storage_path('app/'.$subdir);
        if (File::isDirectory($dir)) {
            File::cleanDirectory($dir);
        }
    }

    /**
     * @return array{token: string, user: array<string, mixed>, headers: array<string, string>}
     */
    protected function registerUser(
        string $email,
        string $name = 'Test User',
        string $password = 'password123'
    ): array {
        $response = $this->postJson('/api/register', [
            'name' => $name,
            'email' => $email,
            'password' => $password,
            'password_confirmation' => $password,
        ]);

        $response->assertCreated();

        $token = (string) ($response->json('data.token.plainTextToken')
            ?? $response->json('token.plainTextToken'));

        return [
            'token' => $token,
            'user' => $response->json('data.user') ?? $response->json('user'),
            'headers' => ['Authorization' => 'Bearer '.$token],
        ];
    }

    /**
     * @param  array{headers: array<string, string>}  $auth
     */
    protected function withApiAuth(array $auth): static
    {
        return $this->withHeaders($auth['headers']);
    }
}
