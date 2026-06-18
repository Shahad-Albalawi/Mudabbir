<?php

namespace Tests\Feature;

use Tests\TestCase;

class GoalsApiTest extends TestCase
{
    public function test_goals_crud_and_contribution_workflow(): void
    {
        $auth = $this->registerUser('goals@example.com');

        $index = $this->withApiAuth($auth)->getJson('/api/goals');
        $index->assertStatus(200)->assertJsonPath('success', true);

        $create = $this->withApiAuth($auth)->postJson('/api/goals', [
            'name' => 'هدف سيارة',
            'target' => 5000,
            'current_amount' => 500,
            'type' => 'Saving',
            'start_date' => '2025-01-01',
            'end_date' => '2025-12-31',
        ]);
        $create->assertStatus(201)->assertJsonPath('success', true);
        $id = (int) $create->json('data.id');

        $show = $this->withApiAuth($auth)->getJson("/api/goals/{$id}");
        $show->assertStatus(200)->assertJsonPath('data.current_amount', 500);

        $contrib = $this->withApiAuth($auth)->postJson("/api/goals/{$id}/contributions", [
            'amount' => 250,
            'note' => 'إيداع شهري',
        ]);
        $contrib->assertStatus(200)->assertJsonPath('data.current_amount', 750);

        $update = $this->withApiAuth($auth)->putJson("/api/goals/{$id}", [
            'name' => 'هدف محدّث',
            'target' => 6000,
            'end_date' => '2026-06-30',
        ]);
        $update->assertStatus(200)
            ->assertJsonPath('data.name', 'هدف محدّث')
            ->assertJsonPath('data.target', 6000);

        $delete = $this->withApiAuth($auth)->deleteJson("/api/goals/{$id}");
        $delete->assertStatus(200)->assertJsonPath('success', true);
    }
}
