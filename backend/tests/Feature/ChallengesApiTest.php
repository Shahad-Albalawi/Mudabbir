<?php

namespace Tests\Feature;

use Tests\TestCase;

class ChallengesApiTest extends TestCase
{
    public function test_challenges_index_returns_success_shape(): void
    {
        $auth = $this->registerUser('challenges@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/challenges');

        $response->assertStatus(200)->assertJsonStructure([
            'success',
            'data',
        ]);
    }

    public function test_invite_and_pending_invitations_work(): void
    {
        $owner = $this->registerUser('owner@example.com');
        $create = $this->withApiAuth($owner)->postJson('/api/challenges/from-template', [
            'template_id' => 'no_extra_week',
        ]);
        $create->assertStatus(201);
        $id = (int) $create->json('data.id');

        $inviteResponse = $this->withApiAuth($owner)->postJson("/api/challenges/{$id}/invite", [
            'email' => 'friend@example.com',
        ]);

        $inviteResponse->assertStatus(200)->assertJsonPath('success', true);

        $invitee = $this->registerUser('friend@example.com');
        $pendingResponse = $this->withApiAuth($invitee)->getJson('/api/challenges/invitations/pending');
        $pendingResponse->assertStatus(200)->assertJsonPath('success', true);
        $this->assertNotEmpty($pendingResponse->json('data'));
    }

    public function test_templates_endpoint_returns_arabic_presets(): void
    {
        $auth = $this->registerUser('templates@example.com');

        $response = $this->withApiAuth($auth)->getJson('/api/challenges/templates');

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
        $auth = $this->registerUser('checkin@example.com');

        $create = $this->withApiAuth($auth)->postJson('/api/challenges/from-template', [
            'template_id' => 'no_extra_week',
        ]);
        $create->assertStatus(201);
        $id = (int) $create->json('data.id');

        $checkIn = $this->withApiAuth($auth)->postJson("/api/challenges/{$id}/check-in");
        $checkIn->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('meta.already_checked_in', false);

        $progress = $this->withApiAuth($auth)->postJson("/api/challenges/{$id}/progress", [
            'amount' => 250,
        ]);
        $progress->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.participants.0.current_progress', 250);

        $leaderboard = $this->withApiAuth($auth)->getJson("/api/challenges/{$id}/leaderboard");
        $leaderboard->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => ['challenge_id', 'entries'],
            ]);
    }

    public function test_respond_matches_invitee_by_email_not_provisional_id(): void
    {
        $owner = $this->registerUser('owner-respond@example.com');
        $create = $this->withApiAuth($owner)->postJson('/api/challenges/from-template', [
            'template_id' => 'no_extra_week',
        ]);
        $create->assertStatus(201);
        $id = (int) $create->json('data.id');

        $this->withApiAuth($owner)->postJson("/api/challenges/{$id}/invite", [
            'email' => 'alice-respond@example.com',
        ])->assertStatus(200);

        $bob = $this->registerUser('bob-respond@example.com');
        $this->withApiAuth($bob)->postJson("/api/challenges/{$id}/respond", [
            'status' => 'accepted',
        ])->assertStatus(404);

        $alice = $this->registerUser('alice-respond@example.com');
        $accept = $this->withApiAuth($alice)->postJson("/api/challenges/{$id}/respond", [
            'status' => 'accepted',
        ]);
        $accept->assertStatus(200)->assertJsonPath('success', true);

        $participants = $accept->json('data.participants');
        $aliceParticipant = collect($participants)->firstWhere(
            'email',
            'alice-respond@example.com'
        );
        $this->assertSame('accepted', $aliceParticipant['status']);
        $this->assertSame((int) $alice['user']['id'], $aliceParticipant['id']);
    }

    public function test_multiple_invitees_respond_independently(): void
    {
        $owner = $this->registerUser('owner-multi@example.com');
        $create = $this->withApiAuth($owner)->postJson('/api/challenges/from-template', [
            'template_id' => 'no_extra_week',
        ]);
        $id = (int) $create->json('data.id');

        $this->withApiAuth($owner)->postJson("/api/challenges/{$id}/invite", [
            'email' => 'first-multi@example.com',
        ])->assertStatus(200);
        $this->withApiAuth($owner)->postJson("/api/challenges/{$id}/invite", [
            'email' => 'second-multi@example.com',
        ])->assertStatus(200);

        $first = $this->registerUser('first-multi@example.com');
        $second = $this->registerUser('second-multi@example.com');

        $this->withApiAuth($first)->postJson("/api/challenges/{$id}/respond", [
            'status' => 'accepted',
        ])->assertStatus(200);

        $reject = $this->withApiAuth($second)->postJson("/api/challenges/{$id}/respond", [
            'status' => 'rejected',
        ]);
        $reject->assertStatus(200);

        $participants = collect($reject->json('data.participants'));
        $this->assertSame(
            'accepted',
            $participants->firstWhere('email', 'first-multi@example.com')['status']
        );
        $this->assertSame(
            'rejected',
            $participants->firstWhere('email', 'second-multi@example.com')['status']
        );
    }
}
