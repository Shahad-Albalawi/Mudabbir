<?php

namespace Tests\Feature;

use App\Services\AiCoachService;
use Mockery;
use Tests\TestCase;

class GenerateContentTest extends TestCase
{
    public function test_generate_content_requires_content_field(): void
    {
        $response = $this->postJson('/api/generate-content', []);

        $response->assertStatus(422);
    }

    public function test_generate_content_returns_clean_response(): void
    {
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

        $response = $this->postJson('/api/generate-content', [
            'content' => 'Hello',
        ]);

        $response
            ->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'request_id',
                'message',
                'meta' => ['provider', 'model'],
            ]);
    }

    public function test_generate_content_returns_429_when_quota_exceeded(): void
    {
        $this->mock(AiCoachService::class, function (Mockery\MockInterface $mock): void {
            $mock->shouldReceive('generate')
                ->once()
                ->andThrow(new \App\Exceptions\AiQuotaExceededException('Quota exceeded'));
        });

        $response = $this->postJson('/api/generate-content', [
            'content' => 'Hello',
        ]);

        $response
            ->assertStatus(429)
            ->assertJsonPath('error.code', 'QUOTA_EXCEEDED');
    }
}
