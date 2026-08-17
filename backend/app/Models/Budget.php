<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Budget extends Model
{
    public $incrementing = false;

    protected $keyType = 'int';

    protected $fillable = [
        'id', 'user_id', 'amount', 'start_date', 'end_date', 'account_id',
    ];

    protected $casts = [
        'amount' => 'float',
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
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
        return [
            'id' => (int) $this->id,
            'user_id' => (int) $this->user_id,
            'amount' => (float) $this->amount,
            'start_date' => $this->start_date->format('Y-m-d'),
            'end_date' => $this->end_date->format('Y-m-d'),
            'account_id' => (int) $this->account_id,
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
