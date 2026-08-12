<?php

namespace Tests\Feature;

use Mockery;
use App\Services\AiCoachService;
use App\Services\OpenAiStreamService;
use Tests\TestCase;

class RateLimitingTest extends TestCase
{
    public function test_register_rate_limit_returns_429(): void
    {
        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/register', [])->assertStatus(422);
        }

        $this->postJson('/api/register', [])->assertStatus(429);
    }

    public function test_login_route_rate_limit_returns_429(): void
    {
        for ($i = 0; $i < 10; $i++) {
            $this->postJson('/api/login', [
                'email' => 'rate-limit@example.com',
                'password' => 'wrong',
            ]);
        }

        $this->postJson('/api/login', [
            'email' => 'rate-limit@example.com',
            'password' => 'wrong',
        ])->assertStatus(429);
    }

    public function test_generate_content_rate_limit_returns_429(): void
    {
        $auth = $this->registerUser('gen-rate-limit@example.com');

        $this->mock(AiCoachService::class, function (Mockery\MockInterface $mock): void {
            $mock->shouldReceive('generate')->andReturn('ok');
            $mock->shouldReceive('provider')->andReturn('openai');
            $mock->shouldReceive('model')->andReturn('gpt-4o-mini');
        });

        for ($i = 0; $i < 12; $i++) {
            $this->withApiAuth($auth)->postJson('/api/generate-content', [
                'content' => 'Hello',
            ])->assertStatus(200);
        }

        $this->withApiAuth($auth)->postJson('/api/generate-content', [
            'content' => 'Hello',
        ])->assertStatus(429);
    }

    public function test_ai_chat_rate_limit_returns_429(): void
    {
        $auth = $this->registerUser('ai-chat-rate@example.com');

        $this->mock(OpenAiStreamService::class, function (Mockery\MockInterface $mock): void {
            $mock->shouldReceive('chat')->andReturn('ok');
        });

        for ($i = 0; $i < 12; $i++) {
            $this->withApiAuth($auth)->postJson('/api/ai/chat', [
                'message' => 'Hello',
                'stream' => false,
            ])->assertStatus(200);
        }

        $this->withApiAuth($auth)->postJson('/api/ai/chat', [
            'message' => 'Hello',
            'stream' => false,
        ])->assertStatus(429);
    }
}
