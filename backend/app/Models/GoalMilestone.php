<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GoalMilestone extends Model
{
    public $incrementing = false;

    protected $keyType = 'int';

    protected $fillable = [
        'id', 'goal_id', 'title', 'target_amount', 'is_achieved', 'achieved_at',
    ];

    protected $casts = [
        'target_amount' => 'float',
        'is_achieved' => 'boolean',
        'achieved_at' => 'datetime',
    ];

    public function goal(): BelongsTo
    {
        return $this->belongsTo(Goal::class);
    }

    /**
     * @return array<string, mixed>
     */
    public function toStoreArray(): array
    {
        return [
            'id' => (int) $this->id,
            'goal_id' => (int) $this->goal_id,
            'title' => (string) $this->title,
            'target_amount' => (float) $this->target_amount,
            'is_achieved' => (bool) $this->is_achieved,
            'achieved_at' => $this->achieved_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
