<?php

namespace Tests\Feature;

use Tests\TestCase;

class ApiExceptionHandlerTest extends TestCase
{
    public function test_validation_errors_return_arabic_envelope(): void
    {
        $response = $this->postJson('/api/register', [], [
            'Accept-Language' => 'ar',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'بيانات غير صالحة. يرجى مراجعة الحقول المحددة.')
            ->assertJsonStructure([
                'success',
                'data',
                'message',
                'errors' => ['name', 'email', 'password'],
                'meta' => ['timestamp', 'version'],
            ]);
    }

    public function test_not_found_returns_404_envelope(): void
    {
        $auth = $this->registerUser('handler-404@example.com');

        $this->withApiAuth($auth)
            ->getJson('/api/expenses/999999')
            ->assertStatus(404)
            ->assertJsonPath('success', false);
    }

    public function test_unauthorized_returns_401_envelope(): void
    {
        $this->getJson('/api/goals')
            ->assertStatus(401)
            ->assertJsonPath('success', false);
    }
}
