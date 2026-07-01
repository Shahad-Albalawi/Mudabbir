<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GoalResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray($request): array
    {
        $goal = is_array($this->resource) ? $this->resource : (array) $this->resource;

        return [
            'id' => (int) $goal['id'],
            'user_id' => (int) ($goal['user_id'] ?? 0),
            'name' => (string) $goal['name'],
            'target' => (float) $goal['target'],
            'current_amount' => (float) ($goal['current_amount'] ?? 0),
            'type' => (string) ($goal['type'] ?? 'Saving'),
            'start_date' => (string) $goal['start_date'],
            'end_date' => (string) $goal['end_date'],
            'image_path' => $goal['image_path'] ?? null,
            'is_completed' => (bool) ($goal['is_completed'] ?? false),
            'completed_at' => $goal['completed_at'] ?? null,
            'contributions' => $goal['contributions'] ?? [],
            'milestones' => $goal['milestones'] ?? [],
            'created_at' => $goal['created_at'] ?? null,
            'updated_at' => $goal['updated_at'] ?? null,
        ];
    }
}
