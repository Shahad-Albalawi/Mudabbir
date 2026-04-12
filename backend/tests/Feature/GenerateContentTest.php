<?php

namespace Tests\Feature;

use App\Services\OpenAiService;
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
        $this->mock(OpenAiService::class, function (Mockery\MockInterface $mock): void {
            $mock->shouldReceive('generate')
                ->once()
                ->andReturn('Hello from OpenAI');
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
}
