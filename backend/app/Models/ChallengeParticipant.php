<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ChallengeParticipant extends Model
{
    protected $fillable = [
        'challenge_id', 'participant_id', 'name', 'email', 'status',
        'target_amount', 'achieved', 'current_progress', 'streak_days',
        'longest_streak', 'last_check_in', 'badges',
    ];

    protected $casts = [
        'participant_id' => 'integer',
        'target_amount' => 'float',
        'achieved' => 'boolean',
        'current_progress' => 'float',
        'streak_days' => 'integer',
        'longest_streak' => 'integer',
        'last_check_in' => 'date',
        'badges' => 'array',
    ];

    public function challenge(): BelongsTo
    {
        return $this->belongsTo(Challenge::class);
    }

    /**
     * @return array<string, mixed>
     */
    public function toStoreArray(): array
    {
        return [
            'id' => (int) $this->participant_id,
            'name' => (string) $this->name,
            'email' => (string) $this->email,
            'status' => (string) $this->status,
            'target_amount' => $this->target_amount !== null ? (float) $this->target_amount : null,
            'achieved' => (bool) $this->achieved,
            'current_progress' => (float) $this->current_progress,
            'streak_days' => (int) $this->streak_days,
            'longest_streak' => (int) $this->longest_streak,
            'last_check_in' => $this->last_check_in?->format('Y-m-d'),
            'badges' => array_values($this->badges ?? []),
        ];
    }
}
