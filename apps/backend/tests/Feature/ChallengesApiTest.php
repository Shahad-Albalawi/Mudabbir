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
}
