<?php

namespace Tests\Feature;

use App\Services\AiCoachService;
use Mockery;
use Tests\TestCase;

class GenerateContentTest extends TestCase
{
    public function test_generate_content_requires_authentication(): void
    {
        $response = $this->postJson('/api/generate-content', [
            'content' => 'Hello',
        ]);

        $response->assertUnauthorized();
    }

    public function test_generate_content_requires_content_field(): void
    {
        $auth = $this->registerUser('gen-content@example.com');

        $response = $this->withApiAuth($auth)->postJson('/api/generate-content', []);

        $response->assertStatus(422);
    }

    public function test_generate_content_returns_clean_response(): void
    {
        $auth = $this->registerUser('gen-content-ok@example.com');

        $this->mock(AiCoachService::class, function (Mockery\MockInterface $mock): void {
            $mock->shouldReceive('generate')
                ->once()
                ->andReturn('Hello from AI coach');
            $mock->shouldReceive('provider')
                ->once()
                ->andReturn('openai');
            $mock->shouldReceive('model')
                ->once()
                ->andReturn('gpt-4o-mini');
        });

        $response = $this->withApiAuth($auth)->postJson('/api/generate-content', [
            'content' => 'Hello',
        ]);

        $response
            ->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Hello from AI coach')
            ->assertJsonPath('data.message', 'Hello from AI coach')
            ->assertJsonStructure([
                'success',
                'data' => [
                    'message',
                    'request_id',
                    'meta' => ['provider', 'model'],
                ],
                'message',
                'errors',
                'request_id',
                'meta' => ['provider', 'model'],
            ]);
    }

    public function test_generate_content_returns_429_when_quota_exceeded(): void
    {
        $auth = $this->registerUser('gen-content-quota@example.com');

        $this->mock(AiCoachService::class, function (Mockery\MockInterface $mock): void {
            $mock->shouldReceive('generate')
                ->once()
                ->andThrow(new \App\Exceptions\AiQuotaExceededException('Quota exceeded'));
        });

        $response = $this->withApiAuth($auth)->postJson('/api/generate-content', [
            'content' => 'Hello',
        ]);

        $response
            ->assertStatus(429)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.code', 'QUOTA_EXCEEDED')
            ->assertJsonPath('message', 'Quota exceeded');
    }
}
