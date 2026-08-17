<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Goal extends Model
{
    protected $fillable = [
        'id', 'user_id', 'name', 'target', 'current_amount', 'type',
        'start_date', 'end_date', 'image_path', 'is_completed', 'completed_at',
    ];

    protected $casts = [
        'target' => 'float',
        'current_amount' => 'float',
        'start_date' => 'date',
        'end_date' => 'date',
        'is_completed' => 'boolean',
        'completed_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function contributions(): HasMany
    {
        return $this->hasMany(GoalContribution::class);
    }

    public function milestones(): HasMany
    {
        return $this->hasMany(GoalMilestone::class);
    }

    public function scopeForUser(Builder $query, int $userId): Builder
    {
        return $query->where('user_id', $userId);
    }

    /**
     * @return array<string, mixed>
     */
    public function toStoreArray(): array
    {
        $this->loadMissing(['contributions', 'milestones']);

        return [
            'id' => (int) $this->id,
            'user_id' => (int) $this->user_id,
            'name' => (string) $this->name,
            'target' => (float) $this->target,
            'current_amount' => (float) $this->current_amount,
            'type' => (string) $this->type,
            'start_date' => $this->start_date->format('Y-m-d'),
            'end_date' => $this->end_date->format('Y-m-d'),
            'image_path' => $this->image_path,
            'is_completed' => (bool) $this->is_completed,
            'completed_at' => $this->completed_at?->toISOString(),
            'contributions' => $this->contributions->map(fn (GoalContribution $c): array => $c->toStoreArray())->values()->all(),
            'milestones' => $this->milestones->map(fn (GoalMilestone $m): array => $m->toStoreArray())->values()->all(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
