<?php

namespace Tests\Feature;

use Tests\TestCase;

class GoalsMilestonesApiTest extends TestCase
{
    public function test_goal_milestones_are_created_and_achieved_on_contribution(): void
    {
        $auth = $this->registerUser('milestones@example.com');

        $create = $this->withApiAuth($auth)->postJson('/api/goals', [
            'name' => 'طوارئ',
            'target' => 1000,
            'current_amount' => 0,
            'type' => 'Saving',
            'start_date' => '2025-01-01',
            'end_date' => '2025-12-31',
        ]);
        $create->assertStatus(201);
        $goalId = (int) $create->json('data.id');

        $milestone = $this->withApiAuth($auth)->postJson("/api/goals/{$goalId}/milestones", [
            'title' => 'المرحلة الأولى',
            'target_amount' => 250,
        ]);
        $milestone->assertStatus(201)->assertJsonPath('data.milestones.0.title', 'المرحلة الأولى');

        $contrib = $this->withApiAuth($auth)->postJson("/api/goals/{$goalId}/contributions", [
            'amount' => 300,
        ]);
        $contrib->assertOk();
        $contrib->assertJsonPath('data.milestones.0.is_achieved', true);
    }
}
