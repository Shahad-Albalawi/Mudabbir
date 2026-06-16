<?php

namespace Tests\Feature;

use Tests\TestCase;

class GoalsApiTest extends TestCase
{
    public function test_goals_crud_and_contribution_workflow(): void
    {
        $index = $this->getJson('/api/goals');
        $index->assertStatus(200)->assertJsonPath('success', true);

        $create = $this->postJson('/api/goals', [
            'name' => 'هدف سيارة',
            'target' => 5000,
            'current_amount' => 500,
            'type' => 'Saving',
            'start_date' => '2025-01-01',
            'end_date' => '2025-12-31',
        ]);
        $create->assertStatus(201)->assertJsonPath('success', true);
        $id = (int) $create->json('data.id');

        $show = $this->getJson("/api/goals/{$id}");
        $show->assertStatus(200)->assertJsonPath('data.current_amount', 500);

        $contrib = $this->postJson("/api/goals/{$id}/contributions", [
            'amount' => 250,
            'note' => 'إيداع شهري',
        ]);
        $contrib->assertStatus(200)->assertJsonPath('data.current_amount', 750);

        $delete = $this->deleteJson("/api/goals/{$id}");
        $delete->assertStatus(200)->assertJsonPath('success', true);
    }
}
