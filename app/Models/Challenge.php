<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Challenge extends Model
{
    public $incrementing = false;

    protected $keyType = 'int';

    protected $fillable = [
        'id', 'user_id', 'creator_id', 'creator_name', 'creator_email',
        'name', 'amount', 'start_date', 'end_date', 'achieved',
    ];

    protected $casts = [
        'amount' => 'float',
        'start_date' => 'date',
        'end_date' => 'date',
        'achieved' => 'boolean',
    ];

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'creator_id');
    }

    public function participants(): HasMany
    {
        return $this->hasMany(ChallengeParticipant::class);
    }

    public function scopeAccessibleBy(Builder $query, int $userId): Builder
    {
        return $query->where(function (Builder $inner) use ($userId): void {
            $inner->where('creator_id', $userId)
                ->orWhereHas(
                    'participants',
                    fn (Builder $participants): Builder => $participants
                        ->where('participant_id', $userId)
                        ->where('status', 'accepted')
                );
        });
    }

    public function isCreator(int $userId): bool
    {
        return (int) $this->creator_id === $userId;
    }

    public function isAccessibleBy(int $userId): bool
    {
        if ($this->isCreator($userId)) {
            return true;
        }

        $this->loadMissing('participants');

        return $this->participants
            ->contains(fn (ChallengeParticipant $participant): bool => (int) $participant->participant_id === $userId
                && $participant->status === 'accepted');
    }

    public function hasAcceptedParticipant(int $userId): bool
    {
        $this->loadMissing('participants');

        return $this->participants
            ->contains(fn (ChallengeParticipant $participant): bool => (int) $participant->participant_id === $userId
                && $participant->status === 'accepted');
    }

    /**
     * @return array<string, mixed>
     */
    public function toStoreArray(): array
    {
        $this->loadMissing('participants');

        return [
            'id' => (int) $this->id,
            'user_id' => (int) $this->user_id,
            'name' => (string) $this->name,
            'amount' => (float) $this->amount,
            'start_date' => $this->start_date->format('Y-m-d'),
            'end_date' => $this->end_date->format('Y-m-d'),
            'achieved' => (bool) $this->achieved,
            'creator_id' => (int) $this->creator_id,
            'creator' => [
                'id' => (int) $this->creator_id,
                'name' => (string) $this->creator_name,
                'email' => (string) $this->creator_email,
            ],
            'participants' => $this->participants
                ->map(fn (ChallengeParticipant $p): array => $p->toStoreArray())
                ->values()
                ->all(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
