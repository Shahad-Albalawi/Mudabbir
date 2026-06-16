<?php

namespace Tests\Feature;

use Tests\TestCase;

class ChallengesApiTest extends TestCase
{
    public function test_challenges_index_returns_success_shape(): void
    {
        $response = $this->getJson('/api/challenges');

        $response->assertStatus(200)->assertJsonStructure([
            'success',
            'data',
        ]);
    }

    public function test_invite_and_pending_invitations_work(): void
    {
        $inviteResponse = $this->postJson('/api/challenges/1/invite', [
            'email' => 'friend@example.com',
        ]);

        $inviteResponse->assertStatus(200)->assertJsonPath('success', true);

        $pendingResponse = $this->getJson('/api/challenges/invitations/pending');
        $pendingResponse->assertStatus(200)->assertJsonPath('success', true);
    }

    public function test_templates_endpoint_returns_arabic_presets(): void
    {
        $response = $this->getJson('/api/challenges/templates');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => [
                    '*' => ['id', 'name_ar', 'name_en', 'duration_days'],
                ],
            ]);

        $this->assertNotEmpty($response->json('data'));
    }

    public function test_check_in_and_leaderboard_work(): void
    {
        $create = $this->postJson('/api/challenges/from-template', [
            'template_id' => 'no_extra_week',
        ]);
        $create->assertStatus(201);
        $id = (int) $create->json('data.id');

        $checkIn = $this->postJson("/api/challenges/{$id}/check-in", [
            'user_id' => 1,
        ]);
        $checkIn->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('meta.already_checked_in', false);

        $progress = $this->postJson("/api/challenges/{$id}/progress", [
            'user_id' => 1,
            'amount' => 250,
        ]);
        $progress->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.participants.0.current_progress', 250);

        $leaderboard = $this->getJson("/api/challenges/{$id}/leaderboard");
        $leaderboard->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => ['challenge_id', 'entries'],
            ]);
    }
}
