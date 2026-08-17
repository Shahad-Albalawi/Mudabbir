<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GoalContribution extends Model
{
    protected $fillable = [
        'id', 'goal_id', 'amount', 'contributed_at', 'note',
    ];

    protected $casts = [
        'amount' => 'float',
        'contributed_at' => 'datetime',
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
            'amount' => (float) $this->amount,
            'contributed_at' => $this->contributed_at->toISOString(),
            'note' => $this->note,
        ];
    }
}
