<?php

namespace Tests\Feature;

use App\Models\DeviceToken;
use Tests\TestCase;

class DeviceTokenApiTest extends TestCase
{
    public function test_register_device_token_requires_auth(): void
    {
        $this->postJson('/api/device-tokens', [
            'fcm_token' => 'sample-token',
            'platform' => 'android',
        ])->assertUnauthorized();
    }

    public function test_register_and_delete_device_token(): void
    {
        $auth = $this->registerUser('device-token@example.com');
        $headers = ['Authorization' => 'Bearer '.$auth['token']];

        $this->withHeaders($headers)
            ->postJson('/api/device-tokens', [
                'fcm_token' => 'abc123',
                'platform' => 'android',
            ])
            ->assertOk();

        $this->assertDatabaseHas('device_tokens', [
            'fcm_token' => 'abc123',
            'platform' => 'android',
        ]);

        $this->withHeaders($headers)
            ->deleteJson('/api/device-tokens', [
                'fcm_token' => 'abc123',
            ])
            ->assertOk();

        $this->assertSame(
            0,
            DeviceToken::query()->where('fcm_token', 'abc123')->count()
        );
    }
}
